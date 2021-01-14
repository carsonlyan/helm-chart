#!/bin/bash
shopt -s extglob

if [ -d /home-init/root/etc ]; then
    echo 'remove etc from local volume (except user info)'
    cd /home-init/root/etc
    rm -fr !("passwd"|"group"|"shadow")

    echo 'copy etc from image to local volume (except user info)'
    cd /etc
    cp -fr !("passwd"|"group"|"shadow") /home-init/root/etc
else
    echo 'copy etc from image'
    cp -fr /home/* /home-init
    mkdir -p /home-init/root/etc
    cp -fr /etc /home-init/root
fi
