#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"

if [ "${PACKER_BUILDER_TYPE}" = "vmware-iso" ]; then
    printf "==> %s" "Installing VMware Tools"
    apt-get install -y linux-headers-$(uname -r) build-essential perl

    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop "/home/${SSH_USER}/linux.iso" /mnt/cdrom

    VMWARE_TOOLS_PATH="$(find /mnt/cdrom -name "VMwareTools-*.tar.gz")"
    VMWARE_TOOLS_VERSION="$(printf "%s" "${VMWARE_TOOLS_PATH}" | cut -f2 -d'-')"
    VMWARE_TOOLS_BUILD="$(printf "%s" "${VMWARE_TOOLS_PATH}" | cut -f3 -d'-')"
    VMWARE_TOOLS_BUILD="$(basename "${VMWARE_TOOLS_BUILD}" .tar.gz)"
    printf "==> %s" "VMware Tools Path: ${VMWARE_TOOLS_PATH}"
    printf "==> %s" "VMware Tools Version: ${VMWARE_TOOLS_VERSION}"
    printf "==> %s" "VMWare Tools Build: ${VMWARE_TOOLS_BUILD}"

    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/
    VMWARE_TOOLS_MAJOR_VERSION="$(printf "%s" ${VMWARE_TOOLS_VERSION} | cut -d '.' -f 1)"
    if [ "${VMWARE_TOOLS_MAJOR_VERSION}" -lt "10" ]; then
        /tmp/vmware-tools-distrib/vmware-install.pl -d
    else
        /tmp/vmware-tools-distrib/vmware-install.pl --force-install
    fi

    rm -fv "/home/${SSH_USER}/linux.iso"
    umount /mnt/cdrom
    rmdir /mnt/cdrom
    rm -rfv /tmp/VMwareTools-*
fi
