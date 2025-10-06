import Flutter
import UIKit

public class FlutterDynamicLauncherIconPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_dynamic_launcher_icon", binaryMessenger: registrar.messenger())
    let instance = FlutterDynamicLauncherIconPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "changeIcon":
      changeIcon(call: call, result: result)
      
    case "getCurrentIcon":
      if #available(iOS 10.3, *) {
        result(UIApplication.shared.alternateIconName)
      } else {
        result(nil)
      }
      
    case "isSupported":
      if #available(iOS 10.3, *) {
        result(UIApplication.shared.supportsAlternateIcons)
      } else {
        result(false)
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // -------------------------------
  // Helpers
  // -------------------------------
  
  private func changeIcon(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if #available(iOS 10.3, *) {
      guard UIApplication.shared.supportsAlternateIcons else {
        result(FlutterError(code: "UNSUPPORTED", message: "Alternate icons not supported", details: nil))
        return
      }
      
      let args = call.arguments as? [String: Any]
      let iconName = args?["iconName"] as? String? ?? nil  // nullable
      let silent = args?["silent"] as? Bool ?? false

      if silent {
          setIconWithoutAlert(iconName, result: result)
          result(nil)
          return
      }
       else {
          UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
              result(FlutterError(code: "ICON_CHANGE_FAILED", message: error.localizedDescription, details: nil))
            } else {
              result(nil)
            }
          }
       }
    } else {
      result(FlutterError(code: "UNSUPPORTED_IOS_VERSION", message: "iOS version < 10.3 does not support alternate icons", details: nil))
    }
  }


  private func setIconWithoutAlert(_ appIcon: String?, result: @escaping FlutterResult) {
    if UIApplication.shared.supportsAlternateIcons {
        typealias SetIconFunc = @convention(c) (NSObject, Selector, NSString?, @escaping (NSError?) -> Void) -> Void
        let selector = NSSelectorFromString("_setAlternateIconName:completionHandler:")
        guard let method = UIApplication.shared.method(for: selector) else {
            result(FlutterError(code: "PRIVATE_API_UNAVAILABLE", message: "Silent icon change not available", details: nil))
            return
        }
        let impl = unsafeBitCast(method, to: SetIconFunc.self)
        impl(UIApplication.shared, selector, appIcon as NSString?) { error in
            if let error = error {
                result(FlutterError(code: "ICON_CHANGE_FAILED", message: error.localizedDescription, details: nil))
            } else {
                result(nil)
            }
        }
    } else {
        result(FlutterError(code: "UNSUPPORTED", message: "Alternate icons not supported", details: nil))
    }
  }
}
