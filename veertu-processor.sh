#!/bin/sh -eu

if [ "${PACKER_BUILDER_TYPE}" != "null" ]; then
	exit
fi

tmp="$(mktemp -d)"

VeertuManage shutdown "${VM_NAME}"
VeertuManage export --fmt vmz "${VM_NAME}" "$tmp/box.vmz"
echo '{"provider": "veertu"}' > "$tmp/metadata.json"
cp tpl/vagrantfile-koalephant.rb "$tmp/Vagrantfile"
tar -cvzf "box/veertu/${VM_NAME}-${VM_VERSION}.box" -C "${tmp}" box.vmz metadata.json Vagrantfile
rm -rf $tmp

