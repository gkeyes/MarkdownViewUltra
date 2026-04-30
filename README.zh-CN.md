# Markdown View Ultra

[![Build](https://github.com/gkeyes/MarkdownViewUltra/actions/workflows/build.yml/badge.svg)](https://github.com/gkeyes/MarkdownViewUltra/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/gkeyes/MarkdownViewUltra)](https://github.com/gkeyes/MarkdownViewUltra/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> **一款轻量级、超精简的 Android Markdown 预览器**
> 通过分享或打开方式，快速预览 `.md` / `.markdown` / `.txt` 文件，无多余编辑功能，纯净专注。

[English](README.md) | **简体中文**

---

## ✨ 功能特性

- **📄 快速打开** — 在文件管理器中用「打开方式」直接打开 `.md` 文件
- **🎨 精美渲染** — GitHub 风格 Markdown，Material Design 3 主题
- **🌗 深色/浅色主题** — 自动跟随系统主题
- **🔗 可点击链接** — 点击链接自动在外部浏览器打开
- **🪶 极致轻量** — 纯预览，无编辑，无冗余
  - **APK 大小**：仅 **16 MB**（R8 优化，资源压缩）
  - **CSS 压缩**：单行化、简写属性、无注释
  - **图标摇树**：从 1645KB 降至 1.8KB
- **📱 Android 原生** — Flutter 构建，Material 3 自适应图标

## 📸 截图

| 深色模式 | 浅色模式 |
|---------|---------|
| ![深色](assets/screenshot-dark.png) | ![浅色](assets/screenshot-light.png) |

## 📦 下载

> **最新版本：** [v1.0.2](https://github.com/gkeyes/MarkdownViewUltra/releases/latest)

| 版本 | 大小 | 下载 |
|------|------|------|
| **v1.0.2** (最新) | 16 MB | [app-arm64-v8a-release.apk](https://github.com/gkeyes/MarkdownViewUltra/releases/download/v1.0.2/app-arm64-v8a-release.apk) |
| v1.0.1 | 16 MB | [Releases 页面](https://github.com/gkeyes/MarkdownViewUltra/releases) |
| v1.0.0 | 16 MB | [Releases 页面](https://github.com/gkeyes/MarkdownViewUltra/releases) |

## 🚀 快速开始

1. **下载** 最新 APK 从 [Releases](https://github.com/gkeyes/MarkdownViewUltra/releases/latest)
2. **安装** 到你的 Android 设备
3. **打开 `.md` 文件** — 长按任意 Markdown 文件 → 选择「打开方式」→ **Markdown View Ultra**

或者：
- 在任意应用中 **分享** Markdown 文件 → 选择 Markdown View Ultra

## 🔧 从源码构建

### 前置条件

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.41.6
- Android NDK / SDK

### 构建步骤

```bash
# 克隆仓库
git clone https://github.com/gkeyes/MarkdownViewUltra.git
cd MarkdownViewUltra

# 安装依赖
flutter pub get

# 构建 Debug APK
flutter build apk --debug

# 构建 Release APK（含 R8 压缩）
flutter build apk --release --split-per-abi
```

APK 生成在 `build/app/outputs/flutter-apk/` 目录。

### CI 自动构建

本仓库使用 **GitHub Actions** 自动构建 APK，每次推送到 `main` 分支都会自动触发：

1. 推送到 `main` 分支
2. 前往 [Actions 页面](https://github.com/gkeyes/MarkdownViewUltra/actions)
3. 下载 `release-apk` 产物

## 🏗️ 项目来源

**Markdown View Ultra** 是一个 **原创项目** —— **100% 纯 AI 生成**，从头构建，并非任何其他仓库的 Fork。整个代码库由 AI 编写，不含人工编写的代码。

技术栈：
- **Flutter** — 跨平台 UI 框架
- **flutter_markdown** — Markdown 解析与渲染
- **WebView** — 自定义 CSS 的 HTML 渲染
- **Android Intents** — 「打开方式」/「分享」集成

所有源代码均在当前仓库中。了解更多请查看 [Releases](https://github.com/gkeyes/MarkdownViewUltra/releases) 和 [提交历史](https://github.com/gkeyes/MarkdownViewUltra/commits/main)。

## 📜 版本历史

| 版本 | 日期 | 亮点 |
|------|------|------|
| **v1.0.2** | 2026-04-30 | 图标居中修复，# 符号优化 |
| **v1.0.1** | 2026-04-30 | 开启 R8 压缩、CSS 压缩、自适应图标，APK 16MB |
| **v1.0.0** | 2026-04-30 | 初始发布，Flutter + WebView Markdown 预览 |

## 📄 许可证

MIT — 详见 [LICENSE](LICENSE) 文件。

---

*用 ❤️ 打造，为 Android 提供轻量快速的 Markdown 预览体验。*