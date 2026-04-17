#!/bin/bash

REPO_URL="https://raw.githubusercontent.com/arsy-01/tools/main"
LAYOUT_URL="$REPO_URL/layout.sh"
CONFIG_FILE="/sdcard/Download/.vip_link_arsy.txt"

# [BARU] Fungsi untuk menghapus cache secara total saat aplikasi MATI
hard_clear_cache() {
    PACKAGES=$(get_roblox_packages)
    for pkg in $PACKAGES; do
        echo " -> Membersihkan sisa cache untuk $pkg..."
        su -c "rm -rf /data/data/$pkg/cache/*" > /dev/null 2>&1
        su -c "rm -rf /sdcard/Android/data/$pkg/cache/*" > /dev/null 2>&1
    done
}

# [DIPERBARUI] Fungsi optimasi yang berjalan tiap 5 menit saat AFK
drop_android_ram() {
    # 1. Matikan background apps
    su -c 'am kill-all' > /dev/null 2>&1
    
    # 2. Soft Clear Cache (Aman saat aplikasi berjalan 24/7)
    echo "    [*] Membersihkan system & app caches..."
    su -c 'pm trim-caches 999999999999999999' > /dev/null 2>&1
    
    # 3. Trim RAM aplikasi target
    PACKAGES=$(get_roblox_packages)
    for pkg in $PACKAGES; do
        su -c "cmd activity send-trim-memory $pkg RUNNING_LOW" > /dev/null 2>&1
    done
    echo "    [v] RAM & Cache teroptimasi."
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
    echo "[*] Mempersiapkan injeksi file Lua ke Eksekutor..."
    PACKAGES=$(get_roblox_packages)
    LUA_CONTENT='loadstring(game:HttpGet("https://raw.githubusercontent.com/arsy-01/tools/main/card.lua"))()'
    
    for pkg in $PACKAGES; do
        echo " -> Mencari folder eksekutor untuk $pkg..."
        
        # Mencari folder Autoexecute dan Scripts secara otomatis ke dalam seluruh sub-folder
        DIR_AUTOEXEC=$(su -c "find /sdcard/Android/data/$pkg/ -type d -name 'Autoexecute' 2>/dev/null | head -n 1" | tr -d '\r')
        DIR_SCRIPTS=$(su -c "find /sdcard/Android/data/$pkg/ -type d -name 'Scripts' 2>/dev/null | head -n 1" | tr -d '\r')
        
        # Mengeksekusi injeksi untuk Autoexecute
        if [ -n "$DIR_AUTOEXEC" ]; then
            su -c "echo '$LUA_CONTENT' > \"$DIR_AUTOEXEC/arsy_card.lua\""
            echo "    [v] Injeksi berhasil di: $DIR_AUTOEXEC"
        else
            echo "    [!] Folder Autoexecute tidak ditemukan."
        fi
        
        # Mengeksekusi injeksi untuk Scripts
        if [ -n "$DIR_SCRIPTS" ]; then
            su -c "echo '$LUA_CONTENT' > \"$DIR_SCRIPTS/arsy_card.lua\""
            echo "    [v] Injeksi berhasil di: $DIR_SCRIPTS"
        else
            echo "    [!] Folder Scripts tidak ditemukan."
        fi
    done
    sleep 2
}
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

                echo "[*] TAHAP 1: Menghentikan instance dan membersihkan total Cache..."
                for pkg in $PACKAGES; do su -c "am force-stop $pkg"; done
                sleep 2
                
                # Menjalankan hard clear cache saat aplikasi mati
                hard_clear_cache

                echo "[*] TAHAP 2: Deploy Lua Script..."
                deploy_lua_script

                echo "[*] TAHAP 3: Mengeksekusi Layout Grid dari GitHub..."
                execute_layout
                
                echo "    Menunggu 15 detik agar aplikasi me-reload di mode Grid..."
                sleep 15 

                echo "[*] TAHAP 4: Menembakkan Link VIP..."
                for pkg in $PACKAGES; do
                    echo " -> Injecting VIP ke $pkg..."
                    su -c "am start --windowingMode 5 -a android.intent.action.VIEW -d \"$VIP_LINK\" $pkg > /dev/null 2>&1"
                    echo "    Menunggu 60 detik agar game termuat penuh..."
                    sleep 60 
                done

                echo "[*] Memasuki Mode AFK (Loop Optimasi & Auto-Clear berjalan)..."
                sleep 2

                # Menjalankan optimasi pertama kali saat masuk mode AFK
                drop_android_ram

                trap "echo -e '\n[!] Keluar dari Mode AFK...'; break" INT
                loop_count=1
                
                # Looping 24/7 (Setiap 300 detik / 5 Menit)
                while true; do
                    sleep 300
                    echo "--- [Siklus AFK #$loop_count] ---"
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
