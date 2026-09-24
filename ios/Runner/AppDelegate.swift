import UIKit
import Flutter
import Foundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var privacyCover: UIView?
  private let securityChannelName = "osiris/platform_security"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let messenger = registrar(forPlugin: "OsirisPlatformSecurity")?.messenger() {
      let channel = FlutterMethodChannel(
        name: securityChannelName,
        binaryMessenger: messenger
      )
      channel.setMethodCallHandler { call, result in
        if call.method == "resolvePrivacyCover" {
          self.privacyCover?.removeFromSuperview()
          self.privacyCover = nil
          result(nil)
          return
        }
        guard call.method == "excludeFromBackup",
              let arguments = call.arguments as? [String: Any],
              let paths = arguments["paths"] as? [String] else {
          result(FlutterMethodNotImplemented)
          return
        }

        do {
          for path in paths where FileManager.default.fileExists(atPath: path) {
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            let url = URL(fileURLWithPath: path, isDirectory: isDirectory.boolValue)
            try url.setResourceValue(true, forKey: .isExcludedFromBackupKey)
          }
          result(nil)
        } catch {
          result(FlutterError(
            code: "BACKUP_EXCLUSION_FAILED",
            message: "Could not exclude sensitive files from backup",
            details: nil
          ))
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    super.applicationWillResignActive(application)
    guard let hostView = window?.rootViewController?.view,
          privacyCover == nil else { return }
    let cover = UIView(frame: hostView.bounds)
    cover.backgroundColor = .black
    cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    cover.layer.zPosition = .greatestFiniteMagnitude
    cover.isAccessibilityElement = true
    cover.accessibilityLabel = "Osiris Browser locked"
    hostView.addSubview(cover)
    privacyCover = cover
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
  }
}
