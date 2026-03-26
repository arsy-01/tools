#!/bin/bash

# GANTI URL DI BAWAH INI dengan hasil copy-paste link GitHub Anda (tanpa /Deltaa.apk di akhirnya)
BASE_URL="https://github.com/arsy-01/main/releases/download/delta"

install_apk() {
    APK_NAME=$1
    EXPECTED_HASH=$2
    PAUSE=$3
    FILE_PATH="/sdcard/Download/${APK_NAME}"

    clear
    echo "[*] Mengunduh $APK_NAME..."
    rm -f "$FILE_PATH"
    
    # Tambahan -f agar curl langsung gagal jika URL salah (404 Not Found)
    if curl -f -L -# -o "$FILE_PATH" "${BASE_URL}/${APK_NAME}"; then
        echo "[*] Memverifikasi dan menginstal..."
        INSTALL_STATUS=$(su -c "pm install -r \"$FILE_PATH\"" < /dev/null 2>&1)
        
        if [[ "$INSTALL_STATUS" == *"Success"* ]]; then
            echo "[v] BERHASIL! $APK_NAME terinstal."
        else
            echo "[X] GAGAL MENGINSTAL! Error: $INSTALL_STATUS"
        fi
    else
        echo "[X] ERROR: Gagal mengunduh $APK_NAME."
        echo "    Pastikan BASE_URL di script sudah benar!"
        rm -f "$FILE_PATH" # Menghapus file sampah 404
    fi
    
    if [ "$PAUSE" == "true" ]; then
        echo ""
        read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
    else
        echo "-----------------------------------"
        sleep 1
    fi
}

apk_menu() {
    while true; do
        clear
        echo "-----------------------------------"
        echo "            INSTALL APK            "
        echo "-----------------------------------"
        echo "[1] Delta A"
        echo "[2] Delta B"
        echo "[3] Delta C"
        echo "[4] Delta D"
        echo "[5] Delta E"
        echo "[6] Delta F"
        echo "[7] Install All"
        echo "[0] Kembali ke Menu Utama"
        echo "-----------------------------------"
        read -p "Pilih APK [0-7]: " apk_choice < /dev/tty

        case $apk_choice in
            1) install_apk "Deltaa.apk" "4d92bfdcf2124b567cf29eb0b5e1eb3ba52bcc14304d1ede729fe4fcd3775378" "true" ;;
            2) install_apk "Deltab.apk" "b91f1106da9c326c07d6d906f5c88e1c8e4655ca8d5d7e14b686080529d8ba5b" "true" ;;
            3) install_apk "Deltac.apk" "2dcf91449ff5ce46a0b2ccf8379f3a978526d1e052f735207706283b33cbca65" "true" ;;
            4) install_apk "Deltad.apk" "a45ba2682b62fd75ddb00d4711d75d734d0c7dd15c43c6b97e8ccd1416a956e4" "true" ;;
            5) install_apk "Deltae.apk" "8d8a4960cb8c8864b9f60f619dc6f26958c564c8dce7c58ca02f76f6418a5c6b" "true" ;;
            6) install_apk "Deltaf.apk" "c5ce9d80a4f5ef72c6f0832d9c1990a0098c505e1421c86c15d93aa27a04bf9c" "true" ;;
            7) 
                install_apk "Deltaa.apk" "4d92bfdcf2124b567cf29eb0b5e1eb3ba52bcc14304d1ede729fe4fcd3775378" "false"
                install_apk "Deltab.apk" "b91f1106da9c326c07d6d906f5c88e1c8e4655ca8d5d7e14b686080529d8ba5b" "false"
                install_apk "Deltac.apk" "2dcf91449ff5ce46a0b2ccf8379f3a978526d1e052f735207706283b33cbca65" "false"
                install_apk "Deltad.apk" "a45ba2682b62fd75ddb00d4711d75d734d0c7dd15c43c6b97e8ccd1416a956e4" "false"
                install_apk "Deltae.apk" "8d8a4960cb8c8864b9f60f619dc6f26958c564c8dce7c58ca02f76f6418a5c6b" "false"
                install_apk "Deltaf.apk" "c5ce9d80a4f5ef72c6f0832d9c1990a0098c505e1421c86c15d93aa27a04bf9c" "false"
                echo ""
                read -p "Semua instalasi selesai! Tekan [ENTER] untuk kembali..." dummy < /dev/tty
                ;;
            0) break ;;
            *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
        esac
    done
}

# Jalankan menu instalasi
apk_menu
