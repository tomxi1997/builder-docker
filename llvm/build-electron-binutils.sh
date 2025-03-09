#!/usr/bin/env bash

#清理
rm -rf binutils-* build-binutils
#设置binutils版本和安装路径
export BV=binutils-2.44
export IN=$GITHUB_WORKSPACE/kernel_workspace/toolchain
#设置binutils版本可从https://mirrors.aliyun.com/gnu/binutils/寻找


#构建binutils 
echo "正在下载binutils中"
wget https://mirrors.aliyun.com/gnu/binutils/$BV.tar.xz
tar -xf $BV.tar.xz
rm *.xz

echo "正在构建64位binutils中"
mkdir build-binutils && cd build-binutils 
env CFLAGS=-O2 CXXFLAGS=-O2 ../$BV/configure --prefix=$IN --target=aarch64-linux-gnu --disable-compressed-debug-sections --disable-gdb --disable-werror --enable-deterministic-archives --enable-new-dtags --enable-plugins --enable-threads --quiet --with-system-zlib --disable-multilib --disable-nls --with-gnu-as --with-gnu-ld --enable-gold --enable-ld=default --with-pkgversion="Electron Binutils"
make -j8 && sudo make install
cd ..
rm -rf build-binutils 

echo "正在构建32位binutils中"
mkdir build-binutils && cd build-binutils
env CFLAGS=-O2 CXXFLAGS=-O2 ../$BV/configure --prefix=$IN --disable-compressed-debug-sections --disable-gdb --disable-werror --enable-deterministic-archives --enable-new-dtags --enable-plugins --enable-threads --quiet --with-system-zlib --disable-multilib --disable-nls --with-gnu-as --with-gnu-ld --program-prefix=arm-linux-gnueabi- --target=arm-linux-gnueabi --with-pkgversion="Electron Binutils"
make -j8 && sudo make install


