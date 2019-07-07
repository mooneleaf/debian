#!/bin/sh -eu

if [ "${PACKER_BUILDER_TYPE}" = 'vmware-iso' ]; then
	case "$(printf -- '%s' "${GUEST_TOOLS:-}" | tr '[:upper:]' '[:lower:]')" in
		true|yes|on|1)
			printf -- '==> Installing Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
		;;

		(*)
			printf -- '==> Skipping Guest Tools install for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- '- Open VM Tools not installed' > /tmp/guest-additions-version.txt
			exit 0
		;;
	esac

	printf -- 'Package: open-vm-tools open-vm-tools-dkms open-vm-tools-dev open-vm-tools-desktop\nPin: release a=%s\nPin-Priority: 500\n\n' "$(lsb_release -sc)-updates" "$(lsb_release -sc)-backports" > /etc/apt/preferences.d/open-vm-tools
	apt-get -y install open-vm-tools

	openVmTools="$(apt-cache policy open-vm-tools | grep Installed | cut -f 3 -d ':')"

	if dpkg --compare-versions "${openVmTools}" lt 10; then
		printf -- '%s\n' "linux-headers-$(uname -r)" open-vm-dkms open-vm-tools-dkms | xargs -n 1 apt-cache --generate pkgnames | xargs apt-get -y install
	fi

	printf -- '- Open VM Tools version %s\n' "${openVmTools}" > /tmp/guest-additions-version.txt

	mkdir /mnt/hgfs
fi
