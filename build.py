#!/usr/bin/env python3
"""
Osiris Browser — cross-platform build script.
Works on macOS and Windows.
"""
import os
import subprocess
import sys
import shutil
import json
import glob
import platform
import getpass

IS_WIN  = platform.system() == "Windows"
IS_MAC  = platform.system() == "Darwin"
PROJECT = os.path.dirname(os.path.abspath(__file__))
SEP     = ";" if IS_WIN else ":"

PATHS_CFG    = os.path.join(PROJECT, ".build_config.json")
KEYSTORE_CFG = os.path.join(PROJECT, ".keystore_config.json")

# ── Автодетект ────────────────────────────────────────────────────────────────
def _detect_flutter():
    f = shutil.which("flutter")
    if f: return f
    for c in [
        os.path.expanduser("~/development/flutter/bin/flutter"),
        os.path.expanduser("~/flutter/bin/flutter"),
        "C:/flutter/bin/flutter.bat",
        "C:/src/flutter/bin/flutter.bat",
    ]:
        if os.path.exists(c): return c
    return ""

def _detect_java():
    jh = os.environ.get("JAVA_HOME")
    if jh and os.path.exists(jh): return jh
    mise = os.path.expanduser("~/.local/share/mise/installs/java")
    if os.path.isdir(mise):
        for pat in ["17*", "11*", "21*"]:
            found = sorted(glob.glob(os.path.join(mise, pat)), reverse=True)
            if found: return found[0]
    for c in [
        os.path.expanduser("~/Applications/Android Studio.app/Contents/jbr/Contents/Home"),
        "/Applications/Android Studio.app/Contents/jbr/Contents/Home",
        "C:/Program Files/Android/Android Studio/jbr",
    ]:
        if os.path.exists(c): return c
    return ""

def _detect_android():
    sdk = os.environ.get("ANDROID_HOME") or os.environ.get("ANDROID_SDK_ROOT")
    if sdk and os.path.exists(sdk): return sdk
    for c in [
        os.path.expanduser("~/Library/Android/sdk"),
        os.path.expanduser("~/Android/Sdk"),
        os.path.expandvars("%LOCALAPPDATA%/Android/Sdk"),
    ]:
        if os.path.exists(c): return c
    return ""

def _detect_pod():
    p = shutil.which("pod")
    if p: return p
    mise = os.path.expanduser("~/.local/share/mise/installs/ruby")
    if os.path.isdir(mise):
        pods = sorted(glob.glob(os.path.join(mise, "*", "bin", "pod")), reverse=True)
        if pods: return pods[0]
    return ""

def _detect_ndk(android_home):
    if not android_home: return ""
    ndk_dir = os.path.join(android_home, "ndk")
    if os.path.isdir(ndk_dir):
        versions = sorted(glob.glob(os.path.join(ndk_dir, "*")), reverse=True)
        if versions: return versions[0]
    return ""

def autodetect_paths():
    android = _detect_android()
    return {
        "flutter":      _detect_flutter(),
        "java_home":    _detect_java(),
        "android_sdk":  android,
        "android_ndk":  _detect_ndk(android),
        "pod":          _detect_pod(),
        "ssl_cert":     "/etc/ssl/cert.pem" if IS_MAC else "",
    }

# ── Конфиг путей ──────────────────────────────────────────────────────────────
def load_paths():
    if os.path.exists(PATHS_CFG):
        with open(PATHS_CFG) as f:
            saved = json.load(f)
        # Дополняем новыми ключами если их нет
        detected = autodetect_paths()
        for k, v in detected.items():
            if k not in saved:
                saved[k] = v
        return saved
    return autodetect_paths()

def save_paths(p):
    with open(PATHS_CFG, "w") as f:
        json.dump(p, f, indent=2)

