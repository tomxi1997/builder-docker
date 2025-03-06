#!/bin/bash
#以clang-r416183b为例
#以下的请查看#https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/android-msm-redbull-4.19-android14/clang-r416183b/manifest_7284624.xml，填写

#一下是最新版本的clang-r547379
#https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/main/clang-r547379
#更个提交清单如下 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/main/clang-r547379/manifest_13065274.xml
llvm_project_version=b718bcaf8c198c82f3021447d943401e3ab5bd54

binutils_version=

toolchain_utils_version=a1bb7f26cc6b735c3d685db12739bb03ad9a2993

llvm_android_version=456a459bd653ddf1cca170e7e9aef9d122a81731
#svn值，请查看$PW/llvm_android/patches/PATCHES.json，按情况写
svn_version=547379


#clang安装路径
CV=clang-r547379
install_path=$GITHUB_WORKSPACE/kernel_workspace/$CV

mkdir -p $GITHUB_WORKSPACE/kernel_workspace/aosp
export PW=$GITHUB_WORKSPACE/kernel_workspace/aosp
cd $PW
#每次变更，只需要更改↑上面的值即可，↓下面的可几乎可不动。
#----------------------------+--------------------------------------

#获取源码
#git clone https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/external/toolchain-utils toolchain-utils

#git clone https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/toolchain/binutils binutils

#git clone https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/toolchain/llvm_android llvm_android

#git clone https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/toolchain/llvm-project llvm-project


git clone https://android.googlesource.com/platform/external/toolchain-utils
git clone https://android.googlesource.com/toolchain/binutils
git clone https://android.googlesource.com/toolchain/llvm_android
git clone https://android.googlesource.com/toolchain/llvm-project

#https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/android-msm-redbull-4.19-android14/clang-r416183b/manifest_7284624.xml



#逐步检出唯一的版本
echo "…………………………………………………………………………………………………………………………………………………………………………………"
echo "检出toolchain-utils"
cd $PW/toolchain-utils
git checkout $toolchain_utils_version
echo "…………………………………………………………………………………………………………………………………………………………………………………"
#cd $PW/binutils
#git checkout $binutils_version

echo "…………………………………………………………………………………………………………………………………………………………………………………"
echo "检出llvm-project"
cd $PW/llvm-project
git checkout $llvm_project_version

echo "……………………………………………………………………………………………………………………………………………………………………………………"
echo "检出llvm-android"
cd $PW/llvm_android
git checkout $llvm_android_version
echo "……………………………………………………………………………………………………………………………………………………………………………………"

#运用aosp clang补丁
echo "运用aosp clang补丁"
#python3 $PW/toolchain-utils/llvm_tools/patch_manager.py --svn_version $svn_version --patch_metadata_file $PW/llvm_android/patches/PATCHES.json --filesdir_path $PW/llvm_android/patches --src_path $PW/llvm-project --use_src_head --failure_mode fail

python3 $PW/toolchain-utils/llvm_tools/patch_manager.py --svn_version $svn_version --patch_metadata_file $PW/llvm_android/patches/PATCHES.json --src_path $PW/llvm-project  

echo "……………………………………………………………………………………………………………………………………………………………………………………"


cd $PW/llvm-project
mkdir build
cd build
#或者使用tc-build https://github.com/ClangBuiltLinux/tc-build来编译获得更标准的clang
#使用ninja编译clang
#cmake -G Ninja \
        #-DCMAKE_BUILD_TYPE=Release \
       # -DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" \
       # -DLLVM_TARGETS_TO_BUILD="AArch64;ARM" \
      #  -DLLVM_BUILD_TESTS=OFF \
     #   -DLLVM_ENABLE_WARNINGS=OFF \
       # -DCMAKE_INSTALL_PREFIX=$install_path ../llvm
#ninja -j6
#ninja install

#使用make编译clang
cmake -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="AArch64;ARM" -DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" -DLLVM_ENABLE_WARNINGS=OFF -DLLVM_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$install_path ../llvm && make -j6 && make install

cd $PW/llvm-project && rm -rf build

#编译binutils（非必要的叫老的clang需要android来，而且请注意binutil一直都为2.27，在本机编译时注意系统gcc版本，一般单独在ubuntu-14.04编译，以确保binutils兼容性）以个好办法是,比如clang-r416183b在Ubuntu 16.04编译安装后，然后呢打包clang-r416183b,并复制到ubuntu-14.04,然后编译binutils,安装路径一样，这样在编译后就可无需设置binutils 路径，更方便于安卓内核编译。然后呢可拿到ubuntu-16.04以上的系统使用。
#cd $PW/binutils
#export TARGET=aarch64-linux-android
#export TARGET=aarch64-linux-gnu
#mkdir build-binutils && cd build-binutils && ../binutils/configure --prefix=$GCC --target=$TARGET --disable-multilib --enable-gold --disable-werror --disable-nls --with-pkgversion="Pdx Binutils" --disable-gdb --with-sysroot --disable-docs --enable-fix-cortex-a53-835769 --enable-plugins && make -j8 && make install 

#cd $PW/binutils
#rm -rf build-binutils
#export TARGET=arm-linux-androideabi
#export TARGET=arm-linux-gnueabi
#mkdir build-binutils && cd build-binutils && ../binutils/configure --prefix=$GCC --target=$TARGET --disable-multilib --enable-gold --disable-werror --disable-nls --with-pkgversion="Pdx Binutils" --disable-gdb --with-sysroot --disable-docs --enable-fix-cortex-a53-835769 --enable-plugins && make -j8 && make install

#cd $PW/binutils && rm -rf build-binutils

#打包
cd $GITHUB_WORKSPACE/kernel_workspace
#tar -I pixz -cf $CV.tar.xz $CV
XZ_OPT="-9" tar --warning=no-file-changed -cJf $CV.tar.xz $CV











