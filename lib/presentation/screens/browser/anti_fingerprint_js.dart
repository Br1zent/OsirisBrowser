/// Page-world fingerprint spoofing is disabled.
///
/// The former script applied incoherent values after page load and exposed an
/// app marker to the page. Keep the call site API inert until a platform
/// implementation can be verified before document scripts run.
class AntiFingerprintJS {
  AntiFingerprintJS._();

  static String buildScript({
    bool blockCanvas = true,
    bool blockAudio = true,
    bool blockWebGL = true,
    bool blockWebRtc = true,
    bool spoofTimezone = true,
    bool blockNavigatorProps = true,
  }) => '';
}