def build_env(p):
    e = os.environ.copy()
    if p.get("java_home"):
        e["JAVA_HOME"] = p["java_home"]
    if p.get("android_sdk"):
        e["ANDROID_HOME"]     = p["android_sdk"]
        e["ANDROID_SDK_ROOT"] = p["android_sdk"]
    if p.get("android_ndk"):
        e["ANDROID_NDK_HOME"] = p["android_ndk"]
    if p.get("ssl_cert") and os.path.exists(p["ssl_cert"]):
        e["SSL_CERT_FILE"] = p["ssl_cert"]

    parts = []
    if p.get("java_home"):
        parts.append(os.path.join(p["java_home"], "bin"))
    if p.get("flutter"):
        parts.append(os.path.dirname(p["flutter"]))
    if p.get("android_sdk"):
        parts.append(os.path.join(p["android_sdk"], "cmdline-tools", "latest", "bin"))
        parts.append(os.path.join(p["android_sdk"], "platform-tools"))
    if p.get("pod"):
        pod_bin = os.path.dirname(p["pod"])
        if pod_bin: parts.append(pod_bin)
    parts.append(e.get("PATH", ""))
    e["PATH"] = SEP.join(parts)
    return e

# Глобальные переменные — пересобираются при изменении путей
_paths = load_paths()
_env   = build_env(_paths)

def paths(): return _paths
def env():   return _env

def reload_paths():
    global _paths, _env
    _paths = load_paths()
    _env   = build_env(_paths)

# ── Утилиты ───────────────────────────────────────────────────────────────────
def run(cmd, fail_ok=False):
    print(f"\n▶ {' '.join(str(c) for c in cmd)}\n")
    result = subprocess.run(cmd, env=env())
    ok_r = result.returncode == 0
    print("\n✓ Готово" if ok_r else f"\n✗ Ошибка (exit {result.returncode})")
    if not ok_r and not fail_ok:
        sys.exit(result.returncode)
    return ok_r

def G(t): return f"\033[92m✓\033[0m {t}"
def R(t): return f"\033[91m✗\033[0m {t}"
def Y(t): return f"\033[93m!\033[0m {t}"

def load_ks_cfg():
    if os.path.exists(KEYSTORE_CFG):
        with open(KEYSTORE_CFG) as f: return json.load(f)
    return {}

def save_ks_cfg(cfg):
    with open(KEYSTORE_CFG, "w") as f: json.dump(cfg, f, indent=2)

def pause(): input("\nНажми Enter для возврата...")

# ── Настройка путей ───────────────────────────────────────────────────────────
PATH_LABELS = {
    "flutter":     "Flutter (путь к бинарнику)",
    "java_home":   "Java Home (JDK 17+)",
    "android_sdk": "Android SDK",
    "android_ndk": "Android NDK (опционально)",
    "pod":         "CocoaPods (pod)",
    "ssl_cert":    "SSL-сертификат (macOS)",
}

def paths_menu():
    while True:
        p = paths()
        print("\n╔══════════════════════════════════════════════════════════════╗")
        print("║                  НАСТРОЙКА ПУТЕЙ                           ║")
        print("╠══════════════════════════════════════════════════════════════╣")
        items = list(PATH_LABELS.items())
        for i, (key, label) in enumerate(items, 1):
            val  = p.get(key, "")
            exists = os.path.exists(val) if val else False
            icon = "✓" if exists else ("!" if val else "✗")
            short = (val[:48] + "…") if len(val) > 49 else val
            print(f"║  {i}. [{icon}] {label:<28} ║")
            print(f"║      {short:<56}║")
        print("╠══════════════════════════════════════════════════════════════╣")
        print("║  A. Автодетект всех путей                                   ║")
        print("║  R. Сбросить к автодетекту (удалить конфиг)                ║")
        print("║  S. Сохранить и выйти                                       ║")
        print("║  0. Назад (без сохранения)                                  ║")
        print("╚══════════════════════════════════════════════════════════════╝")

        choice = input("Выбор: ").strip().upper()

        if choice == "0":
            break
        elif choice == "S":
            save_paths(p)
            reload_paths()
            print(G("Пути сохранены"))
            break
        elif choice == "A":
            detected = autodetect_paths()
            _paths.update(detected)
            _env.update(build_env(_paths))
            print(G("Автодетект завершён — проверь пути и нажми S для сохранения"))
        elif choice == "R":
            if os.path.exists(PATHS_CFG):
                os.remove(PATHS_CFG)
            reload_paths()
            print(G("Конфиг удалён, пути определены автоматически"))
        elif choice.isdigit():
            idx = int(choice) - 1
            if 0 <= idx < len(items):
                key, label = items[idx]
                cur = p.get(key, "")
                print(f"\n  {label}")
                print(f"  Текущее: {cur or '(не задан)'}")
                new_val = input("  Новое значение (Enter = оставить): ").strip()
                if new_val:
                    if not os.path.exists(new_val):
                        print(Y(f"Путь не найден: {new_val} — сохранено, но проверь"))
                    _paths[key] = new_val
                    _env.update(build_env(_paths))

