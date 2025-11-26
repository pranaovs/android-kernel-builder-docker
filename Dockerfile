FROM ubuntu:20.04

WORKDIR /builder

RUN apt-get update && \
  apt-get install -y git device-tree-compiler lz4 xz-utils zlib1g-dev openjdk-17-jdk gcc g++ \
  python3 python-is-python3 p7zip-full android-sdk-libsparse-utils erofs-utils default-jdk \
  git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses-dev libx11-dev \
  libreadline-dev libgl1 libgl1-mesa-dev python3 make gcc g++ bc grep tofrodos python3-markdown \
  libxml2-utils xsltproc zlib1g-dev python-is-python3 libc6-dev libtinfo6 make cpio kmod openssl \
  libelf-dev libssl-dev libarchive-tools zstd rsync --fix-missing && \
  wget --progress=dot:giga http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb && dpkg -i libtinfo5_6.3-2ubuntu0.1_amd64.deb

COPY build.sh ./build.sh
RUN chmod +x ./build.sh

CMD ["./build.sh"]

