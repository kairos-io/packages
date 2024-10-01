#!/bin/bash
set -x -e
HOST_DIR="${HOST_DIR:-/host}"

if [ "$FORCE" != "true" ]; then
    if [ -f "/etc/kairos-release" ]; then
      UPDATE_VERSION=$(source /etc/kairos-release && echo "${KAIROS_VERSION}")
    else
      UPDATE_VERSION=$(source /etc/os-release && echo "${KAIROS_VERSION}")
    fi

    if [ -f "/etc/kairos-release" ]; then
      CURRENT_VERSION=$(source "${HOST_DIR}"/etc/kairos-release && echo "${KAIROS_VERSION}")
    else
      CURRENT_VERSION=$(source "${HOST_DIR}"/etc/os-release && echo "${KAIROS_VERSION}")
    fi

    if [ "$CURRENT_VERSION" == "$UPDATE_VERSION" ]; then
      echo Update to date
      echo "Current version: ${CURRENT_VERSION}"
      echo "Update version: ${UPDATE_VERSION}"
      exit 0
    fi
fi

mount --rbind "${HOST_DIR}"/dev /dev
mount --rbind "${HOST_DIR}"/run /run
kairos-agent upgrade --source dir:/
nsenter -i -m -t 1 -- reboot
exit 1