# ── Тест состояния ────────────────────────────────────────────────────────────
def status():
    p = paths()
    print("\n╔══════════════════════════════════════════════╗")
    print("║         СОСТОЯНИЕ ОКРУЖЕНИЯ                 ║")
    print("╚══════════════════════════════════════════════╝")

    # Flutter
    print("\n[Flutter]")
    flutter = p.get("flutter", "")
    fl_ok = bool(flutter) and os.path.exists(flutter)
    print(f"  {G(flutter) if fl_ok else R(flutter or 'не найден')}")
    if fl_ok:
        r = subprocess.run([flutter, "--version"], capture_output=True, text=True, env=env())
        lines = (r.stdout or r.stderr).splitlines()
        if lines: print(f"    {lines[0]}")

    # Android
    print("\n[Android]")
    java = p.get("java_home", "")
    print(f"  {G('Java: ' + java) if os.path.exists(java) else R('Java: ' + (java or 'не найдена'))}")
    sdk  = p.get("android_sdk", "")
    print(f"  {G('SDK: ' + sdk) if os.path.exists(sdk) else R('SDK: ' + (sdk or 'не найден'))}")
    if sdk and os.path.exists(sdk):
        tools = os.path.join(sdk, "cmdline-tools", "latest", "bin", "sdkmanager" + (".bat" if IS_WIN else ""))
        print(f"  {G('cmdline-tools') if os.path.exists(tools) else R('cmdline-tools: отсутствует')}")
        bt = sorted(glob.glob(os.path.join(sdk, "build-tools", "*")))
        print(f"  {G('build-tools: ' + os.path.basename(bt[-1])) if bt else R('build-tools: нет')}")
    ndk = p.get("android_ndk", "")
    if ndk:
        print(f"  {G('NDK: ' + os.path.basename(ndk)) if os.path.exists(ndk) else Y('NDK: не найден')}")
    ks_cfg = load_ks_cfg()
    ks = ks_cfg.get("keystore_path", "")
    print(f"  {G('keystore: ' + ks) if (ks and os.path.exists(ks)) else Y('keystore: не настроен')}")
    apk = os.path.join(PROJECT, "build/app/outputs/flutter-apk/app-release.apk")
    if os.path.exists(apk):
        print(f"  {G(f'APK: {os.path.getsize(apk)//1024//1024} MB')}")

    # iOS / macOS
    if IS_MAC:
        print("\n[iOS / macOS]")
        xcode = shutil.which("xcodebuild")
        print(f"  {G('Xcode') if xcode else R('Xcode: не найден')}")
        if xcode:
            r = subprocess.run(["xcodebuild", "-version"], capture_output=True, text=True)
            if r.stdout: print(f"    {r.stdout.splitlines()[0]}")
        pod = p.get("pod", "")
        pod_ok = bool(pod) and os.path.exists(pod)
        print(f"  {G('CocoaPods: ' + pod) if pod_ok else R('CocoaPods: не найден')}")
        r = subprocess.run(["xcrun", "--sdk", "iphoneos", "--show-sdk-version"],
                           capture_output=True, text=True)
        print(f"  {G('iOS SDK: ' + r.stdout.strip()) if r.returncode == 0 else R('iOS SDK: не найден')}")
        ssl = p.get("ssl_cert", "")
        print(f"  {G('SSL cert') if (ssl and os.path.exists(ssl)) else Y('SSL cert: не найден')}")
        for pat, label in [
            ("build/macos/Build/Products/Release/osiris_browser.app", "macOS .app"),
            ("build/ios/iphoneos/*.app", "iOS .app"),
        ]:
            if glob.glob(os.path.join(PROJECT, pat)):
                print(f"  {G(label + ' собран')}")

    # Windows
    print("\n[Windows]")
    if IS_WIN:
        exe = os.path.join(PROJECT, "build/windows/runner/Release/osiris_browser.exe")
        print(f"  {G('.exe собран') if os.path.exists(exe) else Y('.exe не собран')}")
    else:
        print(f"  {Y('Сборка только на Windows')}")

    # Linux
    print("\n[Linux]")
    IS_LINUX = platform.system() == "Linux"
    linux_dir = os.path.join(PROJECT, "linux")
    print(f"  {G('linux/ папка есть') if os.path.isdir(linux_dir) else R('linux/ не создана (flutter create --platforms=linux .)')}")
    if IS_LINUX:
        bundle = os.path.join(PROJECT, "build/linux/x64/release/bundle/osiris_browser")
        if os.path.exists(bundle):
            print(f"  {G('bundle собран')}")
    else:
        print(f"  {Y('Сборка только на Linux')}")

    print()
    pause()

