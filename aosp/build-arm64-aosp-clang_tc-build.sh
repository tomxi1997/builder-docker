#!/bin/bash
#以clang-r416183b为例
#以下的请查看#https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/android-msm-redbull-4.19-android14/clang-r416183b/manifest_7284624.xml，填写

#一下是最新版本的clang-r547379
#https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/main/clang-r547379
#更个提交清单如下 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/main/clang-r547379/manifest_13065274.xml
llvm_project_version=4c603efb0cca074e9238af8b4106c30add4418f6

binutils_version=

toolchain_utils_version=c9cb1157f1f9cc5cd081941ba83c8d63657160d0

llvm_android_version=207c6bec0197283db14f4ab1b52c4f062aaa050e
#svn值，请查看$PW/llvm_android/patches/PATCHES.json，按情况写
svn_version=450784


#clang安装路径
CV=clang-r450784e


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
#git clone https://android.googlesource.com/toolchain/binutils
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
python3 $PW/toolchain-utils/llvm_tools/patch_manager.py --svn_version $svn_version --patch_metadata_file $PW/llvm_android/patches/PATCHES.json --filesdir_path $PW/llvm_android/patches --src_path $PW/llvm-project --use_src_head --failure_mode fail

#python3 $PW/toolchain-utils/llvm_tools/patch_manager.py --svn_version $svn_version --patch_metadata_file $PW/llvm_android/patches/PATCHES.json --src_path $PW/llvm-project  

echo "……………………………………………………………………………………………………………………………………………………………………………………"



cd $GITHUB_WORKSPACE/kernel_workspace
#git clone https://github.com/ClangBuiltLinux/tc-build
wget https://github.com/tomxi1997/Toolchain-for-aarch64-hosts/releases/download/v15/tc-build.tar.xz
tar xf tc-build.tar.xz
cd tc-build
mkdir src
mv $PW/llvm-project  $GITHUB_WORKSPACE/kernel_workspace/tc-build/src/
chmod +x *.py

echo "……………………………………………………………………………………………………………………………………………………………………………………"
echo "……………………………………………………………………………………………开始编译……………………………………………………………………………………"
#./build-llvm.py -t AArch64 ARM --vendor-string "Aosp Arm" -i $install_path --no-update
./build-llvm.py --clang-vendor "Aosp Arm" \
	--targets "ARM;AArch64" \
 --no-update \
 --install-folder $install_path 


 
 #打包
cd $GITHUB_WORKSPACE/kernel_workspace
#tar -I pixz -cf $CV.tar.xz $CV
XZ_OPT="-9" tar --warning=no-file-changed -cJf $CV.tar.xz $CV











