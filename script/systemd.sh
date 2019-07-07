#!/bin/sh -eu

if dpkg-query -W -f='${Status}' systemd 2>/dev/null | cut -f 3 -d ' ' | grep -q '^installed$'; then
	printf -- '==> %s\n' 'Installing PAM module for systemd to prevent Vagrant/SSH hangs'
	apt-get -y install libpam-systemd
fi
