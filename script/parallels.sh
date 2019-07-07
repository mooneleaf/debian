#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"


if [ "${PACKER_BUILDER_TYPE}" = 'parallels-iso' ]; then
	case "$(printf "%s" "${GUEST_TOOLS:-}" | tr '[:upper:]' '[:lower:]')" in
		true|yes|on|1)
			printf -- '==> Installing Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
		;;

		(*)
			printf -- '==> Skipping Guest Tools install for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- '- Parallels Tools not installed' > /tmp/guest-additions-version.txt
			exit 0
		;;
	esac

	if [ -s /home/${SSH_USER}/prl-tools-manual.iso ]; then
		mount -o loop /home/${SSH_USER}/prl-tools-manual.iso /mnt
	else
		mount -o loop /home/${SSH_USER}/prl-tools-lin.iso /mnt
	fi

	/mnt/install --install-unattended-with-deps
	umount /mnt
	printf -- '- Parallels Tools version %s\n' "$(prltoolsd  -V | cut -f 3 -d ' ')" > /tmp/guest-additions-version.txt
	rm -fv /home/${SSH_USER}/prl-tools-lin.iso /home/${SSH_USER}/prl-tools-manual.iso /home/${SSH_USER}/.prlctl_version
fi

