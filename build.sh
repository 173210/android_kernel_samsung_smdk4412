#!/bin/bash

KERNEL_DIR=$PWD
#TOOLCHAIN_DIR=$HOME/toolchain

if [ -n "$1" ]; then
	OBJ_DIR=$1
else
	OBJ_DIR=$HOME
fi
if [ ! -e $OBJ_DIR ]; then
	mkdir $OBJ_DIR
fi
if [ ! -e $OBJ_DIR/zips ]; then
	mkdir $OBJ_DIR/zips
fi
if [ -e $OBJ_DIR/zip_tmp ]; then
	rm $OBJ_DIR/zip_tmp/*
else
	mkdir $OBJ_DIR/zip_tmp
fi

if [ -n "$2" ]; then
	DEFCONFIG=$2
else
	DEFCONFIG=kernel_defconfig
fi

if [ -e $TOOLCHAIN_DIR ]; then
	PATH=$PATH:$TOOLCHAIN_DIR/bin
fi
if [ ! -n $CROSS_COMPILE ]; then
	CROSS_COMPILE=arm-gnueabi-
fi

cp $KERNEL_DIR/arch/arm/configs/$DEFCONFIG $KERNEL_DIR/.config
make -j3
find -name '*.ko' -exec cp -av {} $KERNEL_DIR/usr/galaxys2_initramfs_files/modules \;
chmod 644 $KERNEL_DIR/usr/galaxys2_initramfs_files/modules/*
${CROSS_COMPILE}strip --strip-unneeded $KERNEL_DIR/usr/galaxys2_initramfs_files/modules/*

make -j3 zImage CONFIG_INITRAMFS_SOURCE="$KERNEL_DIR/usr/initramfs/cwm.list"
cp $KERNEL_DIR/arch/arm/boot/zImage $OBJ_DIR/zip_tmp
CURRENTDATE=$(date +"%d-%m")
zip -jr $OBJ_DIR/zips/kk-kernel-$CURRENTDATE-CWM.zip $OBJ_DIR/zip_tmp

rm $OBJ_DIR/zip_tmp/*

make -j3 zImage CONFIG_INITRAMFS_SOURCE="$KERNEL_DIR/usr/initramfs/twrp.list"
cp $KERNEL_DIR/arch/arm/boot/zImage $OBJ_DIR/zip_tmp
CURRENTDATE=$(date +"%d-%m")
zip -jr $OBJ_DIR/zips/kk-kernel-$CURRENTDATE-TWRP.zip $OBJ_DIR/zip_tmp
