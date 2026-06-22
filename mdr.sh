#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==========================================================
# MiDebloat-Remover (Safe • No Root)
# Debloat • Clean • Game Mode • Ultra Battery • Monitor • Restore
# Khusus keluarga Xiaomi: Xiaomi • Redmi • POCO (MIUI & HyperOS)
#
# Website : https://www.myrul.dev
# Facebook: https://web.facebook.com/myruldev
#
# Requires:
# - Shizuku RUNNING
# - rish installed & working (rish -c id)
#
# Safety:
# - DISABLE only (no uninstall)
# - Whitelist paket sistem penting (tidak akan disentuh)
# - Backup otomatis + log setiap aksi
# - Restore supported
# ==========================================================

VERSION="3.0.0"

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

# --- Paths (backup & log) ---
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$BASE_DIR/logs"
BACKUP_DIR="$BASE_DIR/backup"
LOG_FILE="$LOG_DIR/actions.log"
mkdir -p "$LOG_DIR" "$BACKUP_DIR"

log() {
  # log "LEVEL" "message"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$ts] [$1] $2" >>"$LOG_FILE"
}

logo() {
  G="\033[1;32m"  # green
  N="\033[0m"     # reset

  echo -e "${G}"
  cat <<'EOF'
 ███╗   ███╗██████╗ ██████╗
 ████╗ ████║██╔══██╗██╔══██╗
 ██╔████╔██║██║  ██║██████╔╝
 ██║╚██╔╝██║██║  ██║██╔══██╗
 ██║ ╚═╝ ██║██████╔╝██║  ██║
 ╚═╝     ╚═╝╚═════╝ ╚═╝  ╚═╝
      >> Mi Debloat Remover <<
EOF
  echo -e "${N}${G}   www.myrul.dev | web.facebook.com/myruldev${N}"
  echo -e "${G}   v${VERSION} • Safe • No Root • Xiaomi/Redmi/POCO${N}"
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

# --- Whitelist: paket sistem PENTING yang TIDAK BOLEH disentuh ---
WHITELIST=(
  com.android.systemui
  com.android.settings
  com.google.android.gms
  com.google.android.gsf
  com.android.vending
  com.android.permissioncontroller
  com.android.packageinstaller
  com.android.providers.downloads
  com.android.providers.media
  com.miui.securitycenter
  com.miui.home
  com.android.phone
  com.android.systemui.overlay
)

is_whitelisted() {
  local pkg="$1"
  for w in "${WHITELIST[@]}"; do
    [ "$w" = "$pkg" ] && return 0
  done
  return 1
}

# --- Safe MIUI & HyperOS debloat list (disable only) ---
DEBLOAT_PKGS=(
  com.miui.msa.global               # MIUI System Ads
  com.miui.systemAdSolution         # MSA core (China/global ad framework)
  com.miui.analytics                # Telemetry & tracking
  com.miui.android.fashiongallery   # Wallpaper Carousel (ads)
  com.mfashiongallery.emag          # Glance / Fashion Gallery feed
  com.miui.bugreport                # Bug reporting tool
  com.miui.yellowpage               # Yellow pages business directory
  com.miui.cleanmaster              # Cleaner app (contains ads/trackers)
  com.miui.miservice                # Services & Feedback
  com.xiaomi.glgm                   # Xiaomi Games App Store
  com.miui.hybrid                   # Quick Apps
  com.miui.hybrid.accessory         # Quick Apps accessory
  com.miui.newhome                  # App Vault / News feed (ads)
  com.facebook.system               # Facebook App Installer
  com.facebook.appmanager           # Facebook App Manager
  com.facebook.services             # Facebook Services
  com.facebook.katana               # Facebook (preinstalled)
  com.google.android.apps.tachyon   # Google Duo / Meet
  com.xiaomi.payment                # Mi Pay / Digital Wallet payments
  com.mipay.wallet.id               # Mi Pay wallet (region)
  com.google.android.apps.subscriptions.red # Google One
  com.google.android.videos         # Google Play Movies & TV / Google TV
  com.google.android.feedback       # Google Feedback tool
  com.miui.miwallpaper.wallpaper    # Extra wallpaper service (ads)
)

# Optional packages (disable only if you DON'T use them)
OPTIONAL_PKGS=(
  com.xiaomi.mipicks                # GetApps (Xiaomi App Store)
  com.miui.browser                  # Mi Browser
  com.mi.globalbrowser              # Mi Browser (global)
  com.miui.videoplayer              # Mi Video
  com.miui.video.global             # Mi Video (global)
  com.miui.player                   # Mi Music
  com.miui.weather2                 # Mi Weather
  com.miui.notes                    # Mi Notes
  com.miui.compass                  # Compass
  com.miui.fm                       # FM Radio (HyperOS)
  com.miui.fmradio                  # FM Radio (MIUI)
  com.xiaomi.midrop                 # ShareMe
  com.google.android.projection.gearhead # Android Auto
  com.miui.cloudservice             # Xiaomi Cloud core service
  com.miui.cloudservice.sysapp      # Xiaomi Cloud system integration
  com.miui.cloudbackup              # Xiaomi Cloud backup
  com.miui.micloudsync              # Xiaomi Cloud synchronization
  com.miui.mishare.connectivity     # Mi Share connectivity/sharing files
  com.xiaomi.scanner                # Mi Scanner
  com.miui.screenrecorder           # Mi Screen Recorder
  com.xiaomi.vipaccount             # Mi Community / VIP Account
  com.miui.virtualsim               # Virtual SIM
  com.android.thememanager          # Theme Store (ads/promo content)
)

# Advanced packages (WARNING: read comment first)
ADVANCED_PKGS=(
  com.xiaomi.joyose                 # Joyose (Performance control. Disable boosts game FPS but may affect dynamic screen refresh/Mi Account sync on some HyperOS versions)
  com.miui.daemon                   # MiuiDaemon (Telemetry background. Disabling saves battery but may affect Xiaomi Cloud status verification)
  com.miui.analytics                # (already in safe; advanced re-confirm)
  com.miui.powerkeeper              # PowerKeeper (aggressive battery mgmt; disabling may break some power features)
)

# --- Helpers: status & pretty output ---
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*"; }

pkg_exists() { run "pm list packages $1" | grep -q "$1"; }
pkg_disabled() { run "pm list packages -d $1" | grep -q "$1"; }

disable_pkg() {
  local pkg="$1"
  if is_whitelisted "$pkg"; then
    red "• DILINDUNGI (whitelist), dilewati: $pkg"
    log "GUARD" "skip whitelist $pkg"
    return 0
  fi
  if ! pkg_exists "$pkg"; then
    yellow "• Skip (tidak ada): $pkg"
    return 0
  fi
  if pkg_disabled "$pkg"; then
    yellow "• Sudah disable: $pkg"
    return 0
  fi
  if run "pm disable-user --user 0 $pkg" >/dev/null 2>&1; then
    green "• Berhasil disable: $pkg"
    log "DISABLE" "$pkg"
  else
    red "• Gagal disable: $pkg"
    log "ERROR" "disable failed $pkg"
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
    log "ENABLE" "$pkg"
  else
    red "• Gagal enable: $pkg"
    log "ERROR" "enable failed $pkg"
  fi
}

# Backup daftar paket yang akan dinonaktifkan SEBELUM aksi
backup_before_disable() {
  local label="$1"; shift
  local ts file
  ts="$(date '+%Y%m%d-%H%M%S')"
  file="$BACKUP_DIR/backup-$ts.txt"
  {
    echo "# MiDebloat-Remover backup"
    echo "# label  : $label"
    echo "# date   : $(date '+%Y-%m-%d %H:%M:%S')"
    echo "# device : $MODEL ($DEVICE) / $SERIES"
    echo "# note   : daftar paket yang aktif & akan dinonaktifkan"
    for p in "$@"; do
      if pkg_exists "$p" && ! pkg_disabled "$p" && ! is_whitelisted "$p"; then
        echo "$p"
      fi
    done
  } >"$file"
  green "[BACKUP] Disimpan: $file"
  log "BACKUP" "$label -> $file"
}

disable_list() {
  detect_device
  backup_before_disable "disable" "$@"
  for p in "$@"; do disable_pkg "$p"; done
}
enable_list() { for p in "$@"; do enable_pkg "$p"; done; }

# --- Scan & Status ---
scan_status() {
  detect_device
  echo
  echo "[INFO] Scan status paket target di perangkat ini"
  echo "Legenda: [AKTIF] terpasang & aktif  |  [OFF] sudah disable  |  [-] tidak ada"
  echo "----------------------------------------------"
  local groups=("SAFE" "OPTIONAL" "ADVANCED")
  local i=0
  for grp in "DEBLOAT_PKGS[@]" "OPTIONAL_PKGS[@]" "ADVANCED_PKGS[@]"; do
    eval "arr=(\"\${$grp}\")"
    echo
    yellow "== ${groups[$i]} =="
    for p in "${arr[@]}"; do
      if ! pkg_exists "$p"; then
        printf "  [-]     %s\n" "$p"
      elif pkg_disabled "$p"; then
        printf "  [OFF]   %s\n" "$p"
      else
        printf "  [AKTIF] %s\n" "$p"
      fi
    done
    i=$((i+1))
  done
  log "SCAN" "status scan executed"
}

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
  log "CLEAN" "kill-all + trim-caches"
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
      log "GAME" "fixed-perf ON"
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
      log "GAME" "fixed-perf OFF"
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
    log "BATTERY" "ultra ON ($ok)"
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
    log "BATTERY" "ultra OFF ($ok)"
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
    log "ANIM" "0.5x ($ok)"
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
    log "ANIM" "1.0x ($ok)"
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

# --- Lihat Log ---
show_log() {
  echo
  echo "[INFO] 30 baris terakhir log aksi ($LOG_FILE):"
  echo "----------------------------------------------"
  if [ -f "$LOG_FILE" ]; then
    tail -n 30 "$LOG_FILE"
  else
    yellow "Belum ada log."
  fi
}

# --- Restore dari file backup ---
restore_from_backup() {
  echo
  echo "[INFO] Daftar file backup tersedia:"
  local files=("$BACKUP_DIR"/backup-*.txt)
  if [ ! -e "${files[0]}" ]; then
    yellow "Belum ada file backup."
    return 0
  fi
  local i=1
  for f in "${files[@]}"; do
    echo "  $i) $(basename "$f")"
    i=$((i+1))
  done
  read -r -p "Pilih nomor backup untuk di-restore (0 batal): " sel
  [ "$sel" = "0" ] && { yellow "Dibatalkan."; return 0; }
  local chosen="${files[$((sel-1))]}"
  if [ -z "$chosen" ] || [ ! -f "$chosen" ]; then
    red "Pilihan tidak valid."
    return 0
  fi
  echo "[INFO] Restore dari: $(basename "$chosen")"
  while IFS= read -r line; do
    case "$line" in
      ''|\#*) continue ;;
      *) enable_pkg "$line" ;;
    esac
  done <"$chosen"
  green "[DONE] Restore dari backup selesai."
  log "RESTORE" "from $(basename "$chosen")"
}

