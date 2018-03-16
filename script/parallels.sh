#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"

if [ "${PACKER_BUILDER_TYPE}" = "parallels-iso" ]; then
	printf "==> %s\n" "Installing Parallels tools"
	mount -o loop /home/${SSH_USER}/prl-tools-lin.iso /mnt
	/mnt/install --install-unattended-with-deps
	umount /mnt
	printf "%s\n" "$(cat /home/${SSH_USER}/.prlctl_version)" > /tmp/guest-additions-version.txt
	rm -rfv /home/${SSH_USER}/prl-tools-lin.iso
	rm -fv /home/${SSH_USER}/.prlctl_version
fi
