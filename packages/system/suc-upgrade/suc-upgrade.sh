#!/bin/bash
set -x -e
HOST_DIR="${HOST_DIR:-/host}"
SUC_VERSION="0.0.0"

echo "SUC_VERSION: $SUC_VERSION"

version_ge() {
    # Compare two semantic versions
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" = "$2" ]
}

# Get the update version from the release file
get_update_version() {
    local release_file="$1"
    # shellcheck disable=SC1090
    source "${release_file}"
    # If we are on 3.4.0 or higher
    if version_ge "$KAIROS_VERSION" "3.4.0"; then
        # if we dont have any provider, we just return the version
        if [ -z "$KAIROS_SOFTWARE_VERSION_PREFIX" ]; then
            echo "$KAIROS_VERSION"
        else
            # if we have a provider, we return the version with the provider + the version
            # Clean software version in case it has a leading v as we dont have that in the artifacts
            KAIROS_SOFTWARE_VERSION="${KAIROS_SOFTWARE_VERSION#v}"
            # Also replace any + with a - as we dont have that in the artifacts, not possible for oci artifacts
            KAIROS_SOFTWARE_VERSION="${KAIROS_SOFTWARE_VERSION//+/\-}"
            echo "${KAIROS_VERSION}-${KAIROS_SOFTWARE_VERSION_PREFIX}${KAIROS_SOFTWARE_VERSION}"
        fi
    else
        # if we are on a version lower than 3.4.0, we just return the version as before
        echo "$KAIROS_VERSION"
    fi
}

if [ "$FORCE" != "true" ]; then
    if [ -f "/etc/kairos-release" ]; then
      UPDATE_VERSION=$(get_update_version "/etc/kairos-release")
    else
      # shellcheck disable=SC1091
      UPDATE_VERSION=$(get_update_version "/etc/os-release")
    fi

    if [ -f "${HOST_DIR}/etc/kairos-release" ]; then
      # shellcheck disable=SC1091
      CURRENT_VERSION=$(get_update_version "${HOST_DIR}/etc/kairos-release")
    else
      # shellcheck disable=SC1091
      CURRENT_VERSION=$(get_update_version "${HOST_DIR}/etc/os-release")
    fi

    if [ "$CURRENT_VERSION" == "$UPDATE_VERSION" ]; then
      echo Up to date
      echo "Current version: ${CURRENT_VERSION}"
      echo "Update version: ${UPDATE_VERSION}"
      exit 0
    fi
fi

mount --rbind "$HOST_DIR"/dev /dev
mount --rbind "$HOST_DIR"/run /run

recovery_mode=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --recovery) recovery_mode=true;;
    esac
    shift
done
if [ "$recovery_mode" = true ]; then
    kairos-agent upgrade --recovery --source dir:/
    exit 0 # no need to reboot when upgrading recovery
else
    kairos-agent upgrade --source dir:/
    nsenter -i -m -t 1 -- reboot
    exit 1
fi
