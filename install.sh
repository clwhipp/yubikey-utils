#!/bin/bash

function install_ykbw(){
    echo "Installing ykbw ..."
    sudo cp ykbw /usr/bin
    sudo chown root:root /usr/bin/ykbw
    sudo chmod 755 /usr/bin/ykbw
}

function install_yksec(){
    echo "Installing yksec ..."
    sudo cp yksec /usr/bin
    sudo chown root:root /usr/bin/yksec
    sudo chmod 755 /usr/bin/yksec
}

function install_yubikey_luks(){
    echo "Installing Yubikey Luks ..."

    sudo cp ykluks.cfg /etc/ykluks.cfg
    sudo chown root:root /etc/ykluks.cfg
    sudo chmod 400 /etc/ykluks.cfg

    sudo cp yubikey-luks-enroll /usr/bin/yubikey-luks-enroll
    sudo chown root:root /usr/bin/yubikey-luks-enroll
    sudo chmod 755 /usr/bin/yubikey-luks-enroll

    sudo cp yubikey-luks-open /usr/bin/yubikey-luks-open
    sudo chown root:root /usr/bin/yubikey-luks-open
    sudo chmod 755 /usr/bin/yubikey-luks-open
}

install_ykbw
install_yksec
install_yubikey_luks

echo "Complete"

