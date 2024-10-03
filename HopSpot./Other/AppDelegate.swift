//
//  AppDelegate.swift
//  HopSpot.
//
//  Created by Yousef Hozayen on 2024-10-01.
//

import Firebase
import FirebaseMessaging
import UserNotifications
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate - didFinishLaunchingWithOptions called")

        // Ensure Firebase is configured at the very start of app launch
        
        FirebaseApp.configure()
        
        /*
        if FirebaseApp.app() == nil {
            print("Configuring Firebase...")
            FirebaseApp.configure()
            print("Firebase has been successfully configured.")
        } else {
            print("Firebase is already configured.")
        }
         */

        // Set the delegates for Firebase Messaging and Notifications
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

        print("AppDelegate - didFinishLaunchingWithOptions completed")

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        resetBadgeCount()
    }
    
    func resetBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }


    
    // MARK: - Remote Notifications Registration
    // Handle successful registration for remote notifications and set the device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Set the APNS device token for Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
        print("APNS device token set for Firebase.")

        // Re-fetch the FCM token after setting the APNS token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error.localizedDescription)")
            } else if let token = token {
                print("FCM Token: \(token)")
            }
        }
    }

    // Handle failure to register for remote notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: - FCM Token Handling
    // Handle FCM token updates
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("Failed to receive FCM registration token.")
            return
        }
        print("FCM registration token received: \(fcmToken)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate Methods
    // Handle notification while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received notification in foreground: \(notification.request.content.userInfo)")
        
        // Show the notification alert even if the app is in the foreground
        completionHandler([.badge, .sound, .alert])
    }

    // Handle notification responses (when user taps on a notification)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("User tapped on notification with info: \(userInfo)")
        
        // Perform necessary actions based on the notification content
        handleNotificationAction(userInfo: userInfo)
        completionHandler()
    }

    // MARK: - Helper Methods
    // Handle notification actions
    private func handleNotificationAction(userInfo: [AnyHashable: Any]) {
        // Process notification content and handle any required actions
        if let type = userInfo["type"] as? String {
            switch type {
            case "new_event":
                print("Navigate to the event view.")
                // Navigate to a specific view controller or update the UI accordingly
            default:
                print("Unknown notification type.")
            }
        }
    }
}

