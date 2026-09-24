# ADR 0001: Supported mobile OS baseline

- Status: accepted for the security remediation release
- Decided: 2026-09-24
- Review by: 2027-09-24

## Decision

The Android minimum SDK is API 26 (Android 8.0) and the iOS deployment target
is iOS 15. The platform installer prevents installation on older OS versions;
the app cannot show an in-app upgrade screen before installation. macOS is not
changed by this ADR.

Android camera and microphone access from web pages is disabled. The app has no
first-party origin-aware, one-time consent flow, so WebView permission requests
are denied and camera/microphone permissions are absent from the manifest.
Downloads and file selection must use app-owned storage or system pickers; the
FileProvider exposes only `cache/webview_uploads/` and `files/shared/`.

## Review evidence

No OS-version telemetry is currently collected. At review time, use release
store compatibility statistics and support reports; do not add device
telemetry solely for this decision. Reassess the minimums before the review
date and update the manifest/build targets in the same change as this ADR.

## Consequences

Devices below Android API 26 or iOS 15 cannot install the release. Web pages
cannot use camera or microphone in the browser until an origin-visible,
one-time consent flow is implemented and reviewed.
