#!/bin/bash

echo "=== 1. PERSIAPAN SISTEM & ORIENTASI ==="
su -c "settings put system accelerometer_rotation 0"
su -c "settings put system user_rotation 1"
echo "[+] Orientasi dikunci ke Landscape."
sleep 1

echo "=== 2. SCANNING APLIKASI ==="
apps=($(su -c "pm list packages" | grep "com.roblox.clien" | cut -d':' -f2 | tr -d '\r' | sort))
count=${#apps[@]}

if [ "$count" -eq 0 ]; then
    echo "[!] Tidak ada aplikasi ditemukan."
    exit 1
fi

SCREEN_RES=$(su -c "wm size" | awk '{print $NF}' | tail -n 1)
W=$(echo $SCREEN_RES | cut -d'x' -f1)
H=$(echo $SCREEN_RES | cut -d'x' -f2)

if [ "$W" -lt "$H" ]; then
    temp=$W
    W=$H
    H=$temp
fi

cols=1
while [ $((cols * cols)) -lt "$count" ]; do
    cols=$((cols + 1))
done
rows=$(( (count + cols - 1) / cols ))

OFFSET_TOP=15
H_USABLE=$(( H - OFFSET_TOP ))

cellW=$(( W / cols ))
cellH=$(( H_USABLE / rows ))

MARGIN_TEPI=2
GAP_ANTAR=2

echo "[+] Resolusi: ${W}x${H} | Grid: ${cols}x${rows} | Total App: ${count}"

for i in "${!apps[@]}"; do
    app=${apps[$i]}
    ACTIVITY="$app/com.roblox.client.startup.ActivitySplash"
    
    echo "-----------------------------------"
    echo "-> Memproses ($((i+1))/$count): $app"
    
    su -c "am force-stop $app"
    sleep 0.5
    
    c=$(( i % cols ))
    r=$(( i / cols ))
    
    # --- LOGIKA AUTO-SWITCHING LAYOUT ---
    if [ "$count" -le 4 ]; then
        # JIKA APP 1 SAMPAI 4: Gunakan rasio proporsional (16:9)
        maxW=$(( cellW - 2 * MARGIN_TEPI ))
        maxH=$(( cellH - MARGIN_TEPI - GAP_ANTAR ))

        testH=$(( maxW * 9 / 16 ))
        testW=$(( maxH * 16 / 9 ))

        if [ "$testH" -le "$maxH" ]; then
            finalW=$maxW
            finalH=$testH
        else
            finalW=$testW
            finalH=$maxH
        fi

        offsetX=$(( (maxW - finalW) / 2 ))
        offsetY=$(( (maxH - finalH) / 2 ))

        L=$(( c * cellW + MARGIN_TEPI + offsetX ))
        R=$(( L + finalW ))
        T=$(( r * cellH + OFFSET_TOP + MARGIN_TEPI + offsetY ))
        B=$(( T + finalH ))
        echo "   [!] Mode: Proporsional (16:9)"
    else
        # JIKA APP 5, 6 ATAU LEBIH: Gunakan layar penuh (Penuhi cell grid)
        L=$(( c * cellW + MARGIN_TEPI ))
        R=$(( (c + 1) * cellW - MARGIN_TEPI ))
        T=$(( r * cellH + OFFSET_TOP + MARGIN_TEPI ))
        B=$(( (r + 1) * cellH + OFFSET_TOP - GAP_ANTAR ))
        echo "   [!] Mode: Full Cell (Maksimal Ruang)"
    fi
    # ------------------------------------
    
    echo "   [+] Kordinat: L:$L, T:$T, R:$R, B:$B"
    
    su -c "am start -n $ACTIVITY --windowingMode 5 > /dev/null 2>&1"
    sleep 3
    
    TASK_ID=$(su -c "dumpsys activity activities | grep 'TaskRecord' | grep '$app' | grep -o '#[0-9]*' | tr -d '#' | head -n 1")
    
    if [ -n "$TASK_ID" ]; then
        su -c "am task resize $TASK_ID $L $T $R $B > /dev/null 2>&1"
    else
        echo "   [!] Task ID tidak ditemukan."
    fi
    sleep 1.5
done
echo "=== DONE! ==="