# ── Сборки ────────────────────────────────────────────────────────────────────
def build_android():
    mode = input("Mode [release/debug] (default: release): ").strip() or "release"
    fmt  = input("Format [apk/appbundle] (default: apk): ").strip() or "apk"
    run([paths()["flutter"], "build", fmt, f"--{mode}"])
    out = os.path.join(PROJECT, "build/app/outputs/flutter-apk/") if fmt == "apk" \
          else os.path.join(PROJECT, "build/app/outputs/bundle/")
    print(f"\nOutput: {out}")

def build_ios():
    if not IS_MAC:
        print(R("iOS сборка только на macOS")); return
    sign = input("Code sign? [y/N]: ").strip().lower() == "y"
    args = [paths()["flutter"], "build", "ios"]
    if not sign: args.append("--no-codesign")
    run(args)

def build_macos():
    if not IS_MAC:
        print(R("macOS сборка только на macOS")); return
    mode = input("Mode [release/debug] (default: release): ").strip() or "release"
    run([paths()["flutter"], "build", "macos", f"--{mode}"])
    print(f"\nOutput: {os.path.join(PROJECT, 'build/macos/Build/Products/Release/osiris_browser.app')}")

def build_windows():
    if not IS_WIN:
        print(Y("Windows сборка возможна только на Windows."))
        print("На Windows запусти: flutter build windows --release")
        pause(); return
    mode = input("Mode [release/debug] (default: release): ").strip() or "release"
    run([paths()["flutter"], "build", "windows", f"--{mode}"])
    print(f"\nOutput: {os.path.join(PROJECT, 'build/windows/runner/Release/')}")

def open_xcode():
    if not IS_MAC:
        print(R("Xcode доступен только на macOS")); return
    xcworkspace = os.path.join(PROJECT, "ios", "Runner.xcworkspace")
    if not os.path.exists(xcworkspace):
        print(R(f"Файл не найден: {xcworkspace}"))
        print(Y("Сначала выполни: flutter build ios --no-codesign"))
        return
    print(f"Открываю: {xcworkspace}")
    subprocess.Popen(["open", xcworkspace])
    print(G("Xcode запущен"))

