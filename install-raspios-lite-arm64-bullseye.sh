#!/bin/sh

set -x
set -e

TDEV=$1
RP_HOSTNAME=$2

test -b "$TDEV"
test -n "$RP_HOSTNAME"

PREF=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-04-07
NAME=2022-04-04-raspios-bullseye-arm64-lite
IMG=$NAME.img
CIMG=$IMG.xz

wget --continue $PREF/$CIMG
wget --continue $PREF/${CIMG}.sha256
sha256sum -c ${CIMG}.sha256
xz -cd $CIMG > $IMG
dd if=$IMG of=$TDEV bs=128M status=progress

MNTP1=$(mktemp -d)
MNTP2=$(mktemp -d)
RP_ETC=$MNTP2/etc
RP_RPI_TUNER=$RP_ETC/rpi-tuner

get_part()
{
	TDEV=$1
	PART=$2

	lsblk -l ${TDEV} | awk '{ print $6, $1 }' | grep ^part | awk '{ print $2; }' | head -n${PART} | tail -n1
}

PART1=/dev/$(get_part ${TDEV} 1)
PART2=/dev/$(get_part ${TDEV} 2)

mount ${PART1} $MNTP1

mount ${PART2} $MNTP2

mkdir -p $RP_RPI_TUNER

cp $MNTP1/config.txt $RP_RPI_TUNER

echo > $MNTP1/ssh

cp $0 $RP_RPI_TUNER/$(basename $0)
echo "$0 $@" > $RP_RPI_TUNER/install-cmdline

CID=/sys/block/$(basename ${TDEV})/device/cid
if [ -f "${CID}" ]; then
	cp ${CID} $RP_RPI_TUNER/cid
fi

( cd $RP_ETC && git init . )
( cd $RP_ETC && git add $(basename $RP_RPI_TUNER) )
( cd $RP_ETC && git commit -s -m "Initial commit" )

cp rpi-etc-gitignore $RP_ETC/.gitignore
( cd $RP_ETC && git add . )
( cd $RP_ETC && git commit -s -m "original $NAME etc state" )

echo "$RP_HOSTNAME" > $RP_ETC/hostname
( cd $RP_ETC && git commit -s -m "set hostname to $RP_HOSTNAME" hostname )
sed -i "s/^\(127.0.1.1\)\s\+.*$/\1\t$RP_HOSTNAME/" $RP_ETC/hosts

echo "enable_uart=1" >> $MNTP1/config.txt
cp $MNTP1/config.txt $RP_RPI_TUNER
( cd $RP_ETC && git commit -s -m "enable uart" $(basename $RP_RPI_TUNER) )

umount $MNTP1
umount $MNTP2

rmdir $MNTP1 $MNTP2
