#!/bin/bash

# Konfigurasi URL Repositori Baru
REPO_URL="https://raw.githubusercontent.com/arsy-01/tools/main"
CONFIG_FILE="/sdcard/Download/.vip_link_arsy.txt"

input_vip_link() {
    clear
    echo "-----------------------------------"
    echo "       INPUT VIP SERVER LINK       "
    echo "-----------------------------------"
    local current_link=""
    if [ -f "$CONFIG_FILE" ]; then current_link=$(cat "$CONFIG_FILE"); fi
    echo "Link Saat Ini: ${current_link:-[KOSONG]}"
    echo ""
    read -p "Masukkan Link VIP baru: " new_link
    
    if [ -n "$new_link" ]; then
        echo "$new_link" > "$CONFIG_FILE"
        echo "[+] Link VIP berhasil disimpan!"
    else
        echo "[!] Input kosong, dibatalkan."
    fi
    sleep 2
}

while true; do
    clear
    echo "-----------------------------------"
    echo "             MENU UTAMA            "
    echo "-----------------------------------"
    echo "[1] Install APK"
    echo "[2] Input Link VIP Server"
    echo "[3] Setup Layout & Jalankan Aplikasi"
    echo "[0] Keluar"
    echo "-----------------------------------"
    
    STATUS_LINK="[KOSONG]"
    if [ -f "$CONFIG_FILE" ]; then STATUS_LINK="[Terisi]"; fi
    echo "* Status VIP Link: $STATUS_LINK"
    echo "-----------------------------------"
    
    read -p "Pilih menu [0-3]: " main_choice

    case $main_choice in
        1) curl -sL "$REPO_URL/install.sh" | bash ;;
        2) input_vip_link ;;
        3) curl -sL "$REPO_URL/engine.sh" | bash ;;
        0) clear; exit 0 ;;
        *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
    esac
done
