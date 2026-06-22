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
# - Restore penuh / restore pilihan / restore dari backup
# ==========================================================

VERSION="3.1.0"

# --- Colors ---
C_BIRU="\033[1;36m"   # cyan
C_HIJAU="\033[1;32m"  # green
C_KUNING="\033[1;33m" # yellow
C_MERAH="\033[1;31m"  # red
C_ABU="\033[0;37m"    # grey
C_RESET="\033[0m"     # reset

# --- Animation Helpers ---
SPEED=0.006
ketik() {
  local teks="$1"; local d="${2:-$SPEED}"
  local i
  for ((i=0; i<${#teks}; i++)); do
    printf "%s" "${teks:$i:1}"
    sleep "$d" 2>/dev/null
  done
  echo
}

loading() {
  local teks="${1:-Memuat}"
  local spin='|/-\'
  local n=0
  while [ "$n" -lt 14 ]; do
    printf "\r${C_KUNING}%s %s...${C_RESET}" "${spin:$((n%4)):1}" "$teks"
    sleep 0.07 2>/dev/null
    n=$((n+1))
  done
  printf "\r${C_HIJAU}> %s... oke${C_RESET}   \n" "$teks"
}

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
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$ts] [$1] $2" >>"$LOG_FILE"
}

logo() {
  echo -e "${C_BIRU}"
  echo "  ┌────────────────────────────────────────────────┐"
  echo "  │          ███╗   ███╗██████╗ ██████╗           │"
  echo "  │          ████╗ ████║██╔══██╗██╔══██╗          │"
  echo "  │          ██╔████╔██║██║  ██║██████╔╝          │"
  echo "  │          ██║╚██╔╝██║██║  ██║██╔══██╗          │"
  echo "  │          ██║ ╚═╝ ██║██████╔╝██║  ██║          │"
  echo "  │          ╚═╝     ╚═╝╚═════╝ ╚═╝  ╚═╝          │"
  echo "  ├────────────────────────────────────────────────┤"
  echo -e "  │               ${C_HIJAU}MI Debloat Remover${C_BIRU}               │"
  echo -e "  │     ${C_ABU}Bersihkan bloatware Xiaomi tanpa root${C_BIRU}      │"
  echo -e "  │      ${C_ABU}------------------------------------${C_BIRU}      │"
  echo -e "  │    ${C_ABU}Website : ${C_BIRU}www.myrul.dev${C_BIRU}                     │"
  echo -e "  │    ${C_ABU}Facebook: ${C_BIRU}https://web.facebook.com/myruldev${C_BIRU} │"
  echo "  └────────────────────────────────────────────────┘"
  echo -e "${C_RESET}"
}

# --- Auto detect device / series / region ---
IS_XIAOMI=0
detect_device() {
  BRAND="$(run 'getprop ro.product.brand' 2>/dev/null | tr -d '\r')"
  MANU="$(run 'getprop ro.product.manufacturer' 2>/dev/null | tr -d '\r')"
  MODEL="$(run 'getprop ro.product.model' 2>/dev/null | tr -d '\r')"
  DEVICE="$(run 'getprop ro.product.device' 2>/dev/null | tr -d '\r')"
  MIUI="$(run 'getprop ro.miui.ui.version.name' 2>/dev/null | tr -d '\r')"
  HYPER="$(run 'getprop ro.hyperos.version' 2>/dev/null | tr -d '\r')"
  ANDR="$(run 'getprop ro.build.version.release' 2>/dev/null | tr -d '\r')"
  REGION="$(run 'getprop ro.miui.region' 2>/dev/null | tr -d '\r')"
  MODDEV="$(run 'getprop ro.product.mod_device' 2>/dev/null | tr -d '\r')"
  LOCALE="$(run 'getprop ro.product.locale.region' 2>/dev/null | tr -d '\r')"

  # Series
  SERIES="Unknown"
  if echo "$BRAND $MANU $MODEL" | grep -qiE "redmi"; then
    SERIES="Redmi"
  elif echo "$BRAND $MANU $MODEL" | grep -qiE "\bpoco\b"; then
    SERIES="POCO"
  elif echo "$BRAND $MANU $MODEL" | grep -qiE "xiaomi|\bmi\b"; then
    SERIES="Xiaomi"
  fi

  # Keluarga Xiaomi?
  if echo "$BRAND $MANU" | grep -qiE "xiaomi|redmi|poco"; then
    IS_XIAOMI=1
  else
    IS_XIAOMI=0
  fi

  # Region / varian ROM
  VARIANT="Unknown"
  local hint="${MODDEV,,} ${REGION,,} ${LOCALE,,}"
  if echo "$hint" | grep -qE "_eea|\beea\b|\beu\b"; then
    VARIANT="Global (EEA/Eropa)"
  elif echo "$hint" | grep -qE "_in\b|india|\bin\b"; then
    VARIANT="Global (India)"
  elif echo "$hint" | grep -qE "_id\b|indonesia|\bid\b"; then
    VARIANT="Global (Indonesia)"
  elif echo "$hint" | grep -qE "_global|global"; then
    VARIANT="Global"
  elif echo "$hint" | grep -qE "_cn\b|\bcn\b|china|mainland"; then
    VARIANT="China"
  elif [ -n "$MODDEV" ]; then
    VARIANT="Global"
  fi
}

# --- Statistik paket (total & disabled) ---
TOTAL_PKGS="?"
DISABLED_PKGS="?"
update_pkg_stats() {
  TOTAL_PKGS="$(run 'pm list packages' 2>/dev/null | tr -d '\r' | grep -c 'package:' || echo '?')"
  DISABLED_PKGS="$(run 'pm list packages -d' 2>/dev/null | tr -d '\r' | grep -c 'package:' || echo '0')"
}

show_device_info() {
  detect_device
  echo "Device : $MODEL ($DEVICE)"
  echo "Series : $SERIES"
  echo "Region : ${VARIANT}${REGION:+ [$REGION]}"
  echo "Android: $ANDR"
  if [ -n "$HYPER" ]; then
    echo "OS     : HyperOS $HYPER"
  else
    echo "OS     : MIUI ${MIUI:-unknown}"
  fi
  echo "Paket  : Total ${TOTAL_PKGS} • Disable ${DISABLED_PKGS}"
  if [ "$IS_XIAOMI" -ne 1 ]; then
    red "!! PERINGATAN: Perangkat ini TERDETEKSI BUKAN keluarga Xiaomi/Redmi/POCO."
    red "   Tool ini dibuat khusus untuk MIUI/HyperOS. Lanjut dengan risiko sendiri."
  fi
}

# Konfirmasi tambahan jika bukan Xiaomi
ensure_xiaomi_or_confirm() {
  if [ "$IS_XIAOMI" -ne 1 ]; then
    red "Perangkat bukan keluarga Xiaomi/Redmi/POCO."
    read -r -p "Tetap lanjutkan debloat? (y/n): " a
    [[ "$a" =~ ^[Yy]$ ]] || { yellow "Dibatalkan."; return 1; }
  fi
  return 0
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
  com.miui.msa.global
  com.miui.systemAdSolution
  com.miui.analytics
  com.miui.android.fashiongallery
  com.mfashiongallery.emag
  com.miui.bugreport
  com.miui.yellowpage
  com.miui.cleanmaster
  com.miui.miservice
  com.xiaomi.glgm
  com.miui.hybrid
  com.miui.hybrid.accessory
  com.miui.newhome
  com.facebook.system
  com.facebook.appmanager
  com.facebook.services
  com.facebook.katana
  com.google.android.apps.tachyon
  com.xiaomi.payment
  com.mipay.wallet.id
  com.google.android.apps.subscriptions.red
  com.google.android.videos
  com.google.android.feedback
  com.miui.miwallpaper.wallpaper
)

# Optional packages (disable only if you DON'T use them)
OPTIONAL_PKGS=(
  com.xiaomi.mipicks
  com.miui.browser
  com.mi.globalbrowser
  com.miui.videoplayer
  com.miui.video.global
  com.miui.player
  com.miui.weather2
  com.miui.notes
  com.miui.compass
  com.miui.fm
  com.miui.fmradio
  com.xiaomi.midrop
  com.google.android.projection.gearhead
  com.miui.cloudservice
  com.miui.cloudservice.sysapp
  com.miui.cloudbackup
  com.miui.micloudsync
  com.miui.mishare.connectivity
  com.xiaomi.scanner
  com.miui.screenrecorder
  com.xiaomi.vipaccount
  com.miui.virtualsim
  com.android.thememanager
)

# Advanced packages (WARNING: read comment first)
ADVANCED_PKGS=(
  com.xiaomi.joyose
  com.miui.daemon
  com.miui.powerkeeper
)

# --- Nama ramah paket (untuk Scan & Restore Pilihan) ---
declare -A PKG_NAME=(
  [com.miui.msa.global]="MIUI System Ads (MSA)"
  [com.miui.systemAdSolution]="MSA Core (Iklan Sistem)"
  [com.miui.analytics]="Analytics / Telemetri"
  [com.miui.android.fashiongallery]="Wallpaper Carousel"
  [com.mfashiongallery.emag]="Glance / Fashion Gallery"
  [com.miui.bugreport]="Bug Report"
  [com.miui.yellowpage]="Yellow Page"
  [com.miui.cleanmaster]="Cleaner (iklan)"
  [com.miui.miservice]="Services & Feedback"
  [com.xiaomi.glgm]="Game Center"
  [com.miui.hybrid]="Quick Apps"
  [com.miui.hybrid.accessory]="Quick Apps Accessory"
  [com.miui.newhome]="App Vault / News Feed"
  [com.facebook.system]="Facebook App Installer"
  [com.facebook.appmanager]="Facebook App Manager"
  [com.facebook.services]="Facebook Services"
  [com.facebook.katana]="Facebook (bawaan)"
  [com.google.android.apps.tachyon]="Google Meet/Duo"
  [com.xiaomi.payment]="Mi Pay"
  [com.mipay.wallet.id]="Mi Pay Wallet"
  [com.google.android.apps.subscriptions.red]="Google One"
  [com.google.android.videos]="Google TV / Movies"
  [com.google.android.feedback]="Google Feedback"
  [com.miui.miwallpaper.wallpaper]="Wallpaper Service"
  [com.xiaomi.mipicks]="GetApps (App Store)"
  [com.miui.browser]="Mi Browser"
  [com.mi.globalbrowser]="Mi Browser (Global)"
  [com.miui.videoplayer]="Mi Video"
  [com.miui.video.global]="Mi Video (Global)"
  [com.miui.player]="Mi Music"
  [com.miui.weather2]="Mi Weather"
  [com.miui.notes]="Mi Notes"
  [com.miui.compass]="Compass"
  [com.miui.fm]="FM Radio (HyperOS)"
  [com.miui.fmradio]="FM Radio (MIUI)"
  [com.xiaomi.midrop]="ShareMe"
  [com.google.android.projection.gearhead]="Android Auto"
  [com.miui.cloudservice]="Mi Cloud (core)"
  [com.miui.cloudservice.sysapp]="Mi Cloud (sysapp)"
  [com.miui.cloudbackup]="Mi Cloud Backup"
  [com.miui.micloudsync]="Mi Cloud Sync"
  [com.miui.mishare.connectivity]="Mi Share"
  [com.xiaomi.scanner]="Mi Scanner"
  [com.miui.screenrecorder]="Screen Recorder"
  [com.xiaomi.vipaccount]="Mi Community / VIP"
  [com.miui.virtualsim]="Virtual SIM"
  [com.android.thememanager]="Theme Store"
  [com.xiaomi.joyose]="Joyose (Game Perf)"
  [com.miui.daemon]="MiuiDaemon (Telemetri)"
  [com.miui.powerkeeper]="PowerKeeper (Baterai)"
)

# --- Helpers: status & pretty output ---
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*"; }

pkg_exists() { run "pm list packages $1" | grep -q "$1"; }
pkg_disabled() { run "pm list packages -d $1" | grep -q "$1"; }
pname() { echo "${PKG_NAME[$1]:-$1}"; }

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
    yellow "• Sudah disable: $(pname "$pkg")"
    return 0
  fi
  if run "pm disable-user --user 0 $pkg" >/dev/null 2>&1; then
    green "• Berhasil disable: $(pname "$pkg")"
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
    green "• Berhasil enable: $(pname "$pkg")"
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
    echo "# device : $MODEL ($DEVICE) / $SERIES / $VARIANT"
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
  loading "Memproses"
  for p in "$@"; do disable_pkg "$p"; done
  update_pkg_stats
}
enable_list() { for p in "$@"; do enable_pkg "$p"; done; update_pkg_stats; }

