#!/bin/sh -eu

case "$(printf "%s" "${UPDATE:-}" | tr '[:upper:]' '[:lower:]')" in
	true|yes|on|1)
		printf "==> %s" "Updating list of repositories"
		apt-get -y update

		printf "==> %s" "Performing dist-upgrade (all packages and kernel)"
		apt-get -y dist-upgrade --force-yes
		printf "==> %s" "Rebooting"
		nohup shutdown --reboot now </dev/null >/dev/null 2>&1 &
	;;
esac


