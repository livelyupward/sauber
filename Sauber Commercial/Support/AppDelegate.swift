import UIKit

/// Registers for silent remote notifications so CloudKit can wake the app to
/// pull in changes made on the user's other devices while this app is in the
/// background. SwiftData's CloudKit-backed store observes these pushes and
/// imports changes on its own — this delegate only needs to opt in and
/// acknowledge each notification.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // CloudKit sync still works when the app is open; it just won't be
        // woken in the background until remote-notification registration
        // succeeds (e.g. once the device has network connectivity).
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completionHandler(.newData)
    }
}
