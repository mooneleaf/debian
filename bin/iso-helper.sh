#!/bin/sh -eu

iso_helper() {

	local target="$1"
	local prereq="$2"
	local basefile="$3"

	get_json_value() {
		local query="${1}"
		jq --raw-output --slurpfile override "${prereq}"  ".variables * \$override[] | . as \$vars | ${query}" "${basefile}"
	}
	sum_value() {
		get_json_value .iso_checksum
	}

	sum_type() {
		get_json_value .iso_checksum_type | sed 's/sha//'
	}

	check_sum() {
		echo "Checking Hash of ${target}"
		echo "$(sum_value)  ${target}" | shasum -a "$(sum_type)" -c >/dev/null 2>&1
	}

	aria2c_download() {
		local url="$1"

		which aria2c > /dev/null
		echo "Downloading using aria2"

		aria2c --auto-file-renaming=false --summary-interval 0 --optimize-concurrent-downloads --file-allocation none --max-connection-per-server 5 --console-log-level warn --dir "$(dirname "${target}")" --out "$(basename "${target}")" --checksum "sha-$(sum_type)=$(sum_value)" "${url}"
	}

	curl_download() {
		local url="$1"
		which curl > /dev/null
		echo "Downloading using cURL"
		curl --fail --location --progress-bar --output "${target}" "${url}"
	}


	fetch_iso() {
		local isoURL="$(get_json_value '.iso_url')"

		echo "Downloading ${isoURL}"

		aria2c_download "${isoURL}" || curl_download "${isoURL}"
	}

	touch_iso() {
		touch "${target}"
	}


	if check_sum; then
		touch_iso
	else
		fetch_iso
	fi

}

iso_helper "$@"



