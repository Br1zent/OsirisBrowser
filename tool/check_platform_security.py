#!/usr/bin/env python3
"""Static checks for the SEC 09/11 platform policy."""

import plistlib
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ANDROID = ROOT / "android/app/src/main"
ANDROID_NS = "{http://schemas.android.com/apk/res/android}"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


manifest = ET.parse(ANDROID / "AndroidManifest.xml").getroot()
permissions = {
    element.attrib[f"{ANDROID_NS}name"]
    for element in manifest.findall("uses-permission")
}
allowed_permissions = {
    "android.permission.INTERNET",
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.USE_BIOMETRIC",
}
require(permissions <= allowed_permissions, f"unexpected Android permissions: {permissions - allowed_permissions}")
require(manifest.find("application").get(f"{ANDROID_NS}requestLegacyExternalStorage") is None,
        "requestLegacyExternalStorage must remain disabled")
require(manifest.find("application").get(f"{ANDROID_NS}allowBackup") == "false",
        "Android app backup must remain disabled")

paths = ET.parse(ANDROID / "res/xml/file_paths.xml").getroot()
for element in paths:
    require(element.tag in {"cache-path", "files-path"}, "FileProvider path must be app-owned")
    require(element.get("path") not in {None, ".", "", "/"}, "FileProvider path must be narrow")

gradle = (ROOT / "android/app/build.gradle").read_text()
require("minSdkVersion 26" in gradle, "Android baseline must be API 26")

pbxproj = (ROOT / "ios/Runner.xcodeproj/project.pbxproj").read_text()
require("IPHONEOS_DEPLOYMENT_TARGET = 15.0;" in pbxproj, "iOS baseline must be 15")
require("IPHONEOS_DEPLOYMENT_TARGET = 12.0;" not in pbxproj, "old iOS target remains")

ios_info = plistlib.loads((ROOT / "ios/Runner/Info.plist").read_bytes())
require("NSCameraUsageDescription" not in ios_info, "camera capability is not enabled")
require("NSMicrophoneUsageDescription" not in ios_info, "microphone capability is not enabled")

release_entitlements = plistlib.loads((ROOT / "macos/Runner/Release.entitlements").read_bytes())
require(release_entitlements.get("com.apple.security.app-sandbox") is True,
        "macOS Release must use App Sandbox")
require(release_entitlements.get("com.apple.security.network.client") is True,
        "macOS Release must allow outbound navigation")
require("ENABLE_HARDENED_RUNTIME = YES;" in
        (ROOT / "macos/Runner.xcodeproj/project.pbxproj").read_text(),
        "macOS Release must enable Hardened Runtime")

browser = (ROOT / "lib/presentation/screens/browser/browser_screen.dart").read_text()
require("PermissionResponseAction.DENY" in browser,
        "WebView permission requests must be denied by default")
app_delegate = (ROOT / "ios/Runner/AppDelegate.swift").read_text()
require("isExcludedFromBackupKey" in app_delegate, "iOS backup exclusion is missing")
require("applicationWillResignActive" in app_delegate, "iOS snapshot cover is missing")
require("resolvePrivacyCover" in app_delegate, "iOS cover must wait for auth resolution")
require("UIApplication.shared.applicationState == .active" in app_delegate,
        "native privacy cover must not be released while inactive")
database = (ROOT / "lib/data/datasources/local/app_database.dart").read_text()
require(database.count("_excludeFromBackup([dir.path, path, '$path-wal', '$path-shm'])") == 2,
        "iOS must exclude both the database directory and current SQLite files before and after opening")
privacy_gate = (ROOT / "lib/core/security/ios_privacy_cover_gate.dart").read_text()
require("addPostFrameCallback" in privacy_gate, "iOS cover release must wait for a rendered frame")
require("routeInformationProvider" in privacy_gate, "iOS cover release must check the resolved route")
require("!browserVisible" in privacy_gate,
        "iOS cover release on the unlock route must wait for the browser overlay to hide")
require("AuthStatus.authenticated" in privacy_gate, "protected routes require an authenticated session")
secure_storage = (ROOT / "lib/core/security/secure_storage.dart").read_text()
require("KeychainAccessibility.first_unlock_this_device" in secure_storage,
        "iOS key envelopes must be device-only Keychain items")

print("SEC09/SEC11 platform policy checks passed")
