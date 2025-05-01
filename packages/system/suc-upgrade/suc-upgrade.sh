#!/bin/bash
set -x -e
HOST_DIR="${HOST_DIR:-/host}"
SUC_VERSION="0.0.0"

echo "SUC_VERSION: $SUC_VERSION"

if [ "$FORCE" != "true" ]; then
    if [ -f "/etc/kairos-release" ]; then
      # shellcheck disable=SC1091
      UPDATE_VERSION=$(source /etc/kairos-release && echo "KAIROS_VERSION=${KAIROS_VERSION};KAIROS_SOFTWARE_VERSION=${KAIROS_SOFTWARE_VERSION}")
    else
      # shellcheck disable=SC1091
      UPDATE_VERSION=$(source /etc/os-release && echo "KAIROS_VERSION=${KAIROS_VERSION};KAIROS_SOFTWARE_VERSION=${KAIROS_SOFTWARE_VERSION}")
    fi

    if [ -f "${HOST_DIR}/etc/kairos-release" ]; then
      # shellcheck disable=SC1091
      CURRENT_VERSION=$(source "${HOST_DIR}"/etc/kairos-release && echo "KAIROS_VERSION=${KAIROS_VERSION};KAIROS_SOFTWARE_VERSION=${KAIROS_SOFTWARE_VERSION}")
    else
      # shellcheck disable=SC1091
      CURRENT_VERSION=$(source "${HOST_DIR}"/etc/os-release && echo "KAIROS_VERSION=${KAIROS_VERSION};KAIROS_SOFTWARE_VERSION=${KAIROS_SOFTWARE_VERSION}")
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
