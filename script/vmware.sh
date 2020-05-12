#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"

if [ "${PACKER_BUILDER_TYPE}" = 'vmware-iso' ]; then
	case "$(printf -- '%s' "${GUEST_TOOLS:-}" | tr '[:upper:]' '[:lower:]')" in
		true|yes|on|1)
			printf -- '==> Installing Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
		;;

		(*)
			printf -- '==> Skipping Guest Tools install for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- '- VMWare Tools not installed' > /tmp/guest-additions-version.txt
			exit 0
		;;
	esac


	case "$(printf -- '%s' "${GUEST_TOOLS_DISTRO:-}" | tr '[:upper:]' '[:lower:]')" in
		(*vmware*)
			printf -- '==> Installing Distro Provided Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- 'Package: open-vm-tools open-vm-tools-dkms open-vm-tools-dev open-vm-tools-desktop\nPin: release a=%s\nPin-Priority: 500\n\n' "$(lsb_release -sc)-updates" "$(lsb_release -sc)-backports" > /etc/apt/preferences.d/open-vm-tools
			apt-get -y install open-vm-tools

			openVmTools="$(apt-cache policy open-vm-tools | grep Installed | cut -f 3 -d ':')"

			if dpkg --compare-versions "${openVmTools}" lt 10; then
				printf -- '%s\n' "linux-headers-$(uname -r)" open-vm-dkms open-vm-tools-dkms | xargs -n 1 apt-cache --generate pkgnames | xargs apt-get -y install
			fi

			printf -- '- Open VM Tools (VMWare) version %s\n' "$(vmtoolsd -v | cut -d ' ' -f 5)" > /tmp/guest-additions-version.txt
			mkdir -p /mnt/hgfs
		;;
	esac

	if ! command -v vmware-toolbox-cmd > /dev/null; then
		printf -- '==> Installing Hypervisor Provided Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
		mkdir -p /mnt/tools
		if [ -f "/home/${SSH_USER}/tools-manual/vmware-tools-lin.iso" ]; then
			mount -o loop,ro "/home/${SSH_USER}/tools-manual/vmware-tools-lin.iso" /mnt/tools
		else
			mount -o loop,ro "/home/${SSH_USER}/vmware-tools-lin.iso" /mnt/tools
		fi

		toolsPath="$(find /mnt -name "VMwareTools-*.tar.gz")"
		majorVersion="$(printf "%s" "${toolsPath}" | cut -f2 -d'-' | cut -d '.' -f 1)"

		tar zxf "${toolsPath}" -C /tmp/
		if [ "${majorVersion}" -lt "10" ]; then
			/tmp/vmware-tools-distrib/vmware-install.pl -d
		else
			/tmp/vmware-tools-distrib/vmware-install.pl --force-install
		fi

		umount /mnt/tools
		rmdir /mnt/tools
		printf -- '- VMWare Tools version %s\n' "$(vmware-toolbox-cmd -v | cut -d ' ' -f 1)" > /tmp/guest-additions-version.txt
	fi

	rm -fvr "/home/${SSH_USER}/tools-manual/" "/home/${SSH_USER}/vmware-tools-lin.iso" "/tmp/vmware-tools-distrib/"

fi
