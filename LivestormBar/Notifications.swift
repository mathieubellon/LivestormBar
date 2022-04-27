//
//  Notifications.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 25/04/2022.
//

import Defaults
import UserNotifications
import SwiftUI

func requestNotificationAuthorization() {
    let center = UNUserNotificationCenter.current()

    center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
}


func scheduleEventNotification(_ event: CalendarItem) {
    requestNotificationAuthorization() // By the apple best practices
    
    guard event.start != nil, event.start?.dateTime != nil else { return }

    let now = Date()
    let notificationTime = Double(60.0)
    let timeInterval = event.start!.dateTime!.timeIntervalSince(now) - notificationTime

    if timeInterval < 0.5 {
        return
    }

    removePendingNotificationRequests()

    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = event.summary ?? "No title"

    content.body = "⏰ La réunion débute dans 1 minute"
    content.categoryIdentifier = "EVENT"
    content.sound = UNNotificationSound.default
    content.userInfo = ["eventID": event.id, "extractedLink": event.extractedLink!]
    content.threadIdentifier = "livestormbar"

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
    let request = UNNotificationRequest(identifier: "EVENT", content: content, trigger: trigger)
    center.add(request) { error in
        if let error = error {
            NSLog("%@", "request \(request.identifier) could not be added because of error \(error)")
        }else{
            print("event registered \(request)")
        }
    }
}

func registerNotificationCategories() {
    let acceptAction = UNNotificationAction(identifier: "JOIN_ACTION",
                                            title: "Join",
                                            options: .foreground)


    let eventCategory = UNNotificationCategory(identifier: "EVENT",
                                               actions: [acceptAction],
                                               intentIdentifiers: [],
                                               hiddenPreviewsBodyPlaceholder: "",
                                               options: [.customDismissAction, .hiddenPreviewsShowTitle])

    let snoozeEventCategory = UNNotificationCategory(identifier: "SNOOZE_EVENT",
                                                     actions: [acceptAction],
                                                     intentIdentifiers: [],
                                                     hiddenPreviewsBodyPlaceholder: "",
                                                     options: [.customDismissAction, .hiddenPreviewsShowTitle])

    let notificationCenter = UNUserNotificationCenter.current()

    notificationCenter.setNotificationCategories([eventCategory, snoozeEventCategory])

    notificationCenter.getNotificationCategories { categories in
        for category in categories {
            NSLog("Category \(category.identifier) was registered")
        }
    }
}


func sendUserNotification(_ title: String, _ text: String) {
    requestNotificationAuthorization() // By the apple best practices

    NSLog("Send notification: \(title) - \(text)")
    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = text
    

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

    center.add(request) { error in
        if let error = error {
            NSLog("%@", "request \(request.identifier) could not be added because of error \(error)")
        }
    }
}

/**
 * check whether the notifications for meetingbar are enabled and alert or banner style is enabled.
 * in this case the method will return true, otherwise false.
 *
 */

//un.requestAuthorization(options: [.alert, .sound]){(authorized, error) in
//    if authorized{
//        print("authorized")
//    }else if !authorized{
//        print("not authorized")
//    }else{
//        print(error?.localizedDescription as Any)
//    }
//
//}
func notificationsEnabled() -> Bool {
    let center = UNUserNotificationCenter.current()
    let group = DispatchGroup()
    group.enter()

    var correctAlertStyle = false
    var notificationsEnabled = false

    center.getNotificationSettings { notificationSettings in
        correctAlertStyle = notificationSettings.alertStyle == UNAlertStyle.alert || notificationSettings.alertStyle == UNAlertStyle.banner
        notificationsEnabled = notificationSettings.authorizationStatus != UNAuthorizationStatus.denied
        group.leave()
    }

    group.wait()
    return correctAlertStyle && notificationsEnabled
}

/**
 * sends a notification to the user.
 */
func sendNotification(_ title: String, _ text: String) {
    requestNotificationAuthorization() // By the apple best practices

    if notificationsEnabled() {
        sendUserNotification(title, text)
    } else {
        displayAlert(title: title, text: text)
    }
}

/**
 * adds an alert for the user- we will only use NSAlert if the user has switched off notifications
 */
func displayAlert(title: String, text: String) {
    NSLog("Display alert: \(title) - \(text)")

    let userAlert = NSAlert()
    userAlert.messageText = title
    userAlert.informativeText = text
    userAlert.alertStyle = NSAlert.Style.informational
    userAlert.addButton(withTitle: "general_ok")

    userAlert.runModal()
}

func removePendingNotificationRequests() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
}

func removeDeliveredNotifications() {
    let center = UNUserNotificationCenter.current()
    center.removeAllDeliveredNotifications()
}

