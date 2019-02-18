#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"

if [ "${PACKER_BUILDER_TYPE}" = "parallels-iso" ]; then
	printf "==> %s\n" "Installing Parallels tools"

	if [ -s /home/${SSH_USER}/prl-tools-manual.iso ]; then
		mount -o loop /home/${SSH_USER}/prl-tools-manual.iso /mnt
	else
		mount -o loop /home/${SSH_USER}/prl-tools-lin.iso /mnt
	fi

	/mnt/install --install-unattended-with-deps
	umount /mnt
	printf -- "- Parallels Tools version %s\n" "$(prltoolsd  -V | cut -f 3 -d " ")" > /tmp/guest-additions-version.txt
	rm -fv /home/${SSH_USER}/prl-tools-lin.iso /home/${SSH_USER}/prl-tools-manual.iso /home/${SSH_USER}/.prlctl_version
fi

