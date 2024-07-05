#!/bin/sh

# Script Name: sync_cfg.sh
# Script Path: <git_root>/sync_cfg.sh
# Description: Sync system configuration files to <git_root>/<system>/

# Copyright 2024 Ray Adams
# SPDX-Licence-Identifier: BSD-3-Clause

# Version: 2.0.1

# Obtain the path for <git_root>
working_dir="$(git rev-parse --show-toplevel)"

# Colors
green='\033[0;32m'
red='\033[0;31m'
nc='\033[0m'

sync() {
    # Directories

    ## chrony
    mkdir -p "${working_dir}/${system}/chrony/"
    echo "${green}Syncing /etc/chrony for ${system}.${nc}"
    rsync -qru --delete \
        --exclude ".*" \
        "${system}:/etc/chrony/" \
        "${working_dir}/${system}/chrony/" || { echo "${red}Syncing /etc/chrony for ${system} failed.${nc}"; exit 1; }

    ## conf.d
    mkdir -p "${working_dir}/${system}/conf.d/"
    echo "${green}Syncing conf.d configuration for ${system}.${nc}"
    rsync -qu \
        "${system}:/etc/conf.d/hostname" \
        "${system}:/etc/conf.d/keymaps" \
        "${system}:/etc/conf.d/net" \
        "${working_dir}/${system}/conf.d/" || { echo "${red}Syncing conf.d configuration for ${system} failed.${nc}"; exit 1; }

    if [ "${system}" = "kotori" ]; then
        rsync -qu \
        "${system}:/etc/conf.d/syncthing" \
        "${working_dir}/${system}/conf.d/" || { echo "${red}Syncing syncthing configuration for ${system} failed.${nc}"; exit 1; }
    fi

    ## libvirt
    if [ "${system}" = "kotori" ]; then
        mkdir -p "${working_dir}/${system}/libvirt/"
        echo "${green}Syncing libvirt configuration for ${system}.${nc}"
        rsync -qu \
            "${system}:/etc/libvirt/libvirtd.conf" \
            "${working_dir}/${system}/libvirt/" || { echo "${red}Syncing libvirt configuration for ${system} failed.${nc}"; exit 1; }
    fi

    ## modules-load.d
    mkdir -p "${working_dir}/${system}/modules-load.d/"
    echo "${green}Syncing /etc/modules-load.d for ${system}.${nc}"
    rsync -qru --delete \
        "${system}:/etc/modules-load.d/" \
        "${working_dir}/${system}/modules-load.d/" || { echo "${red}Syncing modules-load.d configuration for ${system} failed.${nc}"; exit 1; }

    ## pam.d
    mkdir -p "${working_dir}/${system}/pam.d/"
    echo "${green}Syncing pam.d configuration for ${system}.${nc}"
    rsync -qu \
        "${system}:/etc/pam.d/doas" \
        "${system}:/etc/pam.d/su" \
        "${system}:/etc/pam.d/system-local-login" \
        "${working_dir}/${system}/pam.d/" || { echo "${red}Syncing pam.d configuration for ${system} failed.${nc}"; exit 1; }

    ## Portage

    ### Sync subdirectories, files within them (excluding "dot" files), and do not delete certain files.
    mkdir -p "${working_dir}/${system}/portage/savedconfig/"
    echo "${green}Syncing /etc/portage for ${system}.${nc}"
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
        "${working_dir}/${system}/portage/" || { echo "${red}Syncing /etc/portage for ${system} failed.${nc}"; exit 1; }

    ### Sync the files excluded before.
    rsync -qu \
        "${system}:/etc/portage/make.conf" \
        "${system}:/etc/portage/package.unmask" \
        "${system}:/etc/portage/repos.conf" \
        "${working_dir}/${system}/portage/" || { echo "${red}Syncing /etc/portage for ${system} failed.${nc}"; exit 1; }

    ### linux-firmware.
    echo "${green}Syncing linux-firmware configuration for ${system}.${nc}"
    rsync -qu \
        "${system}:/etc/portage/savedconfig/sys-kernel/linux-firmware" \
        "${working_dir}/${system}/portage/savedconfig/sys-kernel/" || { echo "${red}Syncing linux-firmware configuration for ${system} failed.${nc}"; exit 1; }

    ## stubby
    mkdir -p "${working_dir}/${system}/stubby/"
    echo "${green}Syncing /etc/stubby for ${system}.${nc}"
    rsync -qru --delete \
        --exclude ".*" \
        "${system}:/etc/stubby/" \
        "${working_dir}/${system}/stubby/" || { echo "${red}Syncing /etc/stubby for ${system} failed.${nc}"; exit 1; }

    ## zsh
    mkdir -p "${working_dir}/${system}/zsh/"
    echo "${green}Syncing /etc/zsh/zshenv for ${system}.${nc}"
    rsync -qu \
        "${system}:/etc/zsh/zshenv" \
        "${working_dir}/${system}/zsh/" || { echo "${red}Syncing /etc/zsh/zshenv for ${system} failed.${nc}"; exit 1; }

    # Files

    # doas.conf
    echo "${green}Syncing /etc/doas.conf for ${system}.${nc}"
    rsync -qu \
        "${system}:/etc/doas.conf" \
        "${working_dir}/${system}/" || { echo "${red}Syncing /etc/doas.conf for ${system} failed.${nc}"; exit 1; }

    # environment
    echo "${green}Syncing /etc/environment for ${system}.${nc}"
    rsync -qu \
        "${system}:/etc/environment" \
        "${working_dir}/${system}/" || { echo "${red}Syncing /etc/environment for ${system} failed.${nc}"; exit 1; }

    # hostname
    echo "${green}Syncing /etc/hostname for ${system}.${nc}"
    rsync -qu \
        "${system}:/etc/hostname" \
        "${working_dir}/${system}/" || { echo "${red}Syncing /etc/hostname for ${system} failed.${nc}"; exit 1; }

    # resolv.conf.head
    echo "${green}Syncing /etc/resolv.conf.head for ${system}.${nc}"
    rsync -qu \
        "${system}:/etc/resolv.conf.head" \
        "${working_dir}/${system}/" || { echo "${red}Syncing /etc/resolv.conf.head for ${system} failed.${nc}"; exit 1; }

    # systctl.conf
    echo "${green}Syncing /etc/sysctl.conf for ${system}.${nc}"
    rsync -qu \
        "${system}:/etc/sysctl.conf" \
        "${working_dir}/${system}/" || { echo "${red}Syncing /etc/sysctl.conf for ${system} failed.${nc}"; exit 1; }
}

case ${1} in
    kotori)
        system="kotori"
        sync
    ;;

    gentoo-glibc-llvm)
        system="gentoo-glibc-llvm"
        sync
    ;;

    *)
        echo "Invalid option: \"${1}\""
        echo "Correct Usuage: ${0} [SYSTEM]"
        echo "Available systems: gentoo-glibc-llvm, kotori"
    ;;
esac
