#!/bin/bash

# Konfigurasi Repository (Tanpa perlu menulis base URL panjang)
REPO="arsy-01/tools"

install_apk() {
    APK_NAME=$1
    PAUSE=$2
    DOWNLOAD_URL=$3
    FILE_PATH="/sdcard/Download/${APK_NAME}"

    echo "[*] Mengunduh $APK_NAME..."
    rm -f "$FILE_PATH"
    
    # Download langsung menggunakan URL dari API GitHub
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

# --- FUNGSI CERDAS: MEMBACA FOLDER GITHUB SECARA OTOMATIS ---
menu_apk_list() {
    local TAG=$1
    local TAG_NAME=$2
    
    clear
    echo "-----------------------------------"
    echo "    MEMUAT DATA DARI GITHUB...     "
    echo "-----------------------------------"
    
    # 1. Menghubungi API GitHub untuk mengambil daftar isi folder (Release Tag)
    API_URL="https://api.github.com/repos/$REPO/releases/tags/$TAG"
    local API_RESPONSE=$(curl -s "$API_URL")
    
    # Cek apakah folder (tag) ada di GitHub
    if [[ "$API_RESPONSE" == *"Not Found"* ]]; then
        echo "[!] Folder '$TAG' tidak ditemukan di GitHub Anda!"
        sleep 2
        return
    fi

    # 2. Mengekstrak otomatis semua nama file yang berakhiran .apk
    mapfile -t APK_NAMES < <(echo "$API_RESPONSE" | grep -o '"name": "[^"]*\.apk"' | cut -d'"' -f4 | sort)
    # 3. Mengekstrak otomatis link download aslinya
    mapfile -t APK_URLS < <(echo "$API_RESPONSE" | grep -o '"browser_download_url": "[^"]*\.apk"' | cut -d'"' -f4 | sort)
    
    # Menghitung otomatis total APK yang ditemukan
    local COUNT=${#APK_NAMES[@]}
    
    if [ "$COUNT" -eq 0 ]; then
        echo "[!] Tidak ada file .apk yang ditemukan di folder '$TAG_NAME'"
        sleep 2
        return
    fi

    # Tampilkan Menu Isi Folder
    while true; do
        clear
        echo "-----------------------------------"
        echo "     INSTALL APK ($TAG_NAME)       "
        echo "-----------------------------------"
        echo " Ditemukan $COUNT aplikasi otomatis:"
        echo "-----------------------------------"
        for (( i=0; i<COUNT; i++ )); do
            # Menampilkan nama file persis seperti yang diupload di GitHub
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
            # Pilihan "A" -> Install Semua yang terdeteksi
            for (( i=0; i<COUNT; i++ )); do
                install_apk "${APK_NAMES[$i]}" "false" "${APK_URLS[$i]}"
            done
            echo ""
            read -p "Semua instalasi selesai! Tekan [ENTER]..." dummy < /dev/tty
            
        elif [[ "$choice" =~ ^[0-9]+-[0-9]+$ ]]; then
            # Pilihan Rentang (Contoh: 1-3)
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
            # Pilihan Satuan (Contoh: 2)
            idx=$((choice-1))
            install_apk "${APK_NAMES[$idx]}" "true" "${APK_URLS[$idx]}"
            
        else
            echo "[!] Pilihan tidak dikenali!"; sleep 1
        fi
    done
}

# --- MENU TINGKAT PERTAMA (PILIH FOLDER/TAG) ---
while true; do
    clear
    echo "-----------------------------------"
    echo "      PILIH SUMBER FOLDER APK      "
    echo "-----------------------------------"
    echo "[1] Delta Standard (Folder: delta)"
    echo "[2] Delta A10      (Folder: deltaA10)"
    echo "[0] Kembali ke Menu Utama"
    echo "-----------------------------------"
    read -p "Pilih Folder [0-2]: " folder_choice < /dev/tty

    case $folder_choice in
        1) menu_apk_list "delta" "Delta Standard" ;;
        2) menu_apk_list "deltaA10" "Delta A10" ;;
        0) break ;;
        *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
    esac
done
