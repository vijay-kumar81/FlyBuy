import UIKit
import Flutter
import GoogleMaps
import FirebaseAuth
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    //  FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyCRJqpyBsteSDbqPKTW5XyXedLxAX6gyOs")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

// https://firebase.google.com/docs/auth/ios/phone-auth#appendix:-using-phone-sign-in-without-swizzling
// https://firebase.google.com/docs/cloud-messaging/ios/client#token-swizzle-disabled
override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Pass device token to auth
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)

    // Pass device token to messaging
    Messaging.messaging().apnsToken = deviceToken

    return super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
}

// https://firebase.google.com/docs/auth/ios/phone-auth#appendix:-using-phone-sign-in-without-swizzling
// https://firebase.google.com/docs/cloud-messaging/ios/receive#handle-swizzle
override func application(_ application: UIApplication,
                          didReceiveRemoteNotification notification: [AnyHashable : Any],
                          fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // Handle the message for firebase auth phone verification
    if Auth.auth().canHandleNotification(notification) {
        completionHandler(.noData)
        return
    }

    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }

    // Handle it for firebase messaging analytics
    if ((notification["gcm.message_id"]) != nil) {
        Messaging.messaging().appDidReceiveMessage(notification)
    }

    return super.application(application, didReceiveRemoteNotification: notification, fetchCompletionHandler: completionHandler)
}

// https://firebase.google.com/docs/auth/ios/phone-auth#appendix:-using-phone-sign-in-without-swizzling
override func application(_ application: UIApplication, open url: URL,
                          options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    // Handle auth reCAPTCHA when silent push notifications aren't available
    if Auth.auth().canHandle(url) {
        return true
    }

    return super.application(application, open: url, options: options)
   }
}
