//
//  AppDelegate.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 5/12/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
//import GoogleSignIn
import Firebase
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?

    let googleMapsApiKey = "AIzaSyAkxIRJ2cr4CkY8wz6iPLyfIxc01x4yuOA"
    //AIzaSyAumV9VTUkaW-hUOTpbPR0DzTEBThF23TQ

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.registerForRemoteNotifications()
        // User Notification Center
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: { (authorized: Bool, error: Error?) in
            if !authorized {
                print("You should turn on the notification to motivate you to ride more and get G-Points more")
            }
            
        })
        // Define Actions
        let goToAppAction = UNNotificationAction(identifier: "goToApp", title: "Tap Above to ride!", options: [])
        let cancelAction = UNNotificationAction(identifier: "cancel", title: "Maybe next time!", options: [])
        
        let category = UNNotificationCategory(identifier: "rideMoreCategory", actions: [goToAppAction, cancelAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleMapsApiKey)
        GMSPlacesClient.provideAPIKey(googleMapsApiKey)
        UIApplication.shared.statusBarStyle = .lightContent

        //LocationService.sharedInstance.startUpdatingLocation()

        FirebaseApp.configure()
        //GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        //GIDSignIn.sharedInstance().delegate = self
        
        //let foreCast = ForecastForNearbyPlaces()
        
        //foreCast.getForecastNearby(lat: -33.8670522, long: 151.1957362, type: "cafe"){ (nearbyPlace) in
            
        //}

        
        //UserDefaults.standard.set(nil, forKey: "name") as? String
        
        //UserDefaults.standard.set(nil, forKey: "name")
        // This will adjust window size of the app to current device we are using
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var MVC: UIViewController
        
        //if (UserDefaults.standard.value(forKey: "name") as? String) == nil {
        if Auth.auth().currentUser == nil {
            // Show the Login Page
            
            MVC = storyBoard.instantiateViewController(withIdentifier: "LoginAndOutViewController")
        } else {
            // Show the Map View Page
            MVC = storyBoard.instantiateViewController(withIdentifier: "SignInWithTouchIDViewController")
            
        }
        
        // This will set the root view controller of our app => Map View Controller for now
        self.window?.rootViewController = MVC
        
        
        
        
        
        
        // "Key window" is the window that receives events fron the device
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    
    
    func scheduleNotification() {
        print("I did come here!")
        UNUserNotificationCenter.current().delegate = self
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Get some more G-Coins and get more healthy!"
        content.body = "Just a reminder to ride more and have a reward for your ride!"
        //content.badge = 1 as NSNumber
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "rideMoreCategory"
        
        print("get this far")
        guard let path = Bundle.main.path(forResource: "app", ofType: "png") else { return }
        print("did pass this line")
        let url = URL(fileURLWithPath: path)
        
        do {
            let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
            content.attachments = [attachment]
        } catch {
            print("The attachment could not be loaded")
        }
        
        let request = UNNotificationRequest(identifier: "burningBushNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error:Error?) in
            if let error = error{
                print("There was an Error - \(error.localizedDescription)")
            }
        })
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "goToApp" {
            
        } else {
            
        }
        
        scheduleNotification()
        completionHandler()
    }
    
    /*
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("Failed to log into Google ", error)
            return
        }
        
        print("We are succefully logged into Google!")
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error{
                print("Failed to create a firebase user with Google account", error)
            
                return
            
            }
            guard let uid = user?.uid else { return }
            print("Sucessfully logged into Firebase with Google", uid)
        
        })
        //guard let authentication = user.authentication else { return }
        //let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,accessToken: authentication.accessToken)
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
 
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
     */
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "E_Bike_App")
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
    
    /*
    private func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        // Helpers
        var result: NSManagedObject?
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        
        if let entityDescription = entityDescription {
            // Create Managed Object
            result = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        }
        
        return result
    }
    
    private func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        // Helpers
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        
        return result
    }*/

}