def build_linux():
    IS_LINUX = platform.system() == "Linux"
    if not IS_LINUX:
        print(Y("Linux сборка возможна только на Linux."))
        print("На Linux запусти: flutter build linux --release")
        linux_dir = os.path.join(PROJECT, "linux")
        if not os.path.isdir(linux_dir):
            print(Y("Папка linux/ не найдена. Создай её командой:"))
            print(f"  {paths().get('flutter','flutter')} create --platforms=linux .")
        pause(); return
    linux_dir = os.path.join(PROJECT, "linux")
    if not os.path.isdir(linux_dir):
        print(Y("Папка linux/ не найдена. Создаём..."))
        run([paths()["flutter"], "create", "--platforms=linux", "."], fail_ok=True)
    mode = input("Mode [release/debug] (default: release): ").strip() or "release"
    run([paths()["flutter"], "build", "linux", f"--{mode}"])
    print(f"\nOutput: {os.path.join(PROJECT, 'build/linux/x64/release/bundle/')}")

# ── Подписи ───────────────────────────────────────────────────────────────────
def sign_menu():
    while True:
        cfg   = load_ks_cfg()
        ks    = cfg.get("keystore_path", "не задан")
        alias = cfg.get("key_alias",     "не задан")
        short = (ks[:28] + "…") if len(ks) > 29 else ks

        print("\n╔══════════════════════════════════════════════╗")
        print("║         ПОДПИСИ И СЕРТИФИКАТЫ               ║")
        print("╠══════════════════════════════════════════════╣")
        print(f"║  Keystore: {short:<34}║")
        print(f"║  Алиас:    {alias:<34}║")
        print("╠══════════════════════════════════════════════╣")
        print("║  1. Сгенерировать новый Android keystore    ║")
        print("║  2. Указать существующий keystore           ║")
        print("║  3. Применить подпись в build.gradle        ║")
        print("║  4. Инфо о текущем keystore                 ║")
        print("║  5. iOS: инструкция по подписи              ║")
        print("║  0. Назад                                   ║")
        print("╚══════════════════════════════════════════════╝")

        c = input("Выбор: ").strip()
        if c == "0":  break
        elif c == "1": generate_keystore()
        elif c == "2": select_keystore()
        elif c == "3": apply_to_gradle()
        elif c == "4": show_keystore_info()
        elif c == "5": ios_signing_info()

def _keytool():
    jh = paths().get("java_home", "")
    kt = os.path.join(jh, "bin", "keytool" + (".exe" if IS_WIN else "")) if jh else ""
    return kt if os.path.exists(kt) else "keytool"

def generate_keystore():
    print("\n── Генерация Android Keystore ──")
    default = os.path.join(PROJECT, "android", "app", "key.jks")
    path    = input(f"Путь [{default}]: ").strip() or default
    alias   = input("Key alias [key]: ").strip() or "key"
    days    = input("Срок действия (дней) [10000]: ").strip() or "10000"
    dname   = input("DN [CN=Osiris, O=BrizProject, C=RU]: ").strip() or "CN=Osiris, O=BrizProject, C=RU"
    store_pass = getpass.getpass("Store password (мин. 6 симв.): ")
    if len(store_pass) < 6:
        print(R("Пароль слишком короткий")); return
    key_pass = getpass.getpass("Key password (Enter = тот же): ") or store_pass
    cmd = [_keytool(), "-genkey", "-v",
           "-keystore", path, "-alias", alias,
           "-keyalg", "RSA", "-keysize", "2048",
           "-validity", days, "-dname", dname,
           "-storepass", store_pass, "-keypass", key_pass]
    result = subprocess.run(cmd, env=env())
    if result.returncode == 0:
        cfg = load_ks_cfg()
        cfg.update({"keystore_path": path, "key_alias": alias,
                    "store_password": store_pass, "key_password": key_pass})
        save_ks_cfg(cfg)
        print(f"\n{G('Keystore создан: ' + path)}")
        print(Y("Не добавляй key.jks в git! (уже в .gitignore)"))
    else:
        print(R("Ошибка генерации"))

