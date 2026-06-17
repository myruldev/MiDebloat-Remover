# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog,
and this project adheres to Semantic Versioning.

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
