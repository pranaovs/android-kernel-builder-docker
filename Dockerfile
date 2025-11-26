FROM ubuntu:22.04
WORKDIR /builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install all required packages
RUN apt-get update && apt-get install -y \
  android-sdk-libsparse-utils \
  bash-completion \
  bc \
  tmux \
  bison \
  build-essential \
  bzip2 \
  neofetch \
  coreutils \
  cpio \
  curl \
  rsync \
  default-jdk \
  device-tree-compiler \
  e2fsprogs \
  erofs-utils \
  f2fs-tools \
  file \
  findutils \
  flex \
  g++ \
  gcc \
  git \
  gnupg \
  gperf \
  grep \
  htop \
  iproute2 \
  iputils-ping \
  kmod \
  libarchive-tools \
  libc6-dev \
  libelf-dev \
  libgl1 \
  libgl1-mesa-dev \
  libncurses-dev \
  libreadline-dev \
  libssl-dev \
  libx11-dev \
  libxml2-utils \
  lz4 \
  make \
  nano \
  net-tools \
  openssl \
  openjdk-17-jdk \
  p7zip-full \
  pahole \
  procps \
  python-is-python3 \
  python3 \
  python3-markdown \
  python3-pip \
  repo \
  sudo \
  tar \
  tofrodos \
  unzip \
  tree \
  util-linux \
  vim \
  wget \
  xsltproc \
  xz-utils \
  zip \
  zlib1g-dev \
  zstd \
  --fix-missing && \
  wget http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb && \
  dpkg -i libtinfo5_6.3-2ubuntu0.1_amd64.deb && \
  rm libtinfo5_6.3-2ubuntu0.1_amd64.deb && \
  apt-get full-upgrade -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /toolchain && \
  mkdir /kernel

COPY build.sh ./build.sh
RUN chmod +x ./build.sh

CMD ["./build.sh"]

