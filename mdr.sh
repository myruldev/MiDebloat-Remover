#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==========================================================
# MiDebloat-Remover (Safe • No Root)
# Debloat • Clean • Game Mode • Ultra Battery • Monitor • Restore
#
# myrul.dev
# https://www.facebook.com/xamrl
#
# Requires:
# - Shizuku RUNNING
# - rish installed & working (rish -c id)
#
# Safety:
# - DISABLE only (no uninstall)
# - Restore supported
# ==========================================================

# --- Requirements ---
if ! command -v rish >/dev/null 2>&1; then
  echo "[ERROR] 'rish' tidak ditemukan."
  echo "Pastikan Shizuku RUNNING dan rish sudah terpasang di Termux."
  exit 1
fi

# Ensure rish knows the calling app id (Termux)
export RISH_APPLICATION_ID=${RISH_APPLICATION_ID:-com.termux}

run() { rish -c "$1"; }

# Quick connectivity check (non-fatal)
if ! run "id" >/dev/null 2>&1; then
  echo "[ERROR] Tidak bisa konek ke Shizuku (rish -c id gagal)."
  echo "Cek Shizuku RUNNING, izin Termux di Shizuku, dan battery/autostart."
  exit 1
fi

logo() {
  G="\033[1;32m"  # green
  N="\033[0m"     # reset

  echo -e "${G}"
  cat <<'EOF'
 __  __  _____   _____  
|  \/  ||  __ \ |  __ \ 
| \  / || |  | || |__) |
| |\/| || |  | ||  _  / 
| |  | || |__| || | \ \ 
|_|  |_||_____/ |_|  \_\
 >> Mi Debloat Remover <<
EOF
  echo -e "${N}${G}   myrul.dev | facebook.com/xamrl${N}"
}

# --- Auto detect device / series ---
detect_device() {
  BRAND="$(run 'getprop ro.product.brand' 2>/dev/null | tr -d '\r')"
  MANU="$(run 'getprop ro.product.manufacturer' 2>/dev/null | tr -d '\r')"
  MODEL="$(run 'getprop ro.product.model' 2>/dev/null | tr -d '\r')"
  DEVICE="$(run 'getprop ro.product.device' 2>/dev/null | tr -d '\r')"
  MIUI="$(run 'getprop ro.miui.ui.version.name' 2>/dev/null | tr -d '\r')"
  HYPER="$(run 'getprop ro.hyperos.version' 2>/dev/null | tr -d '\r')"
  ANDR="$(run 'getprop ro.build.version.release' 2>/dev/null | tr -d '\r')"

  SERIES="Unknown"
  if echo "$BRAND $MANU $MODEL" | grep -qiE "redmi"; then
    SERIES="Redmi"
  elif echo "$BRAND $MANU $MODEL" | grep -qiE "\bpoco\b"; then
    SERIES="POCO"
  elif echo "$BRAND $MANU $MODEL" | grep -qiE "xiaomi|\bmi\b"; then
    SERIES="Xiaomi"
  fi
}

show_device_info() {
  detect_device
  echo "Device : $MODEL ($DEVICE)"
  echo "Series : $SERIES"
  echo "Android: $ANDR"
  if [ -n "$HYPER" ]; then
    echo "OS     : HyperOS $HYPER"
  else
    echo "OS     : MIUI ${MIUI:-unknown}"
  fi
}

# --- Safe MIUI & HyperOS debloat list (disable only) ---
DEBLOAT_PKGS=(
  com.miui.msa.global               # MIUI System Ads
  com.miui.analytics                # Telemetry & tracking
  com.miui.android.fashiongallery   # Wallpaper Carousel (ads)
  com.miui.bugreport                # Bug reporting tool
  com.miui.yellowpage               # Yellow pages business directory
  com.miui.cleanmaster              # Cleaner app (contains ads/trackers)
  com.miui.miservice                # Services & Feedback
  com.xiaomi.glgm                   # Xiaomi Games App Store
  com.miui.hybrid                   # Quick Apps
  com.miui.hybrid.accessory         # Quick Apps accessory
  com.facebook.system               # Facebook App Installer
  com.facebook.appmanager           # Facebook App Manager
  com.facebook.services             # Facebook Services
  com.google.android.apps.tachyon   # Google Duo / Meet
  com.xiaomi.payment                # Mi Pay / Digital Wallet payments
  com.google.android.apps.subscriptions.red # Google One
  com.google.android.videos         # Google Play Movies & TV / Google TV
  com.google.android.feedback       # Google Feedback tool
)

