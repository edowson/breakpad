#!/bin/bash

set -e

# script variables
HOST_ARCH=$(uname -m)

# use HOST_ARCH to map TARGET_ARCH target triple
if   [[ "$HOST_ARCH" == "x86_64" ]]; then
    TARGET_ARCH=x86_64-unknown-linux-gnu
elif [[ "$HOST_ARCH" == "ppc64le" ]]; then
    TARGET_ARCH=powerpc64le-unknown-linux-gnu
elif [[ "$HOST_ARCH" == "aarch64" ]]; then
    TARGET_ARCH=aarch64-unknown-linux-gnu
else
    echo "${red}Error: Unsupported host platform architecture: $HOST_ARCH${reset}"
    exit 1
fi

export CC=clang
export CXX=clang++
TEMP_DIR="/tmp/local-breakpad-$BASHPID"
BASE_DIR=`pwd`
BINARY_INSTALL="$BASE_DIR/../bin/linux/"

echo "BASE_DIR=$BASE_DIR"
echo "BINARY_INSTALL=$BINARY_INSTALL"

# libcxx flags
if [ 1 ]; then
	export INTERNAL_CXX_CXXFLAGS=""
	export INTERNAL_CXX_LDFLAGS=""
	export INTERNAL_CXX_ABI_LIBS=""
fi

export CXXFLAGS="-O3 -fPIC -std=c++11 -stdlib=libc++ ${INTERNAL_CXX_CXXFLAGS}"
export LDFLAGS="${INTERNAL_CXX_LDFLAGS}"
export LIBS="${INTERNAL_CXX_ABI_LIBS} -lm -lc -lgcc_s -lgcc -lpthread"

# configure
./configure --prefix=$TEMP_DIR --disable-processor --build=$TARGET_ARCH

# build
make clean
make -j`nproc` install

echo "=========== Copy dump_syms Binary ============"
echo "cp $TEMP_DIR/bin/dump_syms $BINARY_INSTALL"

if [[ ! -d $BINARY_INSTALL ]]; then
  mkdir -p $BINARY_INSTALL
fi

cp $TEMP_DIR/bin/dump_syms $BINARY_INSTALL
