# MiDebloat-Remover  
Debloat • Clean • Game Mode • Ultra Battery  
**Safe & No Root (Termux + Shizuku) for Xiaomi, Redmi, & POCO (MIUI & HyperOS)**

Made with ❤️ by **myrul.dev**  
🔗 https://www.facebook.com/xamrl  

---

## 📱 Logo Baru
```
 __  __  _____   _____  
|  \/  ||  __ \ |  __ \ 
| \  / || |  | || |__) |
| |\/| || |  | ||  _  / 
| |  | || |__| || | \ \ 
|_|  |_||_____/ |_|  \_\
 >> Mi Debloat Remover <<
```

---

## ✨ Fitur Utama
*   ✅ **Debloat Aman** (hanya mematikan/disable, tidak menghapus permanen/uninstall sehingga tidak merusak sistem).
*   ✅ **Daftar Debloat Diperluas**: Menyediakan optimasi pembersihan iklan, telemetri, aplikasi pihak ketiga bawaan (Facebook/Google TV), Xiaomi Cloud Services, Mi Share, Mi Pay, dsb.
*   ✅ **Deteksi Otomatis** (Mendeteksi model perangkat dan versi sistem MIUI / HyperOS secara real-time).
*   🚀 **Optimasi Kecepatan Animasi** (Memotong durasi animasi menjadi `0.5x` secara sistem untuk meningkatkan kerestokan transisi UI, tanpa menghapus app/root).
*   🧹 **Clean System** (menghentikan aplikasi latar belakang & membersihkan cache sistem).
*   🎮 **Game Mode ON / OFF** (mengaktifkan mode performa tinggi jika didukung sistem).
*   🔋 **Ultra-Hemat Baterai Mode** (menonaktifkan sync otomatis & membatasi pemindaian latar belakang).
*   📊 **Monitor RAM & CPU** (pantauan proses real-time melalui utilitas `top`).
*   🔁 **Restore Penuh** (bisa mengaktifkan kembali semua aplikasi yang telah di-debloat ke kondisi semula).
*   🛡️ **Aman & Tanpa Root** (menggunakan API tingkat sistem via Shizuku).

---

## 📱 Perangkat yang Didukung
*   Semua seri **Xiaomi**, **Redmi**, dan **POCO** (MIUI / HyperOS).
*   Android 10 hingga Android 14+ (Temasuk HyperOS pada Redmi Note 13 Pro+ 5G).

---

## 🧰 Persyaratan
1.  **Termux** (Sangat disarankan versi F-Droid)  
    👉 [Termux F-Droid](https://f-droid.org/packages/com.termux/)
2.  **Shizuku**  
    👉 [Shizuku di Play Store](https://play.google.com/store/apps/details?id=moe.shizuku.privileged.api)
3.  **Shizuku dalam keadaan RUNNING**
4.  **rish (Shizuku shell) sudah terpasang** (Tes dengan perintah `rish -c id` harus berhasil).

---

## 🚀 Instalasi & Cara Menjalankan
1.  Unduh script `mdr.sh` ke Termux Anda.
2.  Beri izin eksekusi pada script:
    ```bash
    chmod +x mdr.sh
    ```
3.  Jalankan perkakas:
    ```bash
    ./mdr.sh
    ```

---

## 🧭 Panduan Menu Debloat & Optimasi
1.  **Debloat AMAN**: Menghapus telemetri & iklan MIUI/HyperOS (MSA, Analytics, Fashion Gallery, Bug Report, Google One, Google TV, Mi Pay, dsb) tanpa efek samping pada sistem.
2.  **Debloat AMAN + Optional**: Pilihan pertama ditambah aplikasi bawaan seperti GetApps, Mi Video, Mi Music, Mi Weather, Mi Cloud Services, Mi Share, dsb. (Dinonaktifkan hanya jika Anda sudah memiliki aplikasi pengganti).
3.  **Debloat ADVANCED**: Menghapus Joyose & MiuiDaemon. *Baca peringatan terlebih dahulu sebelum mengeksekusi!*
4.  **Optimasi Animasi**: Mempercepat transisi Android Anda secara instan ke `0.5x` (membuat UI terasa sangat cepat) atau mengembalikannya ke `1.0x` (standar).
5.  **Restore Debloat**: Mengaktifkan kembali seluruh paket yang dinonaktifkan ke kondisi semula.


---

## 🛡️ Keamanan & Disclaimer
*   Script ini **tidak menghapus file sistem secara permanen**, melainkan menonaktifkannya (`disable-user`) untuk user 0.
*   Jika terjadi masalah, Anda dapat dengan mudah mengembalikan aplikasi melalui menu **Restore** di dalam script, atau via ADB komputer dengan perintah:
    ```bash
    adb shell pm install-existing <nama_paket>
    ```
*   **Gunakan dengan risiko ditanggung sendiri (DWYOR - Do With Your Own Risk).**

---

Made with **myrul.dev** | [Facebook](https://www.facebook.com/xamrl)
