#!/bin/bash
set -e

ARCH="aarch64"
PKG_LIB_PATH=/usr/local/lib/
PKG_INCLUDE_PATH=/usr/local/include/
PKG_BIN_PATH=/usr/local/bin/

FFMPEG_VERSION=7.1
FFMPEG_SOURCE_DIR=FFmpeg-n$FFMPEG_VERSION
FFMPEG_PREFIX=/workspace/ffmpeg/

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
