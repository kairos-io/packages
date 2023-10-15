#!/bin/bash
# This module selects the proper network module to be used by dracut
# This helps it be more generic and work on all kairos flavors easily without having
# to specify the network module directly in our framework packages list

# called by dracut
check() {
    # always include this module
    return 0
}

# called by dracut
depends() {
    # Network module: selects underlying network module (conman, networkmanager, network-legacy, systemd-networkd)
    # network module needs to be installed for livenet module to work
    # network-legacy just uses bash scripts to setup the network
    # ubuntu-20 uses network
    # ubuntu-22 uses network+network-legacy
    # ubuntu-latest, debian, fedora,opensuse-*, almalinux, rockylinux uses network+network-legacy+systemd-networkd
    # Im guessing we need the network module in the initramfs in case we set the rd.neednet=1
    # but that only affects conman, networkmanager and network-legacy?

    # shellcheck disable=SC2144
    # add network-legacy module if it exists
    if [ -d "${dracutbasedir}"/modules.d/??network-legacy ]; then
        network_handler="network-legacy"
    fi

    echo "kernel-network-modules network $network_handler"
    return 0
}

# called by dracut
installkernel() {
    return 0
}

# called by dracut
install() {
    dracut_need_initqueue
}
