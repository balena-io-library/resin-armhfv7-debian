#!/bin/bash

# This script based on mkimage-debootstap: https://github.com/docker/docker/blob/master/contrib/mkimage-debootstrap.sh

set -e
suite='wheezy'

variant='minbase'
include='iproute,iputils-ping'

target="/debianArmBase"
mirror="ftp://ftp.debian.org/debian/"
arch='armhf'

mkdir -p "$target"
qemu-debootstrap --verbose --arch="$arch" --variant="$variant" --include="$include" "$suite" "$target" "$mirror"
#debootstrap --verbose --arch="$arch" --variant="$variant" --include="$include" "$suite" "$target" "$mirror"

# Copy qemu-arm-static to image, qemu-arm-static from package qemu-user-static_1.1.2+dfsg-6a+deb7u6_amd64
cp qemu-arm-static "$target/usr/bin/"

cd "$target"
# prevent init scripts from running during install/update
#  policy-rc.d (for most scripts)
echo $'#!/bin/sh\nexit 101' | tee usr/sbin/policy-rc.d > /dev/null
chmod +x usr/sbin/policy-rc.d
#  initctl (for some pesky upstart scripts)
chroot . dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true sbin/initctl

# Cleaning up the image

if strings usr/bin/dpkg | grep -q unsafe-io; then
		# while we're at it, apt is unnecessarily slow inside containers
		#  this forces dpkg not to call sync() after package extraction and speeds up install
		#    the benefit is huge on spinning disks, and the penalty is nonexistent on SSD or decent server virtualization
		echo 'force-unsafe-io' | sudo tee etc/dpkg/dpkg.cfg.d/02apt-speedup > /dev/null
		# we have this wrapped up in an "if" because the "force-unsafe-io"
		# option was added in dpkg 1.15.8.6
		# (see http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=584254#82),
		# and ubuntu lucid/10.04 only has 1.15.5.6
fi
	{
		# we want to effectively run "apt-get clean" after every install to keep images small (see output of "apt-get clean -s" for context)
		aptGetClean='"rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true";'
		echo "DPkg::Post-Invoke { ${aptGetClean} };"
		echo "APT::Update::Post-Invoke { ${aptGetClean} };"
		echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";'
	} | sudo tee etc/apt/apt.conf.d/no-cache > /dev/null

# and remove the translations, too
echo 'Acquire::Languages "none";' | sudo tee etc/apt/apt.conf.d/no-languages > /dev/null

echo "deb http://ftp.debian.org/debian wheezy main" > "$target/etc/apt/sources.list"
echo "deb http://ftp.debian.org/debian wheezy-updates main" >> "$target/etc/apt/sources.list"
echo "deb http://security.debian.org/ wheezy/updates main" >> "$target/etc/apt/sources.list"

chroot . apt-get clean
# chroot . apt-get update
# chroot . apt-get dist-upgrade -y
# chroot . apt-get clean
# chroot . rm -rf /var/lib/apt/lists/

chroot . find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true
chroot . find /usr/share/doc -empty|xargs rmdir || true
chroot . find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en'|xargs rm -r

chroot . rm -f /var/cache/apt/*.bin
chroot . rm -rf /usr/share/man /usr/share/groff /usr/share/info /usr/share/lintian /usr/share/linda /var/cache/man

# clean up image
# apt-get autoremove -y
# rm -rf /var/lib/{apt,dkpg,cache,log}/