def select_keystore():
    print("\n── Указать существующий keystore ──")
    path = input("Путь к .jks/.keystore: ").strip()
    if not os.path.exists(path):
        print(R(f"Файл не найден: {path}")); return
    alias      = input("Key alias: ").strip()
    store_pass = getpass.getpass("Store password: ")
    key_pass   = getpass.getpass("Key password (Enter = тот же): ") or store_pass
    cfg = load_ks_cfg()
    cfg.update({"keystore_path": path, "key_alias": alias,
                "store_password": store_pass, "key_password": key_pass})
    save_ks_cfg(cfg)
    print(G("Keystore сохранён"))

def apply_to_gradle():
    cfg = load_ks_cfg()
    if not cfg.get("keystore_path"):
        print(R("Сначала настрой keystore (пункт 1 или 2)")); return
    gradle = os.path.join(PROJECT, "android", "app", "build.gradle")
    with open(gradle) as f: content = f.read()
    if "signingConfigs" in content and "release {" in content.split("signingConfigs")[1][:100]:
        print(Y("signingConfigs уже настроен в build.gradle")); return
    ks_path = cfg["keystore_path"].replace("\\", "/")
    signing = f"""
    signingConfigs {{
        release {{
            keyAlias '{cfg["key_alias"]}'
            keyPassword '{cfg["key_password"]}'
            storeFile file('{ks_path}')
            storePassword '{cfg["store_password"]}'
        }}
    }}
"""
    content = content.replace("    buildTypes {", signing + "    buildTypes {")
    content = content.replace(
        "        release {\n            signingConfig signingConfigs.debug",
        "        release {\n            signingConfig signingConfigs.release"
    )
    with open(gradle, "w") as f: f.write(content)
    print(G("build.gradle обновлён с release-подписью"))
    print(Y("Не коммить build.gradle с паролями в открытом виде!"))

def show_keystore_info():
    cfg = load_ks_cfg()
    ks  = cfg.get("keystore_path", "")
    if not ks or not os.path.exists(ks):
        print(R("Keystore не задан или файл не найден")); return
    sp = cfg.get("store_password") or getpass.getpass("Store password: ")
    subprocess.run([_keytool(), "-list", "-v", "-keystore", ks, "-storepass", sp], env=env())
    pause()

def ios_signing_info():
    print("""
╔══════════════════════════════════════════════╗
║         iOS ПОДПИСЬ                         ║
╠══════════════════════════════════════════════╣
║ Тест на своём устройстве (бесплатно):        ║
║  1. Открой ios/Runner.xcworkspace в Xcode   ║
║  2. Runner → Signing & Capabilities         ║
║  3. Team: выбери Apple ID                   ║
║     Бесплатный: 7 дней / Платный: год       ║
║                                              ║
║ App Store (платный аккаунт $99/год):         ║
║  1. Сертификат на developer.apple.com       ║
║  2. Xcode → Product → Archive               ║
║  3. Distribute через Organizer              ║
║                                              ║
║ Bundle ID: com.brizproject.osiris           ║
╚══════════════════════════════════════════════╝
""")
    pause()

# ── Очистка ───────────────────────────────────────────────────────────────────
def _rm(path, label):
    if os.path.exists(path):
        try:
            if os.path.isdir(path):
                shutil.rmtree(path)
            else:
                os.remove(path)
            print(f"  {G(label)}")
        except Exception as e:
            print(f"  {R(label + ': ' + str(e))}")
    else:
        print(f"  - {label}: нет")

def _rm_glob(pattern, label):
    found = glob.glob(pattern, recursive=True)
    if found:
        for p in found:
            try:
                shutil.rmtree(p) if os.path.isdir(p) else os.remove(p)
            except Exception:
                pass
        print(f"  {G(label + ' (' + str(len(found)) + ')')}")
    else:
        print(f"  - {label}: нет")

