#!/bin/bash -eux

echo "==> Recording box generation date"
date > /etc/vagrant_box_build_date

echo "==> Customizing message of the day"
mkdir -p /etc/update-motd.d
motd_original_release_file=/etc/update-motd.d/00-original-release
printf "#!/bin/sh -eu\n" > ${motd_original_release_file}
printf 'echo "%-20s %s (%s)"\n' 'Vagrant box name:' "$VM_NAME" "$PACKER_BUILDER_TYPE" >> ${motd_original_release_file}
printf 'echo "%-20s %s"\n' "Build date:" "$(date +%Y-%m-%d)" >> ${motd_original_release_file}
printf 'echo "%-20s %s"\n' "Build Release:" "$(lsb_release -sd)" >> ${motd_original_release_file}

motd_current_version_file=/etc/update-motd.d/01-current-version
printf "#!/bin/sh -eu\n" > ${motd_current_version_file}
printf 'echo "%-20s %s"\n' "Current Release:" "\$(lsb_release -sd)" >> ${motd_current_version_file}


chmod +x ${motd_original_release_file} ${motd_current_version_file}
