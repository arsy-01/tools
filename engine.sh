#!/bin/bash

REPO_URL="https://raw.githubusercontent.com/arsy-01/tools/main"
LAYOUT_URL="$REPO_URL/layout.sh"
CONFIG_FILE="/sdcard/Download/.vip_link_arsy.txt"

drop_android_ram() {
    su -c 'am kill-all' > /dev/null 2>&1
    PACKAGES=$(get_roblox_packages)
    for pkg in $PACKAGES; do
        su -c "cmd activity send-trim-memory $pkg RUNNING_LOW" > /dev/null 2>&1
    done
}

get_roblox_packages() {
    su -c 'pm list packages' | grep -i 'roblox' | awk -F':' '{print $2}' | tr -d '\r'
}

execute_layout() {
    echo "[*] Mengeksekusi Setup Layout dari GitHub..."
    curl -sL "$LAYOUT_URL" | bash
    sleep 2
}

prepare_device_environment() {
    echo "[*] Memeriksa konfigurasi sistem Android..."
    FREEFORM_STATUS=$(su -c 'settings get global enable_freeform_support' | tr -d '\r')
    
    if [ "$FREEFORM_STATUS" != "1" ]; then
        echo "    [!] DEVICE BARU TERDETEKSI!"
        echo "    [*] Menyuntikkan konfigurasi Multi-Window (Freeform)..."
        su -c 'settings put global enable_freeform_support 1' > /dev/null 2>&1
        su -c 'settings put global force_resizable_activities 1' > /dev/null 2>&1
        echo "    --------------------------------------------------------"
        echo "    [!] PENGATURAN BERHASIL DITERAPKAN!"
        echo "    [!] Karena ini adalah device baru, Android MEWAJIBKAN RESTART."
        echo "    [!] Silakan REBOOT/RESTART Redfinger Anda sekarang."
        echo "    [!] Setelah menyala kembali, jalankan ulang script ini."
        echo "    --------------------------------------------------------"
        exit 0
    fi

    echo "    [*] Memaksa dan mengunci layar ke mode Landscape..."
    su -c 'settings put system accelerometer_rotation 0' > /dev/null 2>&1
    su -c 'settings put system user_rotation 1' > /dev/null 2>&1
    su -c 'am broadcast -a android.intent.action.CONFIGURATION_CHANGED' > /dev/null 2>&1
    sleep 3
}

deploy_lua_script() {
    echo "[*] Mempersiapkan injeksi file Lua ke Delta..."
    PACKAGES=$(get_roblox_packages)
    LUA_CONTENT='loadstring(game:HttpGet("https://raw.githubusercontent.com/arsy-01/tools/main/card.lua"))()'
    
    for pkg in $PACKAGES; do
        DIR_AUTOEXEC="/sdcard/Android/data/$pkg/files/gloop/external/Autoexecute"
        DIR_SCRIPTS="/sdcard/Android/data/$pkg/files/gloop/external/Scripts"
        
        echo " -> Memproses $pkg..."
        
        if su -c "[ -d \"$DIR_AUTOEXEC\" ]"; then
            su -c "echo '$LUA_CONTENT' > \"$DIR_AUTOEXEC/arsy_card.lua\""
            echo "    [v] Berhasil ditambahkan di Autoexecute"
        else
            echo "    [!] Folder Autoexecute belum ada"
        fi
        
        if su -c "[ -d \"$DIR_SCRIPTS\" ]"; then
            su -c "echo '$LUA_CONTENT' > \"$DIR_SCRIPTS/arsy_card.lua\""
            echo "    [v] Berhasil ditambahkan di Scripts"
        else
            echo "    [!] Folder Scripts belum ada"
        fi
    done
    sleep 2
}

run_layout_and_engine() {
    while true; do
        clear
        echo "-----------------------------------"
        echo "     SETUP LAYOUT & JALANKAN       "
        echo "-----------------------------------"
        echo "[1] Setup Layout (Normal Open untuk Login)"
        echo "[2] Jalankan Aplikasi (Auto VIP + Mode AFK)"
        echo "[0] Kembali ke Menu Utama"
        echo "-----------------------------------"
        read -p "Pilih menu [0-2]: " run_choice < /dev/tty

        case $run_choice in
            1)
                clear
                echo "[*] Memulai proses Buka Aplikasi & Setup Layout..."
                prepare_device_environment
                
                PACKAGES=$(get_roblox_packages)
                if [ -z "$PACKAGES" ]; then echo "[!] Tidak ada aplikasi Roblox yang terdeteksi!"; sleep 2; continue; fi

                echo "[*] Menghentikan semua instance agar fresh..."
                for pkg in $PACKAGES; do su -c "am force-stop $pkg"; done
                sleep 2

                deploy_lua_script

                echo "[*] Membuka semua aplikasi untuk Login..."
                for pkg in $PACKAGES; do
                    echo " -> Membuka $pkg..."
                    su -c "monkey -p $pkg -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1"
                    sleep 3
                done
                
                execute_layout
                
                echo ""
                echo "[+] Selesai! Aplikasi sudah berukuran Grid. Silakan login ke akun Anda."
                read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
                ;;
            2)
                clear
                if [ ! -f "$CONFIG_FILE" ]; then echo "[!] Link VIP belum diatur! Silakan isi di Menu Utama."; sleep 2; continue; fi
                VIP_LINK=$(cat "$CONFIG_FILE")
                
                echo "[*] Memulai Mesin Auto AFK..."
                prepare_device_environment

                PACKAGES=$(get_roblox_packages)
                if [ -z "$PACKAGES" ]; then echo "[!] Tidak ada aplikasi Roblox yang terdeteksi!"; sleep 2; continue; fi

                echo "[*] TAHAP 1: Menghentikan semua instance..."
                for pkg in $PACKAGES; do su -c "am force-stop $pkg"; done
                sleep 2

                echo "[*] TAHAP 2: Deploy Lua Script..."
                deploy_lua_script

                echo "[*] TAHAP 3: Membuka aplikasi secara normal..."
                for pkg in $PACKAGES; do
                    su -c "monkey -p $pkg -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1"
                    sleep 3
                done

                echo "[*] TAHAP 4: Mengeksekusi Layout Grid dari GitHub..."
                execute_layout
                
                echo "    Menunggu 15 detik agar aplikasi me-reload di mode Grid..."
                sleep 15 

                echo "[*] TAHAP 5: Menembakkan Link VIP..."
                for pkg in $PACKAGES; do
                    echo " -> Injecting VIP ke $pkg..."
                    su -c "am start --windowingMode 5 -a android.intent.action.VIEW -d \"$VIP_LINK\" $pkg > /dev/null 2>&1"
                    echo "    Menunggu 60 detik agar game termuat penuh..."
                    sleep 60 
                done

                echo "[*] Memasuki Mode AFK..."
                sleep 2

                drop_android_ram

                trap "echo -e '\n[!] Keluar dari Mode AFK...'; break" INT
                loop_count=1
                
                while true; do
                    sleep 300
                    drop_android_ram
                    ((loop_count++))
                done
                trap - INT
                ;;
            0) break ;;
            *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
        esac
    done
}

run_layout_and_engine
