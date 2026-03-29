<div align="center">

# Osiris Browser

**A privacy-first cross-platform browser with AES-256 encryption**

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-lightgrey)](https://flutter.dev/multi-platform)

</div>

---

## Features

### Privacy & Security

- **AES-256 encryption** — bookmarks, history, and settings encrypted at rest with a master password
- **Master password** — PBKDF2-SHA256 (200,000 iterations), derived key never stored in plaintext
- **Anti-fingerprinting** — Canvas, WebGL, AudioContext spoofing + timezone masking via injected JS
- **WebRTC blocking** — overrides `RTCPeerConnection` / `RTCDataChannel` to prevent IP leaks
- **Cookie control** — block all cookies (JS-level `document.cookie` override) or third-party only
- **User-Agent spoofing** — impersonate Chrome/Windows, Firefox/Windows, Safari/macOS, or mobile UA
- **JavaScript toggle** — disable JS site-wide
- **Tracker blocking** — built-in blocklist of major ad/analytics domains (Google, Meta, Twitter, etc.)
- **Biometric unlock** — fingerprint / Face ID via system prompt with master password fallback
- **Forgot password** — full data wipe from the unlock screen if master password is lost

### Browsing Experience

- **Persistent WebViews** — tabs never reload on home↔browser navigation (browser lives as an overlay, not a route)
- **Tab card switcher** — 3D perspective card manager with staggered entrance animations and per-card parallax tilt
- **Multi-tab browsing** — full tab lifecycle: open, close, switch, new tab
- **Smart address bar** — auto-detects URLs vs. search queries; 5 privacy-respecting search engines (DuckDuckGo, Brave, Startpage, SearXNG, Ecosia)
- **Encrypted bookmarks & history** — AES-256 storage, toggleable history saving
- **Scroll-away controls** — top/bottom bars hide on scroll, animate back on scroll up

### Data Control

- **NUKE button** — one-tap wipe of all bookmarks, history, and cache with countdown confirmation
- **Clear on exit** — auto-wipe when the app moves to the background or is closed (via lifecycle observer)
- **Auto-clear intervals** — 1 hour, 6 hours, 24 hours, or never (configurable timer)
- **Clear session data** — on-demand cache wipe from the in-browser menu

### UI & Customization

- **8 accent color presets** — Cosmic Purple, Electric Blue, Neon Green, Amber, Red, Pink, Cyan, Osiris
- **OLED-optimized** — pure black UI throughout with glass-morphism overlays
- **Smooth animations** — fade/slide on all overlays, staggered tab card entrance, browser fade-in/out
- **EN / RU localization**

---

## Screenshots

> Coming soon

---

## Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter | 3.24.5+ |
| Dart | 3.5.4+ |
| Android SDK | API 35 |
| Java | 17+ |
| Xcode | 15+ (macOS / iOS only) |
| CocoaPods | 1.14+ (macOS / iOS only) |

### Clone & run

```bash
git clone https://github.com/Br1zProject/osiris-browser.git
cd osiris-browser
flutter pub get
flutter run
```

### Build for all platforms

```bash
python3 build.py
```

The build script handles:

- Android APK / AAB with optional keystore signing
- iOS / macOS archive
- Windows and Linux desktop builds
- Environment check (Flutter, SDK, Java, Xcode versions)
- Cache cleanup (`build/`, Pods, DerivedData)

---

## Architecture

```
lib/
├── core/
│   ├── constants/       # App-wide constants, UA strings, search engines, tracker list
│   ├── l10n/            # EN/RU localization (AppStrings)
│   ├── router/          # GoRouter — home, privacy hub, settings
│   ├── security/        # AES-256 encryption, PBKDF2, platform-aware secure storage
│   ├── services/        # AppStateService (accent color, locale)
│   └── theme/           # AppTheme, AppColors (OLED palette)
├── data/
│   ├── datasources/     # SQLite via AppDatabase (sqflite)
│   └── repositories/    # BookmarkRepo, HistoryRepo, PrivacySettingsRepo
├── domain/
│   ├── entities/        # BrowserTab, PrivacySettings, Bookmark, HistoryEntry
│   ├── repositories/    # Abstract repository interfaces
│   └── usecases/        # SetupMasterPassword, VerifyMasterPassword, NukeAllData
└── presentation/
    ├── bloc/            # AuthBloc, BrowserBloc, PrivacyBloc
    ├── screens/         # Welcome, Home, Browser, PrivacyHub, Settings
    └── widgets/         # GlassCard, TabCardSwitcher, OsirisLogo, PasswordInput, ...
```

**State management:** BLoC (`flutter_bloc`) + Provider for theme/locale
**Navigation:** GoRouter — the browser screen is a persistent `Offstage`/`AnimatedOpacity` overlay so WebViews survive route transitions
**Storage:** SQLite + `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android, encrypted file on desktop)
**WebView:** `flutter_inappwebview` with one `InAppWebViewController` per tab, kept alive in an `IndexedStack`

---

## Security

| Mechanism | Implementation |
|-----------|----------------|
| Master password | PBKDF2-SHA256, 200,000 iterations, random 32-byte salt |
| Database encryption | AES-256-CBC; key derived from master password, stored in secure storage |
| Cookie blocking | JS `Object.defineProperty(document, 'cookie', { get:()=>'', set:()=>true })` injected on every page load |
| Anti-fingerprinting | JS overrides `HTMLCanvasElement.toDataURL`, `AudioContext`, WebGL parameter getters, navigator properties |
| WebRTC blocking | JS overrides `window.RTCPeerConnection` and `window.RTCDataChannel` to `undefined` |
| Tracker blocking | `shouldOverrideUrlLoading` callback cancels requests matching a built-in domain blocklist |
| Clear on exit | `WidgetsBindingObserver.didChangeAppLifecycleState` triggers cache wipe on `paused`/`detached` |
| Auto-clear | `Timer.periodic` drives timed cache + history wipe; restarts on interval change |
| Biometrics | `local_auth` system prompt; auth result gates master-password session |

> **DNS-over-HTTPS** is a system-level feature on iOS and Android and cannot be configured per-app via WebView.
> Enable it in **iOS Settings → Wi-Fi → DNS** or **Android Settings → Network → Private DNS**.

---

## Platform Notes

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ | APK + AAB, min API 21, target API 35 |
| iOS | ✅ | Requires Apple Developer account for device distribution |
| macOS | ✅ | Ad-hoc signed; no App Store sandbox restrictions |
| Windows | ✅ | Must be built on a Windows machine |
| Linux | ✅ | Must be built on a Linux machine |

---

## Author

Made by [@Br1zProject](https://t.me/Br1zProject)

---

## License

MIT — see [LICENSE](LICENSE) for details.