def clean_flutter():
    print("\n── Flutter clean ──")
    run([paths()["flutter"], "clean"], fail_ok=True)

def clean_builds():
    print("\n── Удаление папок build/ ──")
    _rm(os.path.join(PROJECT, "build"), "build/")
    _rm(os.path.join(PROJECT, ".dart_tool"), ".dart_tool/")
    print(G("Готово"))
    pause()

def clean_ios():
    if not IS_MAC:
        print(R("Только на macOS")); return
    print("\n── Очистка iOS ──")
    _rm(os.path.join(PROJECT, "ios", "build"),              "ios/build/")
    _rm(os.path.join(PROJECT, "ios", "Pods"),               "ios/Pods/")
    _rm(os.path.join(PROJECT, "ios", ".symlinks"),          "ios/.symlinks/")
    _rm(os.path.join(PROJECT, "ios", "Podfile.lock"),       "ios/Podfile.lock")
    _rm(os.path.join(PROJECT, "ios", "Runner.xcworkspace",
                     "xcuserdata"),                         "xcuserdata/")
    _rm_glob(os.path.join(PROJECT, "ios", "**", "*.xcuserdatad"), "*.xcuserdatad")
    print(G("Готово"))
    pause()

def clean_macos():
    if not IS_MAC:
        print(R("Только на macOS")); return
    print("\n── Очистка macOS ──")
    _rm(os.path.join(PROJECT, "macos", "build"),            "macos/build/")
    _rm(os.path.join(PROJECT, "macos", "Pods"),             "macos/Pods/")
    _rm(os.path.join(PROJECT, "macos", ".symlinks"),        "macos/.symlinks/")
    _rm(os.path.join(PROJECT, "macos", "Podfile.lock"),     "macos/Podfile.lock")
    _rm_glob(os.path.join(PROJECT, "macos", "**", "*.xcuserdatad"), "*.xcuserdatad")
    print(G("Готово"))
    pause()

def clean_android():
    print("\n── Очистка Android ──")
    _rm(os.path.join(PROJECT, "android", ".gradle"),        "android/.gradle/")
    _rm(os.path.join(PROJECT, "android", "app", "build"),  "android/app/build/")
    _rm(os.path.join(PROJECT, "android", "build"),         "android/build/")
    print(G("Готово"))
    pause()

def clean_xcode_cache():
    if not IS_MAC:
        print(R("Только на macOS")); return
    print("\n── Очистка Xcode DerivedData ──")
    derived = os.path.expanduser("~/Library/Developer/Xcode/DerivedData")
    if not os.path.isdir(derived):
        print("  - DerivedData не найдена"); pause(); return
    dirs = [d for d in os.listdir(derived) if d.startswith("osiris") or d.startswith("Runner")]
    if not dirs:
        print("  - Нет папок проекта в DerivedData")
    for d in dirs:
        _rm(os.path.join(derived, d), "DerivedData/" + d)
    print(G("Готово"))
    pause()

def clean_pub_cache():
    print("\n── Очистка pub cache ──")
    print(Y("Это удалит все скачанные пакеты (~/.pub-cache/hosted/pub.dev)"))
    yn = input("Продолжить? [y/N]: ").strip().lower()
    if yn != "y": return
    run([paths()["flutter"], "pub", "cache", "repair"], fail_ok=True)

