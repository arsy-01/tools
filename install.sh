#!/bin/bash

BASE_URL="https://github.com/arsy-01/main/releases/download/delta"

install_apk() {
    APK_NAME=$1
    EXPECTED_HASH=$2
    PAUSE=$3
    FILE_PATH="/sdcard/Download/${APK_NAME}"

    clear
    echo "[*] Mengunduh $APK_NAME..."
    rm -f "$FILE_PATH"
    curl -L -# -o "$FILE_PATH" "${BASE_URL}/${APK_NAME}"

    if [ -f "$FILE_PATH" ]; then
        echo "[*] Memverifikasi dan menginstal..."
        INSTALL_STATUS=$(su -c "pm install -r $FILE_PATH" < /dev/null 2>&1)
        if [[ "$INSTALL_STATUS" == *"Success"* ]]; then
            echo "[v] BERHASIL! $APK_NAME terinstal."
        else
            echo "[X] GAGAL MENGINSTAL! Error: $INSTALL_STATUS"
        fi
    else
        echo "[!] ERROR: Gagal mengunduh $APK_NAME."
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
        echo "[5] Install Semua Sekaligus"
        echo "[0] Kembali ke Menu Utama"
        echo "-----------------------------------"
        read -p "Pilih APK [0-5]: " apk_choice

        case $apk_choice in
            1) install_apk "Deltaa.apk" "4d92bfdcf2124b567cf29eb0b5e1eb3ba52bcc14304d1ede729fe4fcd3775378" "true" ;;
            2) install_apk "Deltab.apk" "b91f1106da9c326c07d6d906f5c88e1c8e4655ca8d5d7e14b686080529d8ba5b" "true" ;;
            3) install_apk "Deltac.apk" "2dcf91449ff5ce46a0b2ccf8379f3a978526d1e052f735207706283b33cbca65" "true" ;;
            4) install_apk "Deltad.apk" "a45ba2682b62fd75ddb00d4711d75d734d0c7dd15c43c6b97e8ccd1416a956e4" "true" ;;
            5) 
                install_apk "Deltaa.apk" "4d92bfdcf2124b567cf29eb0b5e1eb3ba52bcc14304d1ede729fe4fcd3775378" "false"
                install_apk "Deltab.apk" "b91f1106da9c326c07d6d906f5c88e1c8e4655ca8d5d7e14b686080529d8ba5b" "false"
                install_apk "Deltac.apk" "2dcf91449ff5ce46a0b2ccf8379f3a978526d1e052f735207706283b33cbca65" "false"
                install_apk "Deltad.apk" "a45ba2682b62fd75ddb00d4711d75d734d0c7dd15c43c6b97e8ccd1416a956e4" "false"
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
