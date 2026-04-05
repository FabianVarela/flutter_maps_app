import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    let dartDefinesString = Bundle.main.infoDictionary!["DART_DEFINES"] as! String
    var dartDefinesDictionary = [String:String]()

    for definedValue in dartDefinesString.components(separatedBy: ",") {
        let decoded = String(data: Data(base64Encoded: definedValue)!, encoding: .utf8)!
        let values = decoded.components(separatedBy: "=")
        dartDefinesDictionary[values[0]] = values[1]
    }

    let dartDefineMapKey = dartDefinesDictionary["GOOGLE_MAPS_API_KEY"] ?? ""
    let envMapKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String ?? ""

    GMSServices.provideAPIKey(dartDefineMapKey ?? envMapKey)
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
