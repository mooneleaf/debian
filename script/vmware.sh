#!/bin/sh -eu

if [ "${PACKER_BUILDER_TYPE}" = "vmware-iso" ]; then
    printf "==> %s\n" "Installing VMware Tools"
    apt-get install -y open-vm-tools;
    mkdir /mnt/hgfs;
fi
