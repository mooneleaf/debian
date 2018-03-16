#!/bin/sh -eu

if [ "${PACKER_BUILDER_TYPE}" = "vmware-iso" ]; then

	openVmTools="$(apt-cache policy open-vm-tools | grep Installed | cut -f 3 -d ':')"

	printf "==> %s\n" "Installing Open VM Tools"
	printf "Package: open-vm-tools open-vm-tools-dkms open-vm-tools-dev open-vm-tools-desktop\nPin: release a=%s\nPin-Priority: 500\n\n" "$(lsb_release -sc)-updates" "$(lsb_release -sc)-backports" > /etc/apt/preferences.d/open-vm-tools
	apt-get -y install open-vm-tools

	if dpkg --compare-versions "${openVmTools}" lt "10"; then
		printf "%s\n" open-vm-dkms open-vm-tools-dkms | xargs -n 1 apt-cache --generate pkgnames | xargs apt-get -y install
	fi

	printf "%s\n" "${openVmTools}" > /tmp/guest-additions-version.txt

	mkdir /mnt/hgfs
fi
