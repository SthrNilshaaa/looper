<p align="center">
  <table align="center">
    <tr>
      <td bgcolor="#2e2e2e" align="center" style="padding: 12px; border-radius: 16px;">
        <img src="assets/main_logo.svg" width="240" height="96" />
      </td>
    </tr>
  </table>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Android-blueviolet?style=for-the-badge&logo=linux&logoColor=white" />
  <img src="https://img.shields.io/badge/UI--UX-Glassmorphism%20%2F%20Neo--Blur-FF007F?style=for-the-badge&logo=figma&logoColor=white" />
  <img src="https://img.shields.io/badge/Built%20With-Flutter%20%26%20Dart-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/github/v/release/SthrNilshaaa/looper?style=for-the-badge&logo=GitHub&color=%23000000"/>
  <img src="https://img.shields.io/github/downloads/SthrNilshaaa/looper/total?style=for-the-badge&logo=GitHub&color=%23000000"/>
  <img src="https://img.shields.io/github/stars/SthrNilshaaa/looper?style=for-the-badge&logo=GitHub&color=%23000000"/>
  <img src="https://img.shields.io/github/forks/SthrNilshaaa/looper?style=for-the-badge&logo=GitHub&color=%23000000"/>
  <img src="https://img.shields.io/badge/License-GPL--3.0-green?style=for-the-badge" />
</p>

---

## 🔮 Experience Music in Cyber-Glass Aesthetics

**Looper Player** is a state-of-the-art, high-fidelity local music player engineered for both **Android** and **Linux**. It redefines local music playback by wrapping a high-performance audio engine in a futuristic **Glassmorphic** interface that adapts instantly to the album art of whatever you are listening to.

Designed with an **offline-first, private-by-default** philosophy, Looper Player keeps your library, lyrics, playback statistics, and custom configurations safely on your local device—completely independent of external telemetry or subscription models.

---

## 🚀 Key Features

```
┌────────────────────────────────────────────────────────────────────────┐
│                        LOOPER PLAYER FEATURES                          │
├───────────────────────────────────────┬────────────────────────────────┤
│ 🔮 GLASSMORPHIC CYBER-UI              │ ⚡ ULTRA-PERFORMANT ENGINE     │
│   Full real-time blur and glowing     │   Sub-millisecond local scans, │
│   gradients that match album art.     │   indexing libraries of 50k+.  │
├───────────────────────────────────────┼────────────────────────────────┤
│ 🎤 SYNCHRONIZED LRC LYRICS            │ 📱 CROSS-PLATFORM PARITY       │
│   Real-time fluid line animations     │   Seamlessly engineered for    │
│   and interactive lyrics search.      │   both Linux and Android.      │
├───────────────────────────────────────┼────────────────────────────────┤
│ 🔒 100% PRIVATE & OFFLINE             │ 🎵 CUSTOMIZABLE AUDIO CONTROL  │
│   Zero trackers. Zero telemetry.      │   Gapless playback and advanced│
│   All data stays local.               │   audio focus management.      │
└───────────────────────────────────────┴────────────────────────────────┘
```

- **Dynamic Theme & Neo-Blur Aesthetics**: The entire interface—buttons, borders, text accents, and ambient background blurs—morphs dynamically to blend beautifully with the album art of the active song, featuring smooth crossfade transitions.
- **Advanced Lyrics Engine**: Synchronized scrolling LRC lyrics with dynamic, tactile line-by-line animations, interactive tap-to-seek playback integration, font scaling, and display keep-awake modes.
- **Resilient Offline File Operations**: Full audio engine state release and file-lock management when renaming or deleting tracks on local storage, backed by immediate, colorful alerts through custom glassmorphic SnackBars.
- **Fully Responsive & Adaptive Layouts**: The dashboard and detail pages (such as the playlist header) intelligently reflow between horizontal rows and vertical columns to fit perfectly on standard, large, and extremely narrow devices alike.
- **Sub-Second Search & Local Library Scans**: Instant global scanning and indexing of 50k+ local libraries, with micro-latency search matching song titles, artists, albums, and even specific lyric phrases.
- **Interactive Android & Linux Parity**: Native media keys, MPRIS controls on Linux, automatic audio focus transitions, and beautiful permission onboarding on Android.

