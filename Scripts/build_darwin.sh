#!/bin/bash
set -euo pipefail

ARCH="$(uname -m)"
BUILD_TYPE="${1:-Release}"

FFMPEG_VERSION=8.0.1
FFMPEG_SOURCE_DIR=FFmpeg-n$FFMPEG_VERSION
FFMPEG_PREFIX=$HOME/.build/ffmpeg/

if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
else
  if [[ "$ARCH" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
  else
    BREW_PREFIX="/usr/local"
  fi
fi

PKG_BIN_PATH="${BREW_PREFIX}/bin"
PKG_LIB_PATH="${BREW_PREFIX}/lib"
PKG_INCLUDE_PATH="${BREW_PREFIX}/include"
PKG_CONFIG_PATH="${PKG_LIB_PATH}/pkgconfig:${BREW_PREFIX}/share/pkgconfig"

export PATH="${PKG_BIN_PATH}:$PATH"
export PKG_CONFIG_PATH
export CFLAGS="-I${PKG_INCLUDE_PATH}"
export CXXFLAGS="-I${PKG_INCLUDE_PATH}"
export LDFLAGS="-L${PKG_LIB_PATH}"

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
  --target-os="darwin" \
  --prefix=$FFMPEG_PREFIX \
  --enable-pthreads \
  --enable-runtime-cpudetect \
  --enable-version3 \
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
