import Firebase
import FirebaseMessaging
import UserNotifications
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate - didFinishLaunchingWithOptions called")

        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                print("Failed to get notification permission: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("Notification permission granted.")
        }

        // Register for remote notifications
        application.registerForRemoteNotifications()

        // Reset the badge count when the app launches
        resetBadgeCount()

        print("AppDelegate - didFinishLaunchingWithOptions completed")
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        resetBadgeCount() // Reset badge when the app becomes active
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        resetBadgeCount() // Reset badge when the app enters the foreground
    }
    
    // This method resets the badge count to zero
    private func resetBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Failed to reset badge count: \(error.localizedDescription)")
            } else {
                print("Badge count successfully reset.")
            }
        }
    }


    // Handle successful registration for remote notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("APNS device token set for Firebase.")
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error.localizedDescription)")
            } else if let token = token {
                print("FCM Token: \(token)")
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("Failed to receive FCM registration token.")
            return
        }
        print("FCM registration token received: \(fcmToken)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received notification in foreground: \(notification.request.content.userInfo)")
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User tapped on notification with info: \(response.notification.request.content.userInfo)")
        handleNotificationAction(userInfo: response.notification.request.content.userInfo)
        resetBadgeCount() // Reset badge after tapping on a notification
        completionHandler()
    }
    
    private func handleNotificationAction(userInfo: [AnyHashable: Any]) {
        if let type = userInfo["type"] as? String {
            switch type {
            case "new_event":
                print("Navigate to the event view.")
            default:
                print("Unknown notification type.")
            }
        }
    }
}
