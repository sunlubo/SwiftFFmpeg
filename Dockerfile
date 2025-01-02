FROM swift:6.0-jammy AS base

ENV ARCH="aarch64"
ENV PKG_LIB_PATH=/usr/local/lib/
ENV PKG_INCLUDE_PATH=/usr/local/include/
ENV PKG_BIN_PATH=/usr/local/bin/

ENV FFMPEG_VERSION=7.1
ENV FFMPEG_SOURCE_DIR=FFmpeg-n$FFMPEG_VERSION
ENV FFMPEG_PREFIX=/workspace/ffmpeg/

ENV APP_VERSION=0.0
ENV APP_SOURCE_DIR=app-n$APP_VERSION
ENV APP_PREFIX=/workspace/app/



FROM base AS ffmpeg

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  && apt-get -q update \
  && apt-get -q dist-upgrade -y \
  && apt-get -q install -y \
    build-essential \
    pkg-config \
    curl \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

COPY <<'EOF' /usr/local/bin/build.sh
#!/bin/bash
set -e

BUILD_TYPE=${1:-Release}

CC=gcc
CXX=g++
AR=ar
LD=ld
RANLIB=ranlib
STRIP=strip

mkdir -p $FFMPEG_PREFIX
cd $FFMPEG_PREFIX

if [ ! -d $FFMPEG_SOURCE_DIR ]; then
  echo "Start downloading FFmpeg..."
  curl -LJO https://codeload.github.com/FFmpeg/FFmpeg/tar.gz/n$FFMPEG_VERSION || exit 1
  tar -zxvf FFmpeg-n$FFMPEG_VERSION.tar.gz || exit 1
  rm -f FFmpeg-n$FFMPEG_VERSION.tar.gz
fi

cd $FFMPEG_SOURCE_DIR
./configure \
  --disable-everything \
  --extra-cflags="-I$FFMPEG_PREFIX/include" \
  --extra-ldflags="-L$FFMPEG_PREFIX/lib" \
  --arch=$ARCH \
  --target-os="linux" \
  --prefix=$FFMPEG_PREFIX \
  --enable-pthreads \
  --enable-runtime-cpudetect \
  --enable-version3 \
  --enable-gpl \
  --enable-static \
  --enable-pic \
  --enable-encoder=jpeg,png,webp,tiff,bmp,ppm \
  --enable-decoder=jpeg,png,webp,tiff,bmp,ppm \
  --enable-avutil \
  --enable-avcodec \
  --enable-swscale \
  --enable-libwebp \
  --enable-filter=scale \
  --enable-filter=crop \
  --enable-filter=transpose \
  --enable-filter=rotate \
  --enable-filter=pad \
  --enable-filter=colorchannelmixer \
  --enable-filter=eq \
  --enable-filter=overlay \
  --enable-filter=colorspace \
  --enable-filter=format
  
make clean
make -j8 install || 1
EOF

RUN chmod +x /usr/local/bin/build.sh \
  && /usr/local/bin/build.sh



FROM base AS app

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  && apt-get -q update \
  && apt-get -q dist-upgrade -y \
  && apt-get -q install -y \
    cmake \
    clang \
    lld \
    llvm \
    pkg-config \
    git \
    curl \
    nasm \
    yasm \
    zlib1g-dev \
    libjemalloc-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR $APP_PREFIX

RUN mkdir /workspace/ffmpeg
COPY --from=ffmpeg ${FFMPEG_PREFIX}/ ${FFMPEG_PREFIX}
RUN ln -s ${FFMPEG_PREFIX}/lib/* $PKG_LIB_PATH \
  && ln -s ${FFMPEG_PREFIX}/bin/* $PKG_BIN_PATH \
  && ln -s ${FFMPEG_PREFIX}/include/* $PKG_INCLUDE_PATH

RUN mkdir $APP_SOURCE_DIR \
  && cd $APP_SOURCE_DIR
COPY ./Package.* ./
RUN swift package resolve \
      $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)
COPY . .

COPY <<'EOF' /usr/local/bin/build.sh
#!/bin/bash
set -e

# Default build type
BUILD_TYPE=${1:-Release}

CC=clang
CXX=clang++
AR=llvm-ar
LD=lld
RANLIB=llvm-ranlib
STRIP=llvm-strip

swift build \
  -c release \
  -Xlinker -ljemalloc \
  --build-path $APP_PREFIX \
  --static-swift-stdlib 
EOF

RUN chmod +x ${PKG_BIN_PATH}/build.sh \
  && ${PKG_BIN_PATH}/build.sh
