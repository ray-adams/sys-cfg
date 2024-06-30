#!/bin/sh

# Script Name: sync-portage.sh
# File Path: <git_root>/sync-scripts/sync-portage.sh
# Description: Sync portage configuration files to <git_root>.

# Copyright 2024 Ray Adams
# SPDX-Licence-Identifier: BSD-3-Clause

# Version: 1.1.0

# Obtain the path for <git_root>
working_dir="$(git rev-parse --show-toplevel)"

kotori() {
    # Sync subdirectories, files within them (excluding "dot" files), and do not
    # delete certain files.
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

    # Sync the files excluded before.
    rsync -uvh \
        "/etc/portage/make.conf" \
        "/etc/portage/package.unmask" \
        "/etc/portage/repos.conf" \
        "${working_dir}/kotori/portage/"

    # Sync linux-firmware.
    rsync -uvh \
        "/etc/portage/savedconfig/sys-kernel/linux-firmware" \
        "${working_dir}/kotori/portage/savedconfig/sys-kernel/"
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