# Optional packages (disable only if you DON'T use them)
OPTIONAL_PKGS=(
  com.xiaomi.mipicks                # GetApps (Xiaomi App Store)
  com.miui.browser                  # Mi Browser
  com.miui.videoplayer              # Mi Video
  com.miui.player                   # Mi Music
  com.miui.weather2                 # Mi Weather
  com.miui.notes                    # Mi Notes
  com.miui.compass                  # Compass
  com.miui.fmradio                  # FM Radio
  com.xiaomi.midrop                 # ShareMe
  com.google.android.projection.gearhead # Android Auto
  com.miui.cloudservice             # Xiaomi Cloud core service
  com.miui.cloudservice.sysapp      # Xiaomi Cloud system integration
  com.miui.cloudbackup              # Xiaomi Cloud backup
  com.miui.micloudsync              # Xiaomi Cloud synchronization
  com.miui.mishare.connectivity     # Mi Share connectivity/sharing files
  com.xiaomi.scanner                # Mi Scanner
  com.miui.screenrecorder           # Mi Screen Recorder
)

# Advanced packages (WARNING: read comment first)
ADVANCED_PKGS=(
  com.xiaomi.joyose                 # Joyose (Performance control. Disable boosts game FPS but may affect dynamic screen refresh/Mi Account sync on some HyperOS versions)
  com.miui.daemon                   # MiuiDaemon (Telemetry background. Disabling saves battery but may affect Xiaomi Cloud status verification)
)

# --- Helpers: status & pretty output ---
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*"; }

pkg_exists() { run "pm list packages $1" | grep -q "$1"; }

disable_pkg() {
  local pkg="$1"
  if ! pkg_exists "$pkg"; then
    yellow "• Skip (tidak ada): $pkg"
    return 0
  fi

  # Check current state
  if run "pm list packages -d $pkg" | grep -q "$pkg"; then
    yellow "• Sudah disable: $pkg"
    return 0
  fi

  if run "pm disable-user --user 0 $pkg" >/dev/null 2>&1; then
    green "• Berhasil disable: $pkg"
  else
    red "• Gagal disable: $pkg"
  fi
}

enable_pkg() {
  local pkg="$1"
  if ! pkg_exists "$pkg"; then
    yellow "• Skip (tidak ada): $pkg"
    return 0
  fi

  if run "pm enable $pkg" >/dev/null 2>&1; then
    green "• Berhasil enable: $pkg"
  else
    red "• Gagal enable: $pkg"
  fi
}

disable_list() { for p in "$@"; do disable_pkg "$p"; done; }
enable_list() { for p in "$@"; do enable_pkg "$p"; done; }

# --- Clean ---
clean_now() {
  echo
  echo "[INFO] Execute: Clean (kill background + trim cache)"
  if run "am kill-all" >/dev/null 2>&1; then
    green "[OK] Background apps ditutup."
  else
    yellow "[WARN] am kill-all tidak didukung/ditolak, lanjut..."
  fi

  if run "pm trim-caches 999G" >/dev/null 2>&1; then
    green "[OK] Cache sistem dibersihkan (trim-caches)."
  else
    yellow "[WARN] trim-caches tidak didukung/ditolak, lanjut..."
  fi

  green "[DONE] Clean selesai."
}

# --- Game Mode (robust) ---
supports_fixed_perf() {
  run "cmd power help" 2>/dev/null | grep -q "set-fixed-performance-mode-enabled"
}

game_on() {
  echo
  echo "[INFO] Execute: Game Mode ON"
  run "am kill-all" >/dev/null 2>&1 || true
  green "[OK] Background apps ditutup."

  if supports_fixed_perf; then
    if run "cmd power set-fixed-performance-mode-enabled true" >/dev/null 2>&1; then
      green "[OK] Fixed performance mode: ON"
      green "[DONE] Game Mode aktif."
    else
      yellow "[WARN] Perintah performance mode gagal dijalankan. Tetap lanjut (clean sudah dilakukan)."
      yellow "[DONE] Game Mode: Clean-only (fallback)."
    fi
  else
    yellow "[INFO] Android kamu tidak mendukung 'set-fixed-performance-mode-enabled'."
    yellow "[DONE] Game Mode: Clean-only (fallback)."
  fi
}

game_off() {
  echo
  echo "[INFO] Execute: Game Mode OFF"
  if supports_fixed_perf; then
    if run "cmd power set-fixed-performance-mode-enabled false" >/dev/null 2>&1; then
      green "[OK] Fixed performance mode: OFF"
      green "[DONE] Game Mode nonaktif."
    else
      yellow "[WARN] Perintah performance mode gagal. Tidak ada yang diubah."
    fi
  else
    yellow "[INFO] Android kamu tidak mendukung 'set-fixed-performance-mode-enabled'."
    yellow "[DONE] Tidak ada yang perlu dimatikan (sebelumnya fallback)."
  fi
}

# --- Ultra Battery Mode ---
ultra_on() {
  echo
  echo "[INFO] Execute: Ultra Battery ON"
  ok=0

  run "settings put global master_sync_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global background_check_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global wifi_scan_always_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global ble_scan_always_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true

  if [ "$ok" -gt 0 ]; then
    green "[OK] Ultra Battery Mode aktif (applied: $ok setting)."
  else
    yellow "[WARN] Tidak ada setting yang berhasil diubah (mungkin dibatasi ROM)."
  fi
  yellow "Catatan: Master sync dimatikan (email/photos bisa tidak auto-sync)."
}

