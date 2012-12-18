#!/bin/bash -x
# script for creating a filesystem image for Fedora's Aarch64 port
# Copyright 2012 John Dulaney jdulaney@fedoraproject.org
# Licensed under the GPLv3+
# Dependencies:  qemu

# Set image size
  imgsize=8G

# Create image
  qemu-img create rootfs.img $imgsize

# Add partitions to the image, a 50 MB DOS bootable partition for
# uboot, and the rest will be for /
  parted rootfs.img mklabel msdos
  parted rootfs.img mkpart primary fat16 1 50
  parted rootfs.img mkpart primary ext3 50 $imgsize
  parted rootfs.img set 1 boot on

# Mount the image in /tmp
  mkdir /tmp/ext3
  mkdir /tmp/vfat

  sudo kpartx -a -v rootfs.img

  sudo mkfs.vfat /dev/mapper/loop0p1
  sudo mkfs.ext3 /dev/mapper/loop0p2

  sudo mount /dev/mapper/loop0p1 /tmp/vfat
  sudo mount /dev/mapper/loop0p2 /tmp/ext3

# Put uboot into the vfat partition for booting
  wget http://fedorapeople.org/groups/armv8/u-boot.bin
  sudo cp u-boot.bin /tmp/vfat
  sudo sync
  sudo umount /tmp/vfat

# Copy file system into image
  cd rootfs
  sudo sh -c "find . -print | cpio -pdumv /tmp/ext3"

# Unmount the image.
  sudo sync
  sudo umount /tmp/ext3

  echo 'Completed.'
