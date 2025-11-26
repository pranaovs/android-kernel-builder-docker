#!/bin/bash
set -euo pipefail

TOOLCHAIN_DIR="/toolchain"
KERNEL_DIR="/kernel"

# Set defaults for all optional variables
: "${ARCH:=arm64}"
: "${KBUILD_BUILD_USER:=$(whoami)}"
: "${KBUILD_BUILD_HOST:=$(hostname)}"
: "${LLVM:=1}"
: "${TOOLCHAIN_CLANG_GIT_BRANCH:=}"
: "${KERNEL_SOURCE_GIT_BRANCH:=}"
: "${KERNEL_CONFIG_ARGS:=}"
: "${KERNEL_ADDITIONAL_CONFIG_ARGS:=}"
: "${KERNEL_BUILD_ARGS:=}"

required_vars=("DEFCONFIG")

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: $var environment variable is not set" >&2
    exit 1
  fi
done

############# TOOLCHAIN SETUP #############

# Check that at least one toolchain variable is set
if [ -z "$TOOLCHAIN_CLANG" ] && [ -z "$TOOLCHAIN_CLANG_GIT" ]; then
  echo "Error: Either TOOLCHAIN_CLANG or TOOLCHAIN_CLANG_GIT must be set" >&2
  exit 1
fi

# auto-populate toolchain_clang from toolchain_clang_git if not set
if [ -z "$TOOLCHAIN_CLANG" ] && [ -n "$TOOLCHAIN_CLANG_GIT" ]; then
  TOOLCHAIN_CLANG=$(basename "$TOOLCHAIN_CLANG_GIT" .git)
fi

# Fetch Clang toolchain if not already present
if [ -d "$TOOLCHAIN_DIR/$TOOLCHAIN_CLANG" ]; then
  echo "Using existing Clang toolchain at $TOOLCHAIN_DIR/$TOOLCHAIN_CLANG"
else
  git clone --depth=1 \
    ${TOOLCHAIN_CLANG_GIT_BRANCH:+--branch "$TOOLCHAIN_CLANG_GIT_BRANCH"} \
    "$TOOLCHAIN_CLANG_GIT" \
    "$TOOLCHAIN_DIR/$TOOLCHAIN_CLANG" || {
    echo "Error: Failed to clone Clang toolchain" >&2
    exit 1
  }
fi

LLVM_BIN="$TOOLCHAIN_DIR/$TOOLCHAIN_CLANG/bin"

############# KERNEL SOURCE SETUP #############

# Check that at least one kernel source variable is set
if [ -z "$KERNEL_SOURCE" ] && [ -z "$KERNEL_SOURCE_GIT" ]; then
  echo "Error: Either KERNEL_SOURCE or KERNEL_SOURCE_GIT must be set" >&2
  exit 1
fi

# auto-populate kernel_source from kernel_source_git if not set
if [ -z "$KERNEL_SOURCE" ] && [ -n "$KERNEL_SOURCE_GIT" ]; then
  KERNEL_SOURCE=$(basename "$KERNEL_SOURCE_GIT" .git)
fi

# Fetch kernel source if not already present
if [ -d "$KERNEL_DIR/$KERNEL_SOURCE" ]; then
  echo "Using existing kernel source at $KERNEL_DIR/$KERNEL_SOURCE"
else
  git clone --depth=1 \
    ${KERNEL_SOURCE_GIT_BRANCH:+--branch "$KERNEL_SOURCE_GIT_BRANCH"} \
    "$KERNEL_SOURCE_GIT" \
    "$KERNEL_DIR/$KERNEL_SOURCE" || {
    echo "Error: Failed to clone kernel source" >&2
    exit 1
  }
fi

KDIR="$KERNEL_DIR/$KERNEL_SOURCE"

############# KERNEL COMPIlATION #############

echo "Compiling $(git -C "$KDIR" branch --show-current) kernel for $DEFCONFIG"

mkdir -p "$KDIR/out"

echo "Configuring kernel with $DEFCONFIG and additional args: $KERNEL_CONFIG_ARGS"
make \
  O="$KDIR/out" \
  ARCH="$ARCH" \
  "$KERNEL_CONFIG_ARGS" \
  "$DEFCONFIG"

echo "Running additional configuration with extra args: $KERNEL_ADDITIONAL_CONFIG_ARGS"
make \
  O="$KDIR/out" \
  CC=clang \
  LD="${LLVM_BIN}/ld.lld" \
  ARCH="$ARCH" \
  AR="${LLVM_BIN}/llvm-ar" \
  NM="${LLVM_BIN}/llvm-nm" \
  AS="${LLVM_BIN}/llvm-as" \
  OBJCOPY="${LLVM_BIN}/llvm-objcopy" \
  OBJDUMP="${LLVM_BIN}/llvm-objdump" \
  READELF="${LLVM_BIN}/llvm-readelf" \
  OBJSIZE="${LLVM_BIN}/llvm-size" \
  STRIP="${LLVM_BIN}/llvm-strip" \
  LLVM_AR="${LLVM_BIN}/llvm-ar" \
  LLVM_DIS="${LLVM_BIN}/llvm-dis" \
  LLVM_NM="${LLVM_BIN}/llvm-nm" \
  LLVM=1 \
  "$KERNEL_ADDITIONAL_CONFIG_ARGS" \
  "$DEFCONFIG"

echo "Starting kernel build with args: $KERNEL_BUILD_ARGS"
make \
  -j"$(nproc --all)" \
  O="$KDIR/out" \
  CC=clang \
  LD="${LLVM_BIN}/ld.lld" \
  ARCH="$ARCH" \
  AR="${LLVM_BIN}/llvm-ar" \
  NM="${LLVM_BIN}/llvm-nm" \
  AS="${LLVM_BIN}/llvm-as" \
  OBJCOPY="${LLVM_BIN}/llvm-objcopy" \
  OBJDUMP="${LLVM_BIN}/llvm-objdump" \
  READELF="${LLVM_BIN}/llvm-readelf" \
  OBJSIZE="${LLVM_BIN}/llvm-size" \
  STRIP="${LLVM_BIN}/llvm-strip" \
  LLVM_AR="${LLVM_BIN}/llvm-ar" \
  LLVM_DIS="${LLVM_BIN}/llvm-dis" \
  LLVM_NM="${LLVM_BIN}/llvm-nm" \
  LLVM=1 \
  "$KERNEL_BUILD_ARGS"
