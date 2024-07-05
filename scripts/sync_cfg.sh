#!/bin/sh

# Script Name: sync_cfg.sh
# Script Path: <git_root>/scripts/sync_cfg.sh
# Description: Sync system configuration files to <git_root>/system/<system>/

# Copyright 2024 Ray Adams
# SPDX-Licence-Identifier: BSD-3-Clause

# Version: 2.4.1

# Obtain the path for <git_root>
working_dir="$(git rev-parse --show-toplevel)"

# Colors
green='\033[0;32m'
red='\033[0;31m'
nc='\033[0m'

sync() {
    # Directories

    ## chrony
    mkdir -p "${working_dir}/system/${system}/chrony/"
    rsync -qru --delete \
        --exclude ".*" \
        "${system}:/etc/chrony/" \
        "${working_dir}/system/${system}/chrony/" || { echo "${red}Syncing /etc/chrony for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/chrony for ${system} successfully.${nc}"

    ## conf.d
    mkdir -p "${working_dir}/system/${system}/conf.d/"
    rsync -qu \
        "${system}:/etc/conf.d/hostname" \
        "${system}:/etc/conf.d/keymaps" \
        "${system}:/etc/conf.d/net" \
        "${working_dir}/system/${system}/conf.d/" || { echo "${red}Syncing conf.d configuration for ${system} failed.${nc}"; exit 1; }

    if [ "${system}" = "kotori" ]; then
        rsync -qu \
            "${system}:/etc/conf.d/syncthing" \
            "${working_dir}/system/${system}/conf.d/" || { echo "${red}Syncing syncthing configuration for ${system} failed.${nc}"; exit 1; }
    fi
    echo "${green}Synced conf.d configuration for ${system} successfully.${nc}"

    ## modules-load.d
    mkdir -p "${working_dir}/system/${system}/modules-load.d/"
    rsync -qru --delete \
        "${system}:/etc/modules-load.d/" \
        "${working_dir}/system/${system}/modules-load.d/" || { echo "${red}Syncing modules-load.d configuration for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/modules-load.d for ${system} successfully.${nc}"

    ## pam.d
    mkdir -p "${working_dir}/system/${system}/pam.d/"
    rsync -qu \
        "${system}:/etc/pam.d/doas" \
        "${system}:/etc/pam.d/su" \
        "${system}:/etc/pam.d/system-local-login" \
        "${working_dir}/system/${system}/pam.d/" || { echo "${red}Syncing pam.d configuration for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced pam.d configuration for ${system} successfully.${nc}"

    ## Portage

    ### Sync subdirectories, files within them (excluding "dot" files), and do not delete certain files.
    mkdir -p "${working_dir}/system/${system}/portage/"
    rsync -qru --delete \
        --exclude ".*" \
        --exclude "make.conf" \
        --exclude "package.unmask" \
        --exclude "repos.conf" \
        --exclude "savedconfig" \
        "${system}:/etc/portage/env" \
        "${system}:/etc/portage/package.env" \
        "${system}:/etc/portage/package.license" \
        "${system}:/etc/portage/package.mask" \
        "${system}:/etc/portage/package.use" \
        "${system}:/etc/portage/sets" \
        "${working_dir}/system/${system}/portage/" || { echo "${red}Syncing /etc/portage for ${system} failed.${nc}"; exit 1; }

    ### Sync the files excluded before.
    rsync -qu \
        "${system}:/etc/portage/make.conf" \
        "${system}:/etc/portage/package.unmask" \
        "${system}:/etc/portage/repos.conf" \
        "${working_dir}/system/${system}/portage/" || { echo "${red}Syncing /etc/portage for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/portage for ${system} successfully.${nc}"

    ## stubby
    mkdir -p "${working_dir}/system/${system}/stubby/"
    rsync -qru --delete \
        --exclude ".*" \
        "${system}:/etc/stubby/" \
        "${working_dir}/system/${system}/stubby/" || { echo "${red}Syncing /etc/stubby for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/stubby for ${system} successfully.${nc}"

    ## zsh
    mkdir -p "${working_dir}/system/${system}/zsh/"
    rsync -qu \
        "${system}:/etc/zsh/zshenv" \
        "${working_dir}/system/${system}/zsh/" || { echo "${red}Syncing /etc/zsh/zshenv for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/zsh/zshenv for ${system} successfully.${nc}"

    # Files

    ## doas.conf
    rsync -qu \
        "${system}:/etc/doas.conf" \
        "${working_dir}/system/${system}/" || { echo "${red}Syncing /etc/doas.conf for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/doas.conf for ${system} successfully.${nc}"

    ## environment
    rsync -qu \
        "${system}:/etc/environment" \
        "${working_dir}/system/${system}/" || { echo "${red}Syncing /etc/environment for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/environment for ${system} successfully.${nc}"

    ## hostname
    rsync -qu \
        "${system}:/etc/hostname" \
        "${working_dir}/system/${system}/" || { echo "${red}Syncing /etc/hostname for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/hostname for ${system} successfully.${nc}"

    ## resolv.conf.head
    rsync -qu \
        "${system}:/etc/resolv.conf.head" \
        "${working_dir}/system/${system}/" || { echo "${red}Syncing /etc/resolv.conf.head for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/resolv.conf.head for ${system} successfully.${nc}"

    ## systctl.conf
    rsync -qu \
        "${system}:/etc/sysctl.conf" \
        "${working_dir}/system/${system}/" || { echo "${red}Syncing /etc/sysctl.conf for ${system} failed.${nc}"; exit 1; }
    echo "${green}Synced /etc/sysctl.conf for ${system} successfully.${nc}"

    # System Specific

    ## dhcpcd.conf
    if [ "${system}" = "angelica" ]; then
        rsync -qu \
            "${system}:/etc/dhcpcd.conf" \
            "${working_dir}/system/${system}/" || { echo "${red}Syncing dhcpcd.conf for ${system} failed.${nc}"; exit 1; }
        echo "${green}Synced /etc/dhcpcd.conf successfully.${nc}"
    fi

    ## libvirt
    if [ "${system}" = "kotori" ]; then
        mkdir -p "${working_dir}/system/${system}/libvirt/"
        rsync -qu \
            "${system}:/etc/libvirt/libvirtd.conf" \
            "${working_dir}/system/${system}/libvirt/" || { echo "${red}Syncing libvirt configuration for ${system} failed.${nc}"; exit 1; }
        echo "${green}Synced libvirt configuration for ${system} successfully.${nc}"
    fi

    ## linux-firmware.
    if [ "${system}" != "angelica" ]; then
        mkdir -p "${working_dir}/system/${system}/portage/savedconfig/"
        rsync -qu \
            "${system}:/etc/portage/savedconfig/sys-kernel/linux-firmware" \
            "${working_dir}/system/${system}/portage/savedconfig/sys-kernel/" || { echo "${red}Syncing linux-firmware configuration for ${system} failed.${nc}"; exit 1; }
        echo "${green}Synced linux-firmware configuration for ${system} successfully.${nc}"
    fi
}

case ${1} in
    angelica)
        system="angelica"
        sync
    ;;

    kotori)
        system="kotori"
        sync
    ;;

    eleanore-compile)
        system="eleanore-compile"
        sync
    ;;

    *)
        echo "Invalid option: \"${1}\""
        echo "Correct Usuage: ${0} [SYSTEM]"
        echo "Available systems: angelica, eleanore-compile, kotori"
    ;;
esac