# --- Scan & Status (cepat, pakai 2x fetch list) ---
scan_status() {
  detect_device
  echo
  loading "Ngitung aplikasi"
  echo "[INFO] Scan status paket target di perangkat ini"
  echo "Legenda: [AKTIF] terpasang & aktif  |  [OFF] sudah disable  |  [-] tidak ada"
  echo "----------------------------------------------"
  local installed disabled
  installed="$(run 'pm list packages' 2>/dev/null | sed 's/package://g' | tr -d '\r')"
  disabled="$(run 'pm list packages -d' 2>/dev/null | sed 's/package://g' | tr -d '\r')"

  local groups=("SAFE" "OPTIONAL" "ADVANCED")
  local i=0
  for grp in "DEBLOAT_PKGS[@]" "OPTIONAL_PKGS[@]" "ADVANCED_PKGS[@]"; do
    eval "arr=(\"\${$grp}\")"
    echo
    yellow "== ${groups[$i]} =="
    for p in "${arr[@]}"; do
      if ! echo "$installed" | grep -qx "$p"; then
        printf "  [-]     %-34s %s\n" "$p" "$(pname "$p")"
      elif echo "$disabled" | grep -qx "$p"; then
        printf "  [OFF]   %-34s %s\n" "$p" "$(pname "$p")"
      else
        printf "  [AKTIF] %-34s %s\n" "$p" "$(pname "$p")"
      fi
    done
    i=$((i+1))
  done
  log "SCAN" "status scan executed"
}

