#!/bin/bash

LNVM_DEV=""
LNVM_DRIVE=""

QEMU=../qemu/x86_64-softmmu/qemu-system-x86_64

while getopts lq: OPT; do
	case "$OPT" in
		l)
			echo "LightNVM mode"
			LNVM_DEV="-device nvme,drive=lnvm,serial=deadbeef,id=lnvm,cmb_size_mb=32,lnum_pu=32,lws_min=12,lws_opt=24,lsec_size=4096,lsecs_per_chk=3072,lmw_cunits=192,ldebug=1,lstrict=1,meta=16,mc=3,lmetadata=lnvm/meta.qemu,lchunktable=lnvm/chunk.qemu \
				-drive file=/mnt/eval/nvme_block2,if=none,id=lnvm"
			;;
		q)
			QEMU=${OPTARG}
			;;
		\?)
			echo "Unknown option"
			exit 1
			;;
	esac
done

echo $QEMU

sudo ${QEMU} -m 8G -smp 12 -s \
-drive file=/home/javigon/development/virtual/images/ubuntu18.img,id=diskdrive,if=none \
-device ide-hd,drive=diskdrive \
-drive file=/mnt/eval/extradisk.raw,id=extradrive,format=raw,if=none \
-device ide-hd,drive=extradrive \
-device nvme,drive=mynvme,serial=deadbeef,id="nvme0" \
-drive file=/mnt/eval/nvme_block,if=none,id=mynvme \
-kernel "/home/javigon/linux/arch/x86_64/boot/bzImage" \
-append "console=ttyS0,kgdboc=ttyS1,115200 root=/dev/sda2" \
-device e1000,netdev=net1,mac=52:55:00:d1:55:01 \
-netdev tap,id=net1,ifname=tap0,script=no,downscript=no \
-device e1000,netdev=net0 \
-netdev user,id=net0,hostfwd=tcp::2022-:22 \
$LNVM_DEV \
-serial mon:stdio \
-cpu host \
-serial pty -nographic --enable-kvm -chardev socket,id=qmp,path=/tmp/test.qmp,server,nowait -mon chardev=qmp,mode=control
