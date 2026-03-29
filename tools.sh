#!/bin/bash

# Konfigurasi URL Repositori Baru
REPO_URL="https://raw.githubusercontent.com/arsy-01/tools/main"
CONFIG_FILE="/sdcard/Download/.vip_link_arsy.txt"

input_vip_link() {
    clear
    echo "-----------------------------------"
    echo "       INPUT PRIVATE SERVER        "
    echo "-----------------------------------"
    local current_link=""
    if [ -f "$CONFIG_FILE" ]; then current_link=$(cat "$CONFIG_FILE"); fi
    echo "Link Saat Ini: ${current_link:-[KOSONG]}"
    echo ""
    read -p "Masukkan Private Server Link: " new_link < /dev/tty
    
    if [ -n "$new_link" ]; then
        echo "$new_link" > "$CONFIG_FILE"
        echo "[+] Link berhasil disimpan!"
    else
        echo "[!] Input kosong, dibatalkan."
    fi
    sleep 2
}

input_delta_key() {
    clear
    echo "-----------------------------------"
    echo "          INPUT DELTA KEY          "
    echo "-----------------------------------"
    read -p "Masukkan Delta Key: " delta_key < /dev/tty

    if [ -n "$delta_key" ]; then
        echo "[*] Mencari folder Roblox..."
        BASE_DIR="/storage/emulated/0/Android/data"
        
        # Mencari folder Roblox langsung tanpa menggunakan 'su' (seperti script Kaeru)
        ROBLOX_DIRS=$(ls -d $BASE_DIR/com.roblox.clien* 2>/dev/null)
        
        if [ -z "$ROBLOX_DIRS" ]; then
            echo "[!] Tidak ada folder aplikasi Roblox yang terdeteksi!"
        else
            for dir in $ROBLOX_DIRS; do
                pkg_name=$(basename "$dir")
                echo " -> Menerapkan key ke $pkg_name..."
                
                TARGET_DIR="$dir/files/gloop/external/Internals/Cache"
                
                # Membuat folder dan menulis key langsung secara murni
                mkdir -p "$TARGET_DIR"
                printf "%s" "$delta_key" > "$TARGET_DIR/license"
                
                echo "    [v] Key berhasil disalin!"
            done
            echo ""
            echo "[+] Selesai! Delta Key telah diterapkan ke semua aplikasi."
        fi
    else
        echo "[!] Input kosong, dibatalkan."
    fi
    echo ""
    # Tombol enter dijamin aman
    read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
}

while true; do
    clear
    echo "-----------------------------------"
    echo "             MENU UTAMA            "
    echo "-----------------------------------"
    echo "[1] Install APK"
    echo "[2] Private Server Link"
    echo "[3] Setup  &  Run"
    echo "[4] Delta Key"
    echo "[0] Keluar"
    echo "-----------------------------------"
    
    STATUS_LINK="[KOSONG]"
    if [ -f "$CONFIG_FILE" ]; then STATUS_LINK="[Terisi]"; fi
    echo "* Status Private Link: $STATUS_LINK"
    echo "-----------------------------------"
    
    read -p "Pilih menu [0-4]: " main_choice < /dev/tty

    case $main_choice in
        1) curl -sL "$REPO_URL/install.sh" | bash ;;
        2) input_vip_link ;;
        3) curl -sL "$REPO_URL/engine.sh" | bash ;;
        4) input_delta_key ;;
        0) clear; exit 0 ;;
        *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
    esac
done
