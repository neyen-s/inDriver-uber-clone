import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
       let dict = NSDictionary(contentsOfFile: path),
       let apiKey = dict["GOOGLE_MAPS_API_KEY"] as? String {
      GMSServices.provideAPIKey(apiKey)
    } else {
      // No key found locally — no panic, la app compila sin ella
      print("GoogleMaps API key not found in Secrets.plist")
    }

    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
