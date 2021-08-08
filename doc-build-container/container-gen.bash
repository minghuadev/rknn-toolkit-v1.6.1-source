#!/bin/bash
# container-gen.bash
# modified from rk18 build container to adapt to build rv1126

# current uid and gid 
curr_uid=`id -u` 
curr_gid=`id -g` 

echo Creating tmp-gen.dockerfile ...

# create tmp-gen.dockerfile:
cat << EOF1 > tmp-gen.dockerfile

 # previously used ubuntu:bionic
 FROM ubuntu:focal-20201106

 RUN apt-get update
 RUN apt-get install -y git tree openssh-client make
 RUN apt-get install -y bzip2 gcc libncurses5-dev bc
 RUN apt-get install -y file vim
 RUN apt-get install -y zlib1g-dev g++
 RUN apt-get install -y libssl-dev

 # from other sdk requirements:
 #RUN apt-get install -y make zlib1g-dev libncurses5-dev g++ bc libssl-dev 
 RUN apt-get install -y lib32z1 lib32stdc++6  ncurses-term libncursesw5-dev

 # tzdata
   ## preesed tzdata, update package index, upgrade packages and install needed software
   RUN truncate -s0 /tmp/preseed.cfg && \
       (echo "tzdata tzdata/Areas select America" >> /tmp/preseed.cfg) && \
       (echo "tzdata tzdata/Zones/America select Los_Angeles" >> /tmp/preseed.cfg) && \
       debconf-set-selections /tmp/preseed.cfg && \
       rm -f /etc/timezone /etc/localtime && \
       apt-get update && \
       DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
       apt-get install -y tzdata
   ## cleanup of files from setup
   RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

 # from other sdk requirements:
 RUN apt-get update
 RUN apt-get install -y texinfo texlive gawk 

 # needed by wl18xx build
 RUN apt-get install -y autoconf libtool libglib2.0-dev bison flex

 # rk1808 96boards-tb-96aiot dependencies:
 RUN dpkg --add-architecture i386
 RUN apt-get update
 RUN DEBIAN_FRONTEND="noninteractive" TZ="America/Los_Angeles" apt-get install -y \
    git-core gitk git-gui gcc-arm-linux-gnueabihf u-boot-tools \
    device-tree-compiler gcc-aarch64-linux-gnu mtools parted libudev-dev libusb-1.0-0-dev \
    autoconf autotools-dev libsigsegv2 m4 \
    intltool libdrm-dev \
    curl sed \
    make binutils build-essential gcc g++ bash patch gzip bzip2 perl tar cpio python unzip \
    rsync file \
    bc wget libncurses5 \
    libglib2.0-dev libgtk2.0-dev libglade2-dev cvs git \
    mercurial rsync openssh-client subversion asciidoc w3m dblatex graphviz \
    libc6:i386 liblz4-tool \
    gawk

  # repo: removed to use a local copy
  # gawk: needed to build u-boot image.
  # libqt4-dev : removed for focal
  # python-linaro-image-tools linaro-image-tools : removed for focal
  # python-matplotlib : removed for focal

 # time needed for the rk1808 recovery build.sh script:
 RUN apt-get install -y time

 ARG UNAME=rk18user

 ARG UID=9999
 ARG GID=9999

 RUN groupadd -g \$GID \$UNAME
 RUN useradd -m -u \$UID -g \$GID -s /bin/bash \$UNAME

 RUN rm /bin/sh && ln -s bash /bin/sh
 RUN cp -a /etc /etc-original && chmod a+rw /etc

 USER \$UNAME

 CMD /bin/bash
EOF1

echo Docker build off tmp-gen.dockerfile ...
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
     -f tmp-gen.dockerfile  -t rk18image .

echo Docker build finished ...