---

## 📸 Gallery

<details>
<summary><b>📐 Click to View App Design & Screenshots</b></summary>
<br/>

<p align="center">
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-31-38.png" width="49%" alt="Main Dashboard" />
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-40-26.png" width="49%" alt="Player View" />
</p>
<p align="center">
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-31-46.png" width="32%" />
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-32-19.png" width="32%" />
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-32-45.png" width="32%" />
</p>
<p align="center">
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-33-14.png" width="32%" />
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-33-28.png" width="32%" />
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-34-16.png" width="32%" />
</p>
<p align="center">
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-35-40.png" width="32%" />
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-36-46.png" width="32%" />
  <img src="assets/SS_looper/Screenshot From 2026-05-09 11-37-16.png" width="32%" />
</p>

</details>

---

## 🛠️ The Tech Stack

```
        ┌────────────────────────────────────────────────────────┐
        │                  LOOPER ARCHITECTURE                   │
        ├────────────────────────────────────────────────────────┤
        │  UI Framework      │  Flutter & Dart (Neo-Material 3)  │
        ├────────────────────┼───────────────────────────────────┤
        │  Database          │  Isar DB (High-Speed Local SQL)   │
        ├────────────────────┼───────────────────────────────────┤
        │  Playback (Linux)  │  Media Kit (C-bindings to libmpv) │
        ├────────────────────┼───────────────────────────────────┤
        │  Playback (Android)│  Native Kotlin Audio Handler      │
        ├────────────────────┼───────────────────────────────────┤
        │  State Manager     │  Riverpod (Immutable Observables) │
        └────────────────────┴───────────────────────────────────┘
```

---

## 📦 Installation & Setup

Download the signed production build for your specific platform from our [Releases](https://github.com/SthrNilshaaa/looper/releases) page.

### 📱 Android (`.apk`)
We distribute clean, cryptographically signed production APKs built directly on our automated pipeline:
- **Download the APK** matching your architecture (e.g. `arm64-v8a` for modern smartphones, `armeabi-v7a` for older devices, or `x86_64` for emulators).
- Open the package and tap **Install** (ensure "Install from Unknown Sources" is enabled in your Android settings).

---

### 💻 Linux Packages

We provide packages for all major Linux distributions:

#### 📂 Debian / Ubuntu / Mint (`.deb`)
```bash
sudo apt install ./looper-player.deb
```

#### 📂 Fedora / RHEL / CentOS (`.rpm`)
```bash
# Fedora
sudo dnf install ./looper-player.rpm
# openSUSE
sudo zypper install ./looper-player.rpm
```

#### 🚀 AppImage (Universal standalone)
No installation required. Works on almost any modern Linux distribution out of the box:
```bash
chmod +x looper-player.AppImage
./looper-player.AppImage
```

#### 📂 Portable Archive (`.tar.gz`)
Great for "extract-and-run" setups or custom user directories:
```bash
tar -xzvf looper-player-linux.tar.gz
cd universal
./run.sh
```

---

## 👥 Contributors & Open Source

A massive thank you to the brilliant creators behind Looper Player and the open-source libraries that make it possible:

### Core Project Team
* **Nilesh Suthar** — *Lead Architect & Lead Developer*
* **Karan Suthar** — *Creative UI/UX & Interaction Designer*

---

## 📄 License

This project is licensed under the GPL-3.0 License.

---

## 📬 Contact & Channels

Connect with the developers for feature requests, bug reports, or discussion:

**Nilesh Suthar**
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/SthrNilshaaa)
[![Telegram](https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/neelshy)