pause() { echo; read -r -p "Tekan Enter untuk lanjut..."; }

# --- Main Menu ---
while true; do
  clear
  logo
  echo "----------------------------------------------"
  show_device_info
  echo "=============================================="
  echo " 1) Scan & Status Paket (cek dulu sebelum debloat)"
  echo " 2) Debloat AMAN (Iklan & Telemetri Utama)"
  echo " 3) Debloat AMAN + Optional (Aplikasi Bawaan)"
  echo " 4) Debloat ADVANCED (Joyose & Daemon - Baca Risiko!)"
  echo " 5) Clean (Kill background + trim cache)"
  echo " 6) Game Mode ON"
  echo " 7) Game Mode OFF"
  echo " 8) Ultra Battery ON"
  echo " 9) Ultra Battery OFF"
  echo "10) Monitor RAM / CPU (top)"
  echo "11) Speed Up Animations (0.5x - Lebih Responsif!)"
  echo "12) Restore Animations (1.0x - Normal)"
  echo "13) Restore Debloat (Aktifkan kembali semua paket)"
  echo "14) Restore dari File Backup"
  echo "15) Lihat Log Aksi"
  echo " 0) Keluar"
  echo "----------------------------------------------"
  read -r -p "Pilih (0-15): " c

  case "$c" in
    1) scan_status; pause ;;
    2)
      echo
      echo "[INFO] Execute: Debloat AMAN"
      disable_list "${DEBLOAT_PKGS[@]}"
      green "[DONE] Debloat aman selesai."
      pause
      ;;
    3)
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
    4)
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
    5) clean_now; pause ;;
    6) game_on; pause ;;
    7) game_off; pause ;;
    8) ultra_on; pause ;;
    9) ultra_off; pause ;;
    10) show_top; pause ;;
    11) animation_fast; pause ;;
    12) animation_normal; pause ;;
    13)
      echo
      echo "[INFO] Execute: Restore Debloat"
      enable_list "${DEBLOAT_PKGS[@]}"
      enable_list "${OPTIONAL_PKGS[@]}"
      enable_list "${ADVANCED_PKGS[@]}"
      green "[DONE] Restore selesai."
      pause
      ;;
    14) restore_from_backup; pause ;;
    15) show_log; pause ;;
    0) exit 0 ;;
    *) red "Pilihan tidak valid"; pause ;;
  esac
done
