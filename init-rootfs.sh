#!/bin/sh
#
#   This script needs to be run before booting the rootfs as an
#   NFS root.  It also needs to be run as root, and it has to be
#   run in the rootfs.
#

if [ ! -d dj ]
then
        echo "? you are probably not cd'd to the top of your rootfs"
        exit 1
fi

if [ "$(id -u)" != "0" ]
then
        echo "? you must run this as root"
        exit 1
fi

#-- make all of our needed directories
for ii in dev proc sys tmp var/lock var/log var/tmp
do
        [ ! -d $ii ] && mkdir -p $ii
done

for ii in tmp var/lock var/log var/tmp
do
        chmod 1777 $ii
done

#-- do all the required mknods
cd dev

[ ! -c null ] && mknod null c   1 3
[ ! -c zero ] && mknod zero c   1 5
[ ! -c tty ] && mknod tty c   5 0
[ ! -c console ] && mknod console c   5 1
[ ! -b sda ] && mknod sda b   8 0
[ ! -b sda1 ] && mknod sda1 b   8 1
[ ! -b sda2 ] && mknod sda2 b   8 2
[ ! -b sda3 ] && mknod sda3 b   8 3
[ ! -b sda4 ] && mknod sda4 b   8 4
[ ! -b mmcblk0 ] && mknod mmcblk0 b 179 0
[ ! -b mmcblk0p1 ] && mknod mmcblk0p1 b 179 1
[ ! -b mmcblk0p2 ] && mknod mmcblk0p2 b 179 2
[ ! -b mmcblk0p3 ] && mknod mmcblk0p3 b 179 3
[ ! -b mmcblk0p4 ] && mknod mmcblk0p4 b 179 4
[ ! -c tty00 ] && mknod tty00 c 253 0
[ ! -c tty01 ] && mknod tty01 c 253 1
[ ! -c tty02 ] && mknod tty02 c 253 2
[ ! -c tty03 ] && mknod tty03 c 253 3
[ ! -c tty2 ] && mknod tty2 c 4 2
[ ! -c tty3 ] && mknod tty3 c 4 3
[ ! -c tty4 ] && mknod tty4 c 4 4
[ ! -c ttyS0 ] && mknod ttyS0 c 4 64
[ ! -c ttyS1 ] && mknod ttyS1 c 4 65
[ ! -c ttyS2 ] && mknod ttyS2 c 4 66
[ ! -c ttyS3 ] && mknod ttyS3 c 4 67

chmod a+rw null zero

#-- all done
exit 0