ultra_off() {
  echo
  echo "[INFO] Execute: Ultra Battery OFF (restore)"
  ok=0

  run "settings put global master_sync_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global background_check_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global wifi_scan_always_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global ble_scan_always_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true

  if [ "$ok" -gt 0 ]; then
    green "[OK] Ultra Battery Mode dimatikan (restore) (applied: $ok setting)."
  else
    yellow "[WARN] Tidak ada setting yang berhasil diubah (mungkin dibatasi ROM)."
  fi
}

# --- Speed Up Animations (System settings) ---
animation_fast() {
  echo
  echo "[INFO] Execute: Speed Up Animations (0.5x)"
  ok=0
  run "settings put global window_animation_scale 0.5" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global transition_animation_scale 0.5" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global animator_duration_scale 0.5" >/dev/null 2>&1 && ok=$((ok+1)) || true

  if [ "$ok" -gt 0 ]; then
    green "[OK] Animasi diset ke 0.5x (applied: $ok setting). HP Anda sekarang terasa lebih cepat!"
  else
    yellow "[WARN] Gagal mengubah setting animasi (mungkin dibatasi ROM)."
  fi
}

animation_normal() {
  echo
  echo "[INFO] Execute: Restore Animations (1.0x)"
  ok=0
  run "settings put global window_animation_scale 1.0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global transition_animation_scale 1.0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global animator_duration_scale 1.0" >/dev/null 2>&1 && ok=$((ok+1)) || true

  if [ "$ok" -gt 0 ]; then
    green "[OK] Animasi dikembalikan ke 1.0x (applied: $ok setting)."
  else
    yellow "[WARN] Gagal mengubah setting animasi."
  fi
}

# --- Monitor ---
show_top() {
  echo
  echo "[INFO] Execute: Monitor RAM/CPU (top)"
  yellow "Tekan Ctrl+C untuk keluar"
  sleep 1
  run "top -o RES,CPU,ARGS -s 10"
}

pause() { echo; read -r -p "Tekan Enter untuk lanjut..."; }

# --- Main Menu ---
while true; do
  clear
  logo
  echo "----------------------------------------------"
  show_device_info
  echo "=============================================="
  echo "1) Debloat AMAN (Iklan & Telemetri Utama)"
  echo "2) Debloat AMAN + Optional (Aplikasi Bawaan)"
  echo "3) Debloat ADVANCED (Joyose & Daemon - Baca Risiko!)"
  echo "4) Clean (Kill background + trim cache)"
  echo "5) Game Mode ON"
  echo "6) Game Mode OFF"
  echo "7) Ultra Battery ON"
  echo "8) Ultra Battery OFF"
  echo "9) Monitor RAM / CPU (top)"
  echo "10) Speed Up Animations (Animasi 0.5x - Lebih Responsif!)"
  echo "11) Restore Animations (Animasi 1.0x - Normal)"
  echo "12) Restore Debloat (Aktifkan kembali semua paket)"
  echo "0) Keluar"
  echo "----------------------------------------------"
  read -r -p "Pilih (0-12): " c

  case "$c" in
    1)
      echo
      echo "[INFO] Execute: Debloat AMAN"
      disable_list "${DEBLOAT_PKGS[@]}"
      green "[DONE] Debloat aman selesai."
      pause
      ;;
    2)
      echo
      echo "[INFO] Execute: Debloat AMAN + Optional"
      echo "== Safe =="
      disable_list "${DEBLOAT_PKGS[@]}"
      echo
      echo "== Optional =="
      disable_list "${OPTIONAL_PKGS[@]}"
      green "[DONE] Debloat + optional selesai."
      pause
      ;;
    3)
      echo
      echo "[WARNING] Menonaktifkan Joyose/Daemon dapat menyebabkan performa game naik"
      echo "namun pada versi HyperOS tertentu berisiko mengganggu sinkronisasi akun"
      echo "atau refresh rate dinamis."
      read -r -p "Apakah Anda yakin ingin melanjutkan? (y/n): " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "[INFO] Execute: Debloat ADVANCED"
        disable_list "${ADVANCED_PKGS[@]}"
        green "[DONE] Debloat advanced selesai."
      else
        yellow "Dibatalkan."
      fi
      pause
      ;;
    4) clean_now; pause ;;
    5) game_on; pause ;;
    6) game_off; pause ;;
    7) ultra_on; pause ;;
    8) ultra_off; pause ;;
    9) show_top; pause ;;
    10) animation_fast; pause ;;
    11) animation_normal; pause ;;
    12)
      echo
      echo "[INFO] Execute: Restore Debloat"
      enable_list "${DEBLOAT_PKGS[@]}"
      enable_list "${OPTIONAL_PKGS[@]}"
      enable_list "${ADVANCED_PKGS[@]}"
      green "[DONE] Restore selesai."
      pause
      ;;
    0) exit 0 ;;
    *) red "Pilihan tidak valid"; pause ;;
  esac
done
