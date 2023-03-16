//
//  AppDelegate.swift
//  See Fish
//
//  Created by Andre on 10/31/20.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift    // when keyboard appears, move textfield or textview up
import UserNotifications
import GoogleMaps
import GooglePlaces
import OneSignal

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        IQKeyboardManager.shared.enable = true
        ConnectionManager.sharedInstance.observeReachability()
        
        GMSServices.provideAPIKey(apikey)
        GMSPlacesClient.provideAPIKey(apikey)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {
            granted, error in
            print("granted: \(granted)")
        })
        // Register with APNs
        UIApplication.shared.registerForRemoteNotifications()
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        // Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: false]
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { [self] notification in
            print("Received Notification - \(notification?.payload.notificationID) - \(notification?.payload.title)")
            if let actionID = notification?.payload.additionalData["act"] as? Int {
                if actionID == 1 {
                    if gHomeViewController != nil {
                        gHomeViewController.routeFollowingsBar.visibility = .visible
                    }
                }
            }
        }

        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload

            var fullMessage = payload.body
            print("Message = \(fullMessage)")
            print("data = \(payload.additionalData)")
            print("title = \(payload.title)")

            print("App URL: \(payload.launchURL ?? "No lanuch Url")")

            if payload.additionalData != nil {
                if let actionID = payload.additionalData["act"] as? Int {
                    print("action ID +++ \(actionID)")
                    if actionID == 1 {
                        UserDefaults.standard.set(actionID, forKey: "actionID")
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        if let topController = UIApplication.shared.topViewController() {
                            if topController is BaseViewController && topController != gRouteFollowingsViewController {
                                if recent != nil {
                                    let vc = UIStoryboard(name: "Main2", bundle: nil).instantiateViewController(withIdentifier: "RouteFollowingsViewController")
                                    vc.modalPresentationStyle = .fullScreen
                                    topController.present(vc, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }

                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
                }
           }

        }
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "5db38391-6853-4e88-8f8b-6cfb4b892f5b", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        // OneSignal initialization
//        OneSignal.initWithLaunchOptions(launchOptions, appId: "5db38391-6853-4e88-8f8b-6cfb4b892f5b")
          
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground \(notification.request.content.userInfo)")
        
        
        // Reading message body
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        
        var messageBody:String?
        var messageTitle:String = "Alert"
        
        if let alertDict = dict["alert"] as? Dictionary<String, String> {
            messageBody = alertDict["body"]!
            if alertDict["title"] != nil { messageTitle  = alertDict["title"]! }
            
        } else {
            messageBody = dict["alert"] as? String
        }
        
        print("Message body is \(messageBody!) ")
        print("Message message Title is \(messageTitle) ")
        // Let iOS to display message
        
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "See Fish")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func updateBadgeCount() {
        var badgeCount = UIApplication.shared.applicationIconBadgeNumber
        if badgeCount > 0
        {
            badgeCount = badgeCount-1
        }
        
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }
    
    

}


