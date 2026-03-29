#!/bin/bash

# GANTI URL DI BAWAH INI dengan hasil copy-paste link GitHub Anda (tanpa /Deltaa.apk di akhirnya)
BASE_URL="https://github.com/arsy-01/tools/releases/download/delta"

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
            1) install_apk "Deltaa.apk" "0f5a04747ec49f789baa0808ce9a0fc2ea63557050e86fa83133b467d4b8f8a0" "true" ;;
            2) install_apk "Deltab.apk" "4f2f9f67d951713b062ac517e6c2a5227b518325b596678163a3b7461147ad47" "true" ;;
            3) install_apk "Deltac.apk" "f2ca4ed01813ee8471a3da9b374fd1785ce3d48096e0b7f808449e719711157c" "true" ;;
            4) install_apk "Deltad.apk" "1eb5f19dfc571a181ea371ac6189d641c16152484a0638cfa12dbbe63b68032e" "true" ;;
            5) install_apk "Deltae.apk" "327577f20548f0164ae3366fd866e487026ee137f6f83802589473ff57b61afc" "true" ;;
            6) install_apk "Deltaf.apk" "2fb6d00c2973ee28e432fc315d6e8da45f55ac1f91fa599aa94114d50a110bf0" "true" ;;
            7) 
                install_apk "Deltaa.apk" "0f5a04747ec49f789baa0808ce9a0fc2ea63557050e86fa83133b467d4b8f8a0" "false"
                install_apk "Deltab.apk" "4f2f9f67d951713b062ac517e6c2a5227b518325b596678163a3b7461147ad47" "false"
                install_apk "Deltac.apk" "f2ca4ed01813ee8471a3da9b374fd1785ce3d48096e0b7f808449e719711157c" "false"
                install_apk "Deltad.apk" "1eb5f19dfc571a181ea371ac6189d641c16152484a0638cfa12dbbe63b68032e" "false"
                install_apk "Deltae.apk" "327577f20548f0164ae3366fd866e487026ee137f6f83802589473ff57b61afc" "false"
                install_apk "Deltaf.apk" "2fb6d00c2973ee28e432fc315d6e8da45f55ac1f91fa599aa94114d50a110bf0" "false"
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