# --- Restore Pilihan (pilih paket spesifik) ---
restore_selective() {
  detect_device
  echo
  echo "[INFO] Restore Pilihan — kembalikan paket tertentu yang sedang disable"
  local all=("${DEBLOAT_PKGS[@]}" "${OPTIONAL_PKGS[@]}" "${ADVANCED_PKGS[@]}")
  local disabled_raw
  disabled_raw="$(run 'pm list packages -d' 2>/dev/null | sed 's/package://g' | tr -d '\r')"

  local list=()
  declare -A seen
  local p
  for p in "${all[@]}"; do
    [ -n "${seen[$p]}" ] && continue
    seen[$p]=1
    if echo "$disabled_raw" | grep -qx "$p"; then
      list+=("$p")
    fi
  done

  if [ ${#list[@]} -eq 0 ]; then
    yellow "Tidak ada paket target yang sedang disable. Tidak ada yang perlu dipulihkan."
    return 0
  fi

  echo "Paket yang sedang DISABLE:"
  local i=1
  for p in "${list[@]}"; do
    printf "  %2d) %-34s %s\n" "$i" "$p" "$(pname "$p")"
    i=$((i+1))
  done
  echo "----------------------------------------------"
  echo "Ketik nomor yang ingin dipulihkan (pisahkan spasi, mis: 1 3 5)"
  echo "Ketik 'all' untuk semua, atau '0' untuk batal."
  read -r -p "Pilihan: " picks
  [ "$picks" = "0" ] && { yellow "Dibatalkan."; return 0; }

  if [ "$picks" = "all" ]; then
    enable_list "${list[@]}"
  else
    local n idx pk
    for n in $picks; do
      case "$n" in
        ''|*[!0-9]*) red "Lewati input tidak valid: $n"; continue ;;
      esac
      idx=$((n-1))
      pk="${list[$idx]}"
      if [ -n "$pk" ]; then enable_pkg "$pk"; else red "Lewati nomor di luar daftar: $n"; fi
    done
    update_pkg_stats
  fi
  green "[DONE] Restore pilihan selesai."
  log "RESTORE" "selective"
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
      green "[OK] Fixed performance mode: ON"; green "[DONE] Game Mode aktif."; log "GAME" "ON"
    else
      yellow "[WARN] Perintah performance mode gagal. Tetap lanjut (clean sudah)."
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
      green "[OK] Fixed performance mode: OFF"; green "[DONE] Game Mode nonaktif."; log "GAME" "OFF"
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
  echo; echo "[INFO] Execute: Ultra Battery ON"; ok=0
  run "settings put global master_sync_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global background_check_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global wifi_scan_always_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global ble_scan_always_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  if [ "$ok" -gt 0 ]; then green "[OK] Ultra Battery Mode aktif (applied: $ok)."; log "BATTERY" "ON ($ok)"
  else yellow "[WARN] Tidak ada setting yang berhasil diubah (mungkin dibatasi ROM)."; fi
  yellow "Catatan: Master sync dimatikan (email/photos bisa tidak auto-sync)."
}
ultra_off() {
  echo; echo "[INFO] Execute: Ultra Battery OFF (restore)"; ok=0
  run "settings put global master_sync_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global background_check_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global wifi_scan_always_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global ble_scan_always_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  if [ "$ok" -gt 0 ]; then green "[OK] Ultra Battery Mode dimatikan (applied: $ok)."; log "BATTERY" "OFF ($ok)"
  else yellow "[WARN] Tidak ada setting yang berhasil diubah (mungkin dibatasi ROM)."; fi
}

# --- Speed Up Animations ---
animation_fast() {
  echo; echo "[INFO] Execute: Speed Up Animations (0.5x)"; ok=0
  run "settings put global window_animation_scale 0.5" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global transition_animation_scale 0.5" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global animator_duration_scale 0.5" >/dev/null 2>&1 && ok=$((ok+1)) || true
  if [ "$ok" -gt 0 ]; then green "[OK] Animasi 0.5x (applied: $ok). HP terasa lebih cepat!"; log "ANIM" "0.5x"
  else yellow "[WARN] Gagal mengubah setting animasi (mungkin dibatasi ROM)."; fi
}
animation_normal() {
  echo; echo "[INFO] Execute: Restore Animations (1.0x)"; ok=0
  run "settings put global window_animation_scale 1.0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global transition_animation_scale 1.0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global animator_duration_scale 1.0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  if [ "$ok" -gt 0 ]; then green "[OK] Animasi dikembalikan ke 1.0x (applied: $ok)."; log "ANIM" "1.0x"
  else yellow "[WARN] Gagal mengubah setting animasi."; fi
}

# --- Monitor ---
show_top() {
  echo; echo "[INFO] Execute: Monitor RAM/CPU (top)"
  yellow "Tekan Ctrl+C untuk keluar"; sleep 1
  run "top -o RES,CPU,ARGS -s 10"
}

# --- Lihat Log ---
show_log() {
  echo; echo "[INFO] 30 baris terakhir log aksi ($LOG_FILE):"
  echo "----------------------------------------------"
  if [ -f "$LOG_FILE" ]; then tail -n 30 "$LOG_FILE"; else yellow "Belum ada log."; fi
}

# --- Restore dari file backup ---
restore_from_backup() {
  echo; echo "[INFO] Daftar file backup tersedia:"
  local files=("$BACKUP_DIR"/backup-*.txt)
  if [ ! -e "${files[0]}" ]; then yellow "Belum ada file backup."; return 0; fi
  local i=1
  for f in "${files[@]}"; do echo "  $i) $(basename "$f")"; i=$((i+1)); done
  read -r -p "Pilih nomor backup untuk di-restore (0 batal): " sel
  [ "$sel" = "0" ] && { yellow "Dibatalkan."; return 0; }
  local chosen="${files[$((sel-1))]}"
  if [ -z "$chosen" ] || [ ! -f "$chosen" ]; then red "Pilihan tidak valid."; return 0; fi
  echo "[INFO] Restore dari: $(basename "$chosen")"
  while IFS= read -r line; do
    case "$line" in
      ''|\#*) continue ;;
      *) enable_pkg "$line" ;;
    esac
  done <"$chosen"
  update_pkg_stats
  green "[DONE] Restore dari backup selesai."
  log "RESTORE" "from $(basename "$chosen")"
}

