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

	apt-get install -y linux-headers-$(uname -r) build-essential perl dkms

	VBOX_VERSION="$(cat /home/${SSH_USER}/.vbox_version)"
	mount -o loop "/home/${SSH_USER}/VBoxGuestAdditions_${VBOX_VERSION}.iso" /mnt
	retCode=0
	sh /mnt/VBoxLinuxAdditions.run --nox11 || retCode=$?
	if [ ${retCode} -eq 1 ]; then
		printf -- 'VirtualBox Guest Additions installation failed\n' >&2
		exit 1
	fi
	umount /mnt
	rm -fv "/home/${SSH_USER}/VBoxGuestAdditions_${VBOX_VERSION}.iso"
	rm -fv "/home/${SSH_USER}/.vbox_version"

	printf -- '- VirtualBox Guest Additions version %s\n' "${VBOX_VERSION}" > /tmp/guest-additions-version.txt
fi
