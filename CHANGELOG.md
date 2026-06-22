# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog,
and this project adheres to Semantic Versioning.

---

## [3.1.0] - 2026-06-22
### Added
- **Banner gambar header** (`assets/banner.png`) ditampilkan di README GitHub (tema gelap + aksen Xiaomi-orange).
- Bagian bawah logo terminal diseragamkan dengan AUD (judul hijau, label abu, value cyan, garis penutup).
- **Deteksi region/varian ROM** (China / Global / EEA-Eropa / India / Indonesia) via `ro.product.mod_device`, `ro.miui.region`, `ro.product.locale.region`.
- **Peringatan otomatis** bila perangkat terdeteksi BUKAN keluarga Xiaomi/Redmi/POCO, plus konfirmasi ekstra sebelum debloat.
- **Statistik paket** di header: jumlah total paket terpasang & jumlah yang sedang di-disable (auto-refresh setelah aksi).
- **Menu Restore PILIHAN** — pilih aplikasi spesifik untuk dikembalikan (mis. Mi Music, Mi Video, Mi Browser) dari daftar paket yang sedang disable; dukung pilih banyak (`1 3 5`) atau `all`.
- Nama ramah (friendly name) untuk tiap paket di Scan & Restore.

### Changed
- Scan & Status dipercepat (memakai 2x fetch list daripada query per-paket).
- Menu utama diperluas menjadi 16 opsi.

---

## [3.0.0] - 2026-06-22
### Added
- ASCII banner baru bergaya "ANSI Shadow" (box-drawing) bertuliskan **MDR**, seragam dengan Android Universal Debloat (AUD).
- **Scan & Status Paket** — menampilkan status setiap paket target (`AKTIF` / `OFF` / tidak ada) sebelum debloat.
- **Backup otomatis** daftar paket aktif ke `backup/backup-YYYYMMDD-HHMMSS.txt` sebelum proses disable.
- **Log aksi** ke `logs/actions.log` + menu **Lihat Log Aksi**.
- **Restore dari File Backup** — pulihkan paket dari file backup yang dipilih.
- **Whitelist sistem** — paket vital (SystemUI, Settings, GMS/GSF, SecurityCenter, Launcher, Phone, dsb.) dilindungi & tidak akan dinonaktifkan.
- Daftar bloatware diperluas: MSA core, Glance/Fashion Gallery, App Vault (newhome), Facebook (katana), Mi Browser global, Mi Video global, FM Radio HyperOS, Theme Store, Mi Community/VIP, Virtual SIM, PowerKeeper, dll.
- Tabel panduan menu di README + badge merek Xiaomi/Redmi/POCO.

### Changed
- Identitas diperbarui: website **www.myrul.dev** & Facebook **https://web.facebook.com/myruldev** (seragam dengan AUD).
- Menu utama ditata ulang (Scan di urutan 1) dan diperluas menjadi 15 opsi.

---

## [2.0.0] - 2026-06-17
### Added
- Rebranded project from `rn7-1klik` to `MiDebloat-Remover` for universal Xiaomi series support.
- Shortened the executable script name to `mdr.sh` for quicker command entry in Termux.
- Fully compatible with MIUI and HyperOS (tested/adapted for Redmi Note 13 Pro+ 5G).
- Dynamic OS version detection (automatically detects HyperOS or MIUI).
- Categorized debloat package list:
  - **Debloat AMAN** (ads, telemetry, trackers).
  - **Debloat Optional** (pre-installed tools/apps like Mi Video, Music, Browser).
  - **Debloat Advanced** (Joyose & MiuiDaemon with user warning confirmation before disable).
- New very clear, readable, and mobile-friendly ASCII art logo representing **"Mi Debloat"**.


---

## [1.0.0] - 2026-01-13
### Added
- Initial release as `rn7-1klik` for Redmi Note 7.
- Safe MIUI debloat (disable-only, no uninstall).
- Clean system (kill background + trim cache).
- Game Mode ON / OFF.
- Ultra Battery Mode ON / OFF.
- RAM & CPU monitor (top).
- Requires Termux + Shizuku (no root).
