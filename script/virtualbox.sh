#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"

if [ "${PACKER_BUILDER_TYPE}" = 'virtualbox-iso' ]; then
	case "$(printf -- '%s' "${GUEST_TOOLS:-}" | tr '[:upper:]' '[:lower:]')" in
		true|yes|on|1)
			printf -- '==> Installing Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
		;;

		(*)
			printf -- '==> Skipping Guest Tools install for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- '- VirtualBox Guest Additions not installed' > /tmp/guest-additions-version.txt
			exit 0
		;;
	esac

	case "$(printf -- '%s' "${GUEST_TOOLS_DISTRO:-}" | tr '[:upper:]' '[:lower:]')" in
		true|yes|on|1)
			printf -- 'Package: virtualbox-guest-utils virtualbox-guest-dkms\nPin: release a=%s\nPin-Priority: 500\n\n' "$(lsb_release -sc)-updates" "$(lsb_release -sc)-backports" > /etc/apt/preferences.d/virtualbox-additions
			apt-get -y install virtualbox-guest-utils virtualbox-guest-dkms
		;;

		*)
			apt-get install -y linux-headers-$(uname -r) build-essential perl dkms
			mkdir -p /mnt/tools
			if [ -f "/home/${SSH_USER}/tools-manual/VBoxGuestAdditions.iso" ]; then
				mount -o loop "/home/${SSH_USER}/tools-manual/VBoxGuestAdditions.iso" /mnt/tools
			else
				mount -o loop "/home/${SSH_USER}/VBoxGuestAdditions.iso" /mnt/tools
			fi

			retCode=0
			sh /mnt/tools/VBoxLinuxAdditions.run --nox11 || retCode=$?
			if [ ${retCode} -eq 1 ]; then
				printf -- 'VirtualBox Guest Additions installation failed\n' >&2
				exit 1
			fi
			umount /mnt/tools
			rmdir /mnt/tools

		;;
	esac

	printf -- '- VirtualBox Guest Additions version %s\n' "$(VBoxControl -v)" > /tmp/guest-additions-version.txt
	rm -frv "/home/${SSH_USER}/VBoxGuestAdditions.iso" /home/${SSH_USER}/tools-manual/ "/home/${SSH_USER}/.vbox_version"
fi
