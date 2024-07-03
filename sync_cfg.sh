#!/bin/sh

# Script Name: sync_cfg.sh
# Script Path: <git_root>/sync_cfg.sh
# Description: Sync system configuration files to <git_root>/<system>/

# Copyright 2024 Ray Adams
# SPDX-Licence-Identifier: BSD-3-Clause

# Version: 1.0.1

# Obtain the path for <git_root>
working_dir="$(git rev-parse --show-toplevel)"

kotori() {
    # Create directories if they do not exist
    mkdir -p "${working_dir}/kotori/chrony/"
    mkdir -p "${working_dir}/kotori/conf.d/"
    mkdir -p "${working_dir}/kotori/modules-load.d/"
    mkdir -p "${working_dir}/kotori/libvirt/"
    mkdir -p "${working_dir}/kotori/pam.d/"
    mkdir -p "${working_dir}/kotori/portage/savedconfig/"
    mkdir -p "${working_dir}/kotori/stubby/"
    mkdir -p "${working_dir}/kotori/zsh/"

    # chrony
    rsync -ruvh --delete \
        --exclude ".*" \
        "/etc/chrony/" \
        "${working_dir}/kotori/chrony/"

    # conf.d
    rsync -uvh \
        "/etc/conf.d/hostname" \
        "/etc/conf.d/keymaps" \
        "/etc/conf.d/net" \
        "/etc/conf.d/syncthing" \
        "${working_dir}/kotori/conf.d/"

    # libvirt
    rsync -uvh \
        "/etc/libvirt/libvirtd.conf" \
        "${working_dir}/kotori/libvirt/"

    # modules-load.d
    rsync -ruvh --delete \
        "/etc/modules-load.d/" \
        "${working_dir}/kotori/modules-load.d/"

    # pam.d
    rsync -uvh \
        "/etc/pam.d/doas" \
        "/etc/pam.d/su" \
        "/etc/pam.d/system-local-login" \
        "${working_dir}/kotori/pam.d/"

    # Portage

    ## Sync subdirectories, files within them (excluding "dot" files), and do not delete certain files.
    rsync -ruvh --delete \
        --exclude ".*" \
        --exclude "make.conf" \
        --exclude "package.unmask" \
        --exclude "repos.conf" \
        --exclude "savedconfig" \
        "/etc/portage/env" \
        "/etc/portage/package.env" \
        "/etc/portage/package.license" \
        "/etc/portage/package.mask" \
        "/etc/portage/package.use" \
        "/etc/portage/sets" \
        "${working_dir}/kotori/portage/"

    ## Sync the files excluded before.
    rsync -uvh \
        "/etc/portage/make.conf" \
        "/etc/portage/package.unmask" \
        "/etc/portage/repos.conf" \
        "${working_dir}/kotori/portage/"

    ## Sync linux-firmware.
    rsync -uvh \
        "/etc/portage/savedconfig/sys-kernel/linux-firmware" \
        "${working_dir}/kotori/portage/savedconfig/sys-kernel/"

    # stubby
    rsync -ruvh --delete \
        --exclude ".*" \
        "/etc/stubby/" \
        "${working_dir}/kotori/stubby/"

    # zsh
    rsync -uvh \
        "/etc/zsh/zshenv" \
        "${working_dir}/kotori/zsh/"

    # Misc configuration files
    rsync -uvh \
        "/etc/doas.conf" \
        "/etc/environment" \
        "/etc/hostname" \
        "/etc/resolv.conf.head" \
        "/etc/sysctl.conf" \
        "${working_dir}/kotori/"
}

case ${1} in
    kotori)
        kotori
    ;;

    *)
        echo "Invalid option: \"${1}\""
        echo "Correct Usuage: ${0} [SYSTEM]"
        echo "Available systems: kotori"
    ;;
esac
