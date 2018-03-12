#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"

if [ "${PACKER_BUILDER_TYPE}" = "virtualbox-iso" ]; then
    printf "==> %s\n" "Installing VirtualBox guest additions"
    apt-get install -y linux-headers-$(uname -r) build-essential perl
    apt-get install -y dkms

    VBOX_VERSION="$(cat /home/${SSH_USER}/.vbox_version)"
    mount -o loop "/home/${SSH_USER}/VBoxGuestAdditions_${VBOX_VERSION}.iso" /mnt
    sh /mnt/VBoxLinuxAdditions.run --nox11
    umount /mnt
    rm -fv "/home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso"
    rm -fv /home/vagrant/.vbox_version
fi
