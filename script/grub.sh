#!/bin/sh -eu
printf -- '==> %s\n' 'Removing grub timeout'

if [ -f /etc/default/grub ]; then
	sed -i -E -e s/GRUB_TIMEOUT=.+/GRUB_TIMEOUT=0/ /etc/default/grub
	update-grub
fi
