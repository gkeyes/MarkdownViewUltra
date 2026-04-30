# Markdown View Ultra

[![Build](https://github.com/gkeyes/MarkdownViewUltra/actions/workflows/build.yml/badge.svg)](https://github.com/gkeyes/MarkdownViewUltra/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/gkeyes/MarkdownViewUltra)](https://github.com/gkeyes/MarkdownViewUltra/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> **A lightweight, ultra-slim Markdown previewer APK for Android.**
> Open `.md` / `.markdown` / `.txt` files via Android's "Share" or "Open with" — instant preview, no editing clutter.

**English** | [简体中文](README.zh-CN.md)

---

## ✨ Features

- **📄 Quick Open** — Open any `.md` file from any file manager using "Open with"
- **🎨 Beautiful Rendering** — GitHub-flavored Markdown with Material Design 3 styling
- **🌗 Dark/Light Theme** — Automatically follows system theme
- **🔗 Clickable Links** — Tap links, they open externally
- **🪶 Ultra Lightweight** — Pure preview, no editing, no bloating
  - **APK size**: only **16 MB** (R8 optimized, resources shrunk)
  - **CSS compressed**: single-line, shorthand properties, no comments
  - **Tree-shaken icons**: from 1645KB down to 1.8KB
- **📱 Built for Android** — Native Flutter app with Material 3 adaptive icon

## 📸 Preview

| Dark Mode | Light Mode |
|-----------|------------|
| ![Dark](assets/screenshot-dark.png) | ![Light](assets/screenshot-light.png) |

## 📦 Download

> **Latest release:** [v1.0.1](https://github.com/gkeyes/MarkdownViewUltra/releases/latest)

| Version | Size | Download |
|---------|------|----------|
| **v1.0.1** (latest) | 16 MB | [app-arm64-v8a-release.apk](https://github.com/gkeyes/MarkdownViewUltra/releases/download/v1.0.1/app-arm64-v8a-release.apk) |
| v1.0.0 | 16 MB | [Releases page](https://github.com/gkeyes/MarkdownViewUltra/releases) |

## 🚀 Quick Start

1. **Download** the latest APK from [Releases](https://github.com/gkeyes/MarkdownViewUltra/releases/latest)
2. **Install** on your Android device
3. **Open a `.md` file** — long-press any Markdown file in your file manager → "Open with" → select **Markdown View Ultra"

Or:
- **Share** a Markdown file from any app → pick Markdown View Ultra

## 🔧 Build from Source

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.41.6
- Android NDK / SDK

### Steps

```bash
# Clone the repository
git clone https://github.com/gkeyes/MarkdownViewUltra.git
cd MarkdownViewUltra

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK (with R8 minification)
flutter build apk --release --split-per-abi
```

The APK will be at `build/app/outputs/flutter-apk/`.

### CI Build

This repository uses **GitHub Actions** to build the APK automatically on every push to `main`:

1. Push to `main` branch
2. Go to the [Actions tab](https://github.com/gkeyes/MarkdownViewUltra/actions)
3. Download the `release-apk` artifact

## 🏗️ Project Origin

**Markdown View Ultra** is an **original project** — built from scratch as a custom Flutter app, not a fork of any other repository.

The app was developed with:
- **Flutter** — cross-platform UI framework
- **flutter_markdown** — Markdown parsing & rendering
- **WebView** — HTML rendering with custom CSS
- **Android Intents** — "Open with" / "Share" integration

All source code is in this repository. For the latest updates, check the [Releases](https://github.com/gkeyes/MarkdownViewUltra/releases) and [Commits](https://github.com/gkeyes/MarkdownViewUltra/commits/main).

## 📜 Version History

| Version | Date | Highlights |
|---------|------|------------|
| **v1.0.1** | 2026-04-30 | R8 enabled, CSS minified, adaptive icon, 16 MB APK |
| **v1.0.0** | 2026-04-30 | Initial release, Flutter + WebView Markdown preview |

## 📄 License

MIT — see [LICENSE](LICENSE) for details.

---

*Made with ❤️ for a lightweight, fast Markdown preview experience on Android.*