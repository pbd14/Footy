import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    
  ) -> Bool {
    if #available(iOS 10.0, *) {
        FirebaseApp.configure()
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GMSServices.provideAPIKey("AIzaSyAP76RF198pKogJjyPyEtcB3L_bLfSWgGY")
    GeneratedPluginRegistrant.register(with: self)
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*5))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

       Messaging.messaging().apnsToken = deviceToken
       super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
     }
}
