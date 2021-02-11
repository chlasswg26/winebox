#!/usr/bin/env bash

# Bash script to install winbox on Linux (wine)
# Author: owl4ce
# License: GPL-3.0
# ----------------------------------------------
# https://github.com/owl4ce/winebox

R='\e[1;31m'
M='\e[1;35m'
C='\e[1;36m'
G='\e[1;32m'
N='\e[0m'

CHK_ARCH="$(lscpu | grep "Architecture" | awk -F'_' '{print $2}')"
winbox() { curl -L "https://mt.lv/winbox" -o $HOME/.winebox/winbox.exe; }
winbox64() { curl -L "https://mt.lv/winbox64" -o $HOME/.winebox/winbox64.exe; }

mkds() {
    [[ ! -e $HOME/.local/share/applications ]] && \
    mkdir -p $HOME/.local/share/applications && \
    touch $HOME/.local/share/applications/winebox.desktop && \
    chmod +x $HOME/.local/share/applications/winebox.desktop
}

dtwine() {
    if [[ -x "$(which "wine" 2> /dev/null)" ]]; then
        echo -e "${C}Detected Wine version: ${N}$(wine --version)"
    else
        echo -e "${R}Wine is not installed. ${N}Please install the wine first!" && exit 1
    fi
}

case $1 in
    -u) [[ -d $HOME/.winebox ]] && \
        rm -rv $HOME/.{winebox,local/share/applications/winebox.desktop} && \
        echo -e "${G}Winebox successfuly uninstalled."
    ;;
    *)  clear
        if [[ $EUID -ne 0 ]]; then    
            dtwine
            echo -n -e "${C}Detected OS architecture: "
            echo -e "${N}$CHK_ARCH-bit" && echo -e "${N}"
            [[ ! -e $HOME/.winebox ]] && mkdir -p $HOME/.winebox && \
            curl -sL "https://raw.githubusercontent.com/owl4ce/winebox/main/.winebox/winebox.png" -o $HOME/.winebox/winebox.png
            if [[ $CHK_ARCH = *"64"* ]]; then
                if [[ ! -f $HOME/.winebox/winbox64.exe ]]; then
                    echo -e "${C}Downloading Winbox ${M}(64-bit)${C}..." && echo -e "${N}"
                    winbox64
                else
                    echo -e "${G}Winbox already exists. ${R}Exiting.." && exit 1
                fi
                echo ""
                echo -n -e "${C}Creating desktop shortcut... "
                mkds
                echo "[Desktop Entry]
Comment=Run MikroTik Winbox over Wine (64-bit)
Terminal=false
Name=Winebox
Categories=Network;
Exec=bash -c \"wine64 $HOME/.winebox/winbox64.exe\"
Type=Application
Icon=$(echo $HOME)/.winebox/winebox.png" > $HOME/.local/share/applications/winebox.desktop
                sleep 1s && echo -e "${G}Winebox successfully installed!"
            else
                if [[ ! -f $HOME/.winebox/winbox.exe ]]; then
                    echo -e "${C}Downloading Winbox ${M}(32-bit)${C}..." && echo -e "${N}"
                    winbox
                else
                    echo -e "${G}Winbox already exists. ${R}Exiting.." && exit 1
                fi
                echo ""
                echo -n -e "${C}Creating desktop shortcut... "
                mkds
                echo "[Desktop Entry]
Comment=Run MikroTik Winbox over Wine (32-bit)
Terminal=false
Name=Winebox
Categories=Network;
Exec=bash -c \"wine $HOME/.winebox/winbox.exe\"
Type=Application
Icon=$(echo $HOME)/.winebox/winebox.png" > $HOME/.local/share/applications/winebox.desktop
                sleep 1s && echo -e "${G}Winebox successfully installed!"
            fi
        else
            echo -e "${R}Running as root is detected! Please run as regular user."
            exit 1
        fi
    ;;
esac
