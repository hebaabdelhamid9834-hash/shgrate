import UIKit
import Flutter
import GoogleMaps
import TikTokBusinessSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  private static let analyticsChannel = "shgarde/marketing_analytics"
  private var tikTokInitialized = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyACtt1uT3NDCjqCAQtJwMDEx66R095M24M")
    GeneratedPluginRegistrant.register(with: self)

    initializeTikTok()
    configureAnalyticsChannel()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func initializeTikTok() -> Bool {
    if tikTokInitialized {
      return true
    }

    guard
      let accessToken = Bundle.main.object(forInfoDictionaryKey: "TikTokAppSecret") as? String,
      !accessToken.isEmpty,
      !accessToken.contains("$(")
    else {
      return false
    }

    let applicationId = (Bundle.main.object(forInfoDictionaryKey: "TikTokApplicationId") as? String)
      ?? "6758672758"
    let tikTokAppId = NSNumber(value: Int64("7700508577488240661") ?? 0)
    guard let config = TikTokConfig.config(
      withAccessToken: accessToken,
      appId: applicationId,
      tiktokAppId: tikTokAppId
    ) else {
      return false
    }

    TikTokBusiness.initializeSdk(config)
    tikTokInitialized = true
    return true
  }

  private func configureAnalyticsChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: AppDelegate.analyticsChannel,
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(false)
        return
      }

      switch call.method {
      case "initializeTikTok":
        result(self.initializeTikTok())
      case "trackTikTok":
        guard self.tikTokInitialized,
              let arguments = call.arguments as? [String: Any],
              let eventName = arguments["eventName"] as? String else {
          result(false)
          return
        }
        let properties = arguments["properties"] as? [String: Any] ?? [:]
        TikTokBusiness.trackEvent(eventName, withProperties: properties)
        result(true)
      case "identifyTikTok":
        guard self.tikTokInitialized,
              let arguments = call.arguments as? [String: Any],
              let externalId = arguments["externalId"] as? String else {
          result(false)
          return
        }
        TikTokBusiness.identify(
          withExternalID: externalId,
          phoneNumber: arguments["phone"] as? String,
          email: arguments["email"] as? String
        )
        result(true)
      case "logoutTikTok":
        if self.tikTokInitialized {
          TikTokBusiness.logout()
        }
        result(true)
      case "flushTikTok":
        if self.tikTokInitialized {
          TikTokBusiness.explicitlyFlush()
        }
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
