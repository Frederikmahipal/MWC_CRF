import Flutter
import UIKit
import Firebase
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    // Initialize Google Maps with API key
    // Try to get API key from Info.plist first
    var apiKey: String?
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let plist = NSDictionary(contentsOfFile: path),
       let key = plist["GOOGLE_MAPS_API_KEY"] as? String,
       !key.isEmpty && key != "YOUR_GOOGLE_MAPS_API_KEY_HERE" {
      apiKey = key
    }
    
    // Fallback: Try to read from environment variable (if available)
    if apiKey == nil {
      apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"]
    }
    
    if let key = apiKey {
      GMSServices.provideAPIKey(key)
      print("✅ Google Maps API key initialized")
    } else {
      print("❌ ERROR: Google Maps API key not found! Please set GOOGLE_MAPS_API_KEY in Info.plist")
    } 
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
