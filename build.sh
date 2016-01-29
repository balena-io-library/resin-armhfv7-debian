#!/bin/bash

set -o errexit

dir=$(mktemp --tmpdir=/var/tmp -d)
	
mkdir -p $dir/rootfs/usr/bin
cp qemu-arm-static $dir/rootfs/usr/bin
chmod +x $dir/rootfs/usr/bin/qemu-arm-static
	
./mkimage.sh -t $REPO:$SUITE --dir=$dir debootstrap --foreign --variant=minbase --arch=armhf --include=sudo $SUITE $MIRROR
