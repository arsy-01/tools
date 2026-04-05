#!/bin/bash

# Konfigurasi Repository Utama Anda
REPO="arsy-01/tools"

install_apk() {
    APK_NAME=$1
    PAUSE=$2
    DOWNLOAD_URL=$3
    FILE_PATH="/sdcard/Download/${APK_NAME}"

    echo "[*] Mengunduh $APK_NAME..."
    rm -f "$FILE_PATH"
    
    if curl -f -L -# -o "$FILE_PATH" "$DOWNLOAD_URL"; then
        echo "[*] Memverifikasi dan menginstal..."
        INSTALL_STATUS=$(su -c "pm install -r \"$FILE_PATH\"" < /dev/null 2>&1)
        
        if [[ "$INSTALL_STATUS" == *"Success"* ]]; then
            echo "[v] BERHASIL! $APK_NAME terinstal."
        else
            echo "[X] GAGAL MENGINSTAL! Error: $INSTALL_STATUS"
        fi
    else
        echo "[X] ERROR: Gagal mengunduh $APK_NAME."
        rm -f "$FILE_PATH"
    fi
    
    if [ "$PAUSE" == "true" ]; then
        echo ""
        read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
    else
        echo "-----------------------------------"
        sleep 1
    fi
}

# --- FUNGSI TINGKAT 2: MEMBACA ISI FILE DALAM FOLDER ---
menu_apk_list() {
    local TAG=$1
    
    clear
    echo "-----------------------------------"
    echo "    MEMUAT DATA DARI FOLDER '$TAG' "
    echo "-----------------------------------"
    
    API_URL="https://api.github.com/repos/$REPO/releases/tags/$TAG"
    local API_RESPONSE=$(curl -s "$API_URL")
    
    if [[ "$API_RESPONSE" == *"Not Found"* ]]; then
        echo "[!] Folder '$TAG' tidak ditemukan atau kosong!"
        sleep 2
        return
    fi

    mapfile -t APK_NAMES < <(echo "$API_RESPONSE" | grep -o '"name": "[^"]*\.apk"' | cut -d'"' -f4 | sort)
    mapfile -t APK_URLS < <(echo "$API_RESPONSE" | grep -o '"browser_download_url": "[^"]*\.apk"' | cut -d'"' -f4 | sort)
    
    local COUNT=${#APK_NAMES[@]}
    
    if [ "$COUNT" -eq 0 ]; then
        echo "[!] Tidak ada file .apk yang ditemukan di folder '$TAG'"
        sleep 2
        return
    fi

    while true; do
        clear
        echo "-----------------------------------"
        echo "     INSTALL APK (Folder: $TAG)    "
        echo "-----------------------------------"
        for (( i=0; i<COUNT; i++ )); do
            echo "[$((i+1))] ${APK_NAMES[$i]}"
        done
        echo "-----------------------------------"
        echo "* Ketik rentang angka (Misal: 1-4) untuk instal multiple"
        echo "-----------------------------------"
        echo "[A] Install Semua (1-$COUNT)"
        echo "[0] Kembali ke Pilih Folder"
        echo "-----------------------------------"
        read -p "Pilihan Anda: " choice < /dev/tty

        if [[ "$choice" == "0" ]]; then
            break
        elif [[ "${choice,,}" == "a" ]]; then
            for (( i=0; i<COUNT; i++ )); do
                install_apk "${APK_NAMES[$i]}" "false" "${APK_URLS[$i]}"
            done
            echo ""
            read -p "Semua instalasi selesai! Tekan [ENTER]..." dummy < /dev/tty
        elif [[ "$choice" =~ ^[0-9]+-[0-9]+$ ]]; then
            start=${choice%-*}
            end=${choice#*-}
            if [ "$start" -ge 1 ] && [ "$end" -le "$COUNT" ] && [ "$start" -le "$end" ]; then
                for (( i=start-1; i<=end-1; i++ )); do
                    install_apk "${APK_NAMES[$i]}" "false" "${APK_URLS[$i]}"
                done
                echo ""
                read -p "Instalasi rentang ($start-$end) selesai! Tekan [ENTER]..." dummy < /dev/tty
            else
                echo "[!] Rentang tidak valid!"; sleep 1
            fi
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$COUNT" ]; then
            idx=$((choice-1))
            install_apk "${APK_NAMES[$idx]}" "true" "${APK_URLS[$idx]}"
        else
            echo "[!] Pilihan tidak dikenali!"; sleep 1
        fi
    done
}

# --- FUNGSI TINGKAT 1: MEMBACA FOLDER (TAGS) DARI GITHUB ---
while true; do
    clear
    echo "-----------------------------------"
    echo "      PILIH SUMBER FOLDER APK      "
    echo "-----------------------------------"
    echo "[*] Sedang menscan folder di GitHub..."
    
    # Membaca daftar semua Release (Folder) yang ada di GitHub Anda
    RELEASES_API=$(curl -s "https://api.github.com/repos/$REPO/releases")
    mapfile -t FOLDER_TAGS < <(echo "$RELEASES_API" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
    
    TOTAL_FOLDERS=${#FOLDER_TAGS[@]}
    
    if [ "$TOTAL_FOLDERS" -eq 0 ]; then
        echo "[!] Tidak ada satupun folder/rilis ditemukan di GitHub Anda!"
        read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
        break
    fi

    clear
    echo "-----------------------------------"
    echo "      PILIH SUMBER FOLDER APK      "
    echo "-----------------------------------"
    echo " Ditemukan $TOTAL_FOLDERS Folder Otomatis:"
    echo "-----------------------------------"
    for (( i=0; i<TOTAL_FOLDERS; i++ )); do
        echo "[$((i+1))] Folder: ${FOLDER_TAGS[$i]}"
    done
    echo "-----------------------------------"
    echo "[0] Kembali ke Menu Utama"
    echo "-----------------------------------"
    
    read -p "Pilih Folder [0-$TOTAL_FOLDERS]: " folder_choice < /dev/tty

    if [[ "$folder_choice" == "0" ]]; then
        break
    elif [[ "$folder_choice" =~ ^[0-9]+$ ]] && [ "$folder_choice" -ge 1 ] && [ "$folder_choice" -le "$TOTAL_FOLDERS" ]; then
        idx=$((folder_choice-1))
        SELECTED_FOLDER="${FOLDER_TAGS[$idx]}"
        menu_apk_list "$SELECTED_FOLDER"
    else
        echo "[!] Pilihan tidak valid"; sleep 1
    fi
done
