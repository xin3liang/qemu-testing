#!/bin/bash

set -x

VCPU=1
MEMORY=512
MAC=$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)))

sudo qemu-system-aarch64 -smp $VCPU -m $MEMORY -cpu host -M virt,gic_version=3 -nographic \
-kernel Image  -initrd initrd.gz -device virtio-net-device,netdev=net0,mac=$MAC \
-netdev tap,id=net0,script=qemu-ifup.sh,downscript=qemu-ifdown.sh -enable-kvm

set +x
