# Troubleshooting

This guide helps fix common issues when using MiDebloat-Remover with Termux + Shizuku.

---

## 🚀 Cara Memasang & Memindahkan file `rish` (Shizuku) ke Termux

Agar `rish` dapat terbaca sebagai perintah sistem di Termux, ikuti langkah pemasangan berikut:

1. **Berikan Izin Akses Penyimpanan di Termux**:
   ```bash
   termux-setup-storage
   ```
2. **Salin File `rish` & `rish.dex` ke Folder Bin Termux**:
   * **Opsi 1**: Jika file diekspor dari aplikasi Shizuku (default):
     ```bash
     cp /sdcard/Android/media/moe.shizuku.privileged.api/files/rish* $PREFIX/bin/
     ```
   * **Opsi 2**: Jika file diletakkan di folder bernama **`Rish Shizuku`** (menggunakan kutip karena ada spasi):
     ```bash
     cp "/sdcard/Rish Shizuku"/rish* $PREFIX/bin/
     ```
     *(Jika di dalam folder Download: `cp "/sdcard/Download/Rish Shizuku"/rish* $PREFIX/bin/`)*
   * **Opsi 3**: Jika file diletakkan langsung di folder **Download**:
     ```bash
     cp /sdcard/Download/rish* $PREFIX/bin/
     ```
3. **Berikan Izin Eksekusi**:
   ```bash
   chmod +x $PREFIX/bin/rish
   ```

---

## ❌ rish: command not found
**Cause**
- rish belum dipindahkan ke folder bin Termux atau PATH belum di-refresh.

**Fix**
- Ikuti panduan **Cara Memasang & Memindahkan file `rish`** di atas.

---

## ❌ RISH_APPLICATION_ID is not set (Terutama di Android 14+)
**Cause**
- Android 14+ memerlukan pendefinisian ID aplikasi pemanggil (`com.termux`) agar Shizuku bersedia memberikan akses shell.

**Fix**
Jalankan perintah ini di Termux:
```bash
export RISH_APPLICATION_ID=com.termux
```
Agar permanen dan tidak perlu mengetik ulang setiap kali membuka Termux, tambahkan perintah tersebut ke konfigurasi shell:
```bash
echo 'export RISH_APPLICATION_ID=com.termux' >> ~/.bashrc
```

---

## ❌ Request timeout / cannot connect to Shizuku
**Cause**
- Shizuku not running
- Battery restriction
- Autostart disabled

**Fix**
- Shizuku status must be RUNNING
- Battery: No restrictions
- Autostart: ON for Termux & Shizuku

---

## ❌ Shizuku stops working after reboot
**Fix**
- Restart Shizuku via Wireless Debugging or ADB
- Reopen Termux and retry

---

## ⚠️ Features missing after debloat
**Fix**
- Use menu: Restore Debloat (Option 13) atau Restore dari File Backup (Option 14)
- Or enable manually:
```bash
rish -c "pm enable <package_name>"
```

---

## 📊 Check performance
```bash
rish -c "top -o RES,CPU,ARGS -s 10"
```

---

## ℹ️ Notes
- Some MIUI/HyperOS versions hide advanced settings
- Behavior may vary between devices
- Always use SAFE mode first
