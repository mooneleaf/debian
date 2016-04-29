#!/bin/bash -eux

echo "==> Disk usage before minimization"
df -h

echo "==> Installed packages before cleanup"
dpkg --get-selections | grep -v deinstall

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg --list | awk '{ print $2 }' | grep 'linux-image-3.*-generic' | grep -v $(uname -r) | xargs apt-get -y purge
echo "==> Removing linux headers"
dpkg --list | awk '{ print $2 }' | grep linux-headers | xargs apt-get -y purge
echo "==> Removing linux source"
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge

echo "==> Removing development packages"
dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge
apt-get -y purge build-essential

echo "==> Removing X11 libraries"
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6
echo "==> Removing obsolete networking components"
apt-get -y purge ppp pppconfig pppoeconf
echo "==> Removing other oddities"
apt-get -y purge popularity-contest installation-report wireless-tools wpasupplicant

# Only remove ruby if not required by the CM
if ! [[ ${CM} == 'puppet' ]]; then
  echo "==> Removing default system Ruby"
  apt-get -y purge ruby ri doc libffi5
fi

echo "==> Removing default system Python"
apt-get -y purge python-dbus libnl1 python-smartpm python-twisted-core libiw30 python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl python-serial python-gobject python-pam python-openssl

# Clean up the apt cache
echo "==> Cleaning up the apt cache"
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean

echo "==> Removing APT files"
find /var/lib/apt -type f -delete
echo "==> Removing caches"
find /var/cache -type f -delete

echo "==> Disk usage after cleanup"
df -h
