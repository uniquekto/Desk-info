//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit
import EstimoteProximitySDK

import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var proximityObserver: ProximityObserver!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            print("notifications permission granted = \(granted), error = \(error?.localizedDescription ?? "(none)")")
        }
        let estimoteCloudCredentials = CloudCredentials(appID: "infoapp-985", appToken: "4a30fc7468ef87a68fd1592ccf62edd3")

        proximityObserver = ProximityObserver(credentials: estimoteCloudCredentials, onError: { error in
            print("ProximityObserver error: \(error)")
        })
        let zone = ProximityZone(tag: "desks", range: .near)
        zone.onEnter = { context in
            let content = UNMutableNotificationContent()
            let deskOwner = context.attachments["desk-owner"]
            let dpost = context.attachments["post"]
            content.title = "You are in \(deskOwner ?? "Pramesh" )´s Desk"
            content.body = "\(dpost ?? " " )"
            content.sound = UNNotificationSound.default()
            let request = UNNotificationRequest(identifier: "enter", content: content, trigger: nil)
            notificationCenter.add(request, withCompletionHandler: nil)
        }
        zone.onExit = { context in
            let content = UNMutableNotificationContent()
            content.title = "Bye bye"
            content.body = "Hope to see you again."
            content.sound = UNNotificationSound.default()
            let request = UNNotificationRequest(identifier: "exit", content: content, trigger: nil)
            notificationCenter.add(request, withCompletionHandler: nil)
        }
        proximityObserver.startObserving([zone])
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // Needs to be implemented to receive notifications both in foreground and background
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([UNNotificationPresentationOptions.alert, UNNotificationPresentationOptions.sound])
    }
}
