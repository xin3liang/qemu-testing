#!/bin/bash -xe

#CDROM_IMG=~/work/estuary/submodules/build-ubuntu/out/release/master/ubuntu/mini.iso
CDROM_IMG=/mnt/result-WH-20180305-B19.iso
HDA_IMG=hda.img
MAC=$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)))

make_kvm_arg()
{
	echo "-smp 2 -m 1024 -cpu host -M virt,gic_version=3 -enable-kvm -nographic"
}

make_cdrom_arg()
{
        echo "-drive file=$1,id=cdrom,if=none,media=cdrom" \
             "-device virtio-scsi-device -device scsi-cd,drive=cdrom"
}

make_hda_arg()
{
        echo "-drive if=none,file=$1,id=hd0" \
             "-device virtio-blk-device,drive=hd0" \
	     "-pflash flash0.img -pflash flash1.img"
}

make_net_arg()
{
	echo "-device virtio-net-device,netdev=net0,mac=$MAC" \
	     "-netdev tap,id=net0,script=qemu-ifup.sh,downscript=qemu-ifdown.sh"
}

KVM_ARGS=`make_kvm_arg`
HDA_ARGS=`make_hda_arg $HDA_IMG`
NET_ARGS=`make_net_arg`
if [ $# -eq 1 ]; then
        case $1 in
            install)
                CDROM_ARGS=`make_cdrom_arg $CDROM_IMG`
            ;;
            *)
                CDROM_ARGS=""
            ;;
        esac
fi


sudo qemu-system-aarch64 $KVM_ARGS $HDA_ARGS $NET_ARGS $CDROM_ARGS

## **Note** disk gerneration
#$ dd if=/dev/zero of=flash0.img bs=1M count=0 seek=64
#$ dd if=/usr/share/qemu-efi/QEMU_EFI.fd of=flash0.img conv=notrunc
#$ dd if=/dev/zero of=flash1.img bs=1M count=0 seek=64
#$ dd if=/dev/zero of=hda.img bs=1G count=0 seek=10