pause() { echo; read -r -p "Tekan Enter untuk lanjut..."; }

# ==========================================================
#  MULAI
# ==========================================================
log "START" "Aplikasi dijalankan"
logo
ketik "   Menyalakan MDR..." 0.02
loading "Cek perlengkapan"
sleep 0.2

# --- Init stats once ---
update_pkg_stats

# --- Main Menu ---
while true; do
  clear
  logo
  show_device_info
  echo "===================================="
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
  echo "13) Restore Debloat (Aktifkan kembali SEMUA paket)"
  echo "14) Restore PILIHAN (pilih app: Mi Music, Mi Video, dll)"
  echo "15) Restore dari File Backup"
  echo "16) Lihat Log Aksi"
  echo " 0) Keluar"
  echo "------------------------------------"
  read -r -p "Pilih (0-16): " c

  case "$c" in
    1) scan_status; pause ;;
    2)
      echo; echo "[INFO] Execute: Debloat AMAN"
      if ensure_xiaomi_or_confirm; then
        disable_list "${DEBLOAT_PKGS[@]}"; green "[DONE] Debloat aman selesai."
      fi
      pause ;;
    3)
      echo; echo "[INFO] Execute: Debloat AMAN + Optional"
      if ensure_xiaomi_or_confirm; then
        echo "== Safe =="; disable_list "${DEBLOAT_PKGS[@]}"
        echo; echo "== Optional =="; disable_list "${OPTIONAL_PKGS[@]}"
        green "[DONE] Debloat + optional selesai."
      fi
      pause ;;
    4)
      echo
      echo "[WARNING] Menonaktifkan Joyose/Daemon/PowerKeeper dapat menaikkan performa game"
      echo "namun pada versi HyperOS tertentu berisiko mengganggu sinkronisasi akun,"
      echo "refresh rate dinamis, atau manajemen baterai."
      read -r -p "Apakah Anda yakin ingin melanjutkan? (y/n): " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]] && ensure_xiaomi_or_confirm; then
        echo "[INFO] Execute: Debloat ADVANCED"
        disable_list "${ADVANCED_PKGS[@]}"; green "[DONE] Debloat advanced selesai."
      else
        yellow "Dibatalkan."
      fi
      pause ;;
    5) clean_now; pause ;;
    6) game_on; pause ;;
    7) game_off; pause ;;
    8) ultra_on; pause ;;
    9) ultra_off; pause ;;
    10) show_top; pause ;;
    11) animation_fast; pause ;;
    12) animation_normal; pause ;;
    13)
      echo; echo "[INFO] Execute: Restore Debloat (semua)"
      enable_list "${DEBLOAT_PKGS[@]}"
      enable_list "${OPTIONAL_PKGS[@]}"
      enable_list "${ADVANCED_PKGS[@]}"
      green "[DONE] Restore selesai."
      pause ;;
    14) restore_selective; pause ;;
    15) restore_from_backup; pause ;;
    16) show_log; pause ;;
    0) exit 0 ;;
    *) red "Pilihan tidak valid"; pause ;;
  esac
done