def clean_all():
    print("\n── Полная очистка ──")
    print(Y("Будут удалены: build/, .dart_tool/, Pods/, android/.gradle/, DerivedData проекта"))
    yn = input("Продолжить? [y/N]: ").strip().lower()
    if yn != "y": return
    _rm(os.path.join(PROJECT, "build"),       "build/")
    _rm(os.path.join(PROJECT, ".dart_tool"),  ".dart_tool/")
    if IS_MAC:
        _rm(os.path.join(PROJECT, "ios",   "Pods"),         "ios/Pods/")
        _rm(os.path.join(PROJECT, "ios",   "Podfile.lock"), "ios/Podfile.lock")
        _rm(os.path.join(PROJECT, "ios",   "build"),        "ios/build/")
        _rm(os.path.join(PROJECT, "macos", "Pods"),         "macos/Pods/")
        _rm(os.path.join(PROJECT, "macos", "Podfile.lock"), "macos/Podfile.lock")
        _rm(os.path.join(PROJECT, "macos", "build"),        "macos/build/")
        derived = os.path.expanduser("~/Library/Developer/Xcode/DerivedData")
        if os.path.isdir(derived):
            for d in os.listdir(derived):
                if d.startswith("osiris") or d.startswith("Runner"):
                    _rm(os.path.join(derived, d), "DerivedData/" + d)
    _rm(os.path.join(PROJECT, "android", ".gradle"),       "android/.gradle/")
    _rm(os.path.join(PROJECT, "android", "app", "build"), "android/app/build/")
    print(G("Полная очистка завершена"))
    pause()

def clean_linux():
    IS_LINUX = platform.system() == "Linux"
    print("\n── Очистка Linux ──")
    _rm(os.path.join(PROJECT, "linux", "build"), "linux/build/")
    print(G("Готово"))
    pause()

def clean_menu():
    while True:
        print("\n╔══════════════════════════════════════════════╗")
        print("║         ОЧИСТКА КЭШЕЙ И АРТЕФАКТОВ         ║")
        print("╠══════════════════════════════════════════════╣")
        print("║  1. flutter clean (build/ + .dart_tool/)   ║")
        print("║  2. Удалить папки build/                    ║")
        print("║  3. Очистить iOS (Pods, build, lock)        ║")
        print("║  4. Очистить macOS (Pods, build, lock)      ║")
        print("║  5. Очистить Android (.gradle, build)       ║")
        print("║  6. Очистить Linux (build)                  ║")
        print("║  7. Очистить Xcode DerivedData проекта      ║")
        print("║  8. Очистить pub cache (пакеты Flutter)     ║")
        print("║  9. Полная очистка (всё вышеперечисленное)  ║")
        print("║  0. Назад                                   ║")
        print("╚══════════════════════════════════════════════╝")
        c = input("Выбор: ").strip()
        if c == "0":  break
        elif c == "1": clean_flutter()
        elif c == "2": clean_builds()
        elif c == "3": clean_ios()
        elif c == "4": clean_macos()
        elif c == "5": clean_android()
        elif c == "6": clean_linux()
        elif c == "7": clean_xcode_cache()
        elif c == "8": clean_pub_cache()
        elif c == "9": clean_all()

# ── Главное меню ──────────────────────────────────────────────────────────────
MENU = {
    "1": ("Build Android (APK / AAB)",  build_android),
    "2": ("Build iOS",                  build_ios),
    "3": ("Build macOS",                build_macos),
    "4": ("Build Windows",              build_windows),
    "5": ("Build Linux",                build_linux),
    "6": ("Открыть проект в Xcode",     open_xcode),
    "7": ("Подписи и сертификаты",      sign_menu),
    "8": ("Настройка путей",            paths_menu),
    "9": ("Тест состояния окружения",   status),
    "c": ("Очистка кэшей и артефактов", clean_menu),
    "0": ("Выход",                      None),
}

def main():
    while True:
        p = paths()
        cfg_saved = "💾" if os.path.exists(PATHS_CFG) else "  "
        print("\n╔════════════════════════════════════════╗")
        print("║       OSIRIS BROWSER BUILDER          ║")
        print(f"║  {platform.system()} {platform.machine():<16} {cfg_saved} пути  ║")
        print("╠════════════════════════════════════════╣")
        for k, (label, _) in MENU.items():
            print(f"║  {k}. {label:<34}║")
        print("╚════════════════════════════════════════╝")
        c = input("Выбор: ").strip()
        if c == "0": break
        if c in MENU:
            _, fn = MENU[c]
            if fn: fn()
        else:
            print("Неверный выбор")

if __name__ == "__main__":
    main()
