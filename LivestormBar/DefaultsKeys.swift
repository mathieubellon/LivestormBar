//
//  DefaultsKeys.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 22/04/2022.
//

import Foundation
import Defaults

extension Defaults.Keys {
    static let username = Key<String?>("username", default: nil)
    static let email = Key<String?>("email", default: nil)
    static let picture = Key<String?>("picture", default: nil)
    static let isAuthenticated = Key<Bool>("isauthenticated", default: false)
    static let userWantsNotifications = Key<Bool>("userWantsNotifications", default:true)
}

//
//let observer = Defaults.observe(.username) { change in
//    // Initial event
//    print(change.oldValue)
//    //=> false
//    print(change.newValue)
//    //=> false
//
//    // First actual event
//    print(change.oldValue)
//    //=> false
//    print(change.newValue)
//    //=> true
//}

let userWantsNotificationsObserver = Defaults.observe(.userWantsNotifications) { change in
    if change.oldValue != change.newValue {
        NSLog("Change userWantsNotifications from \(change.oldValue) to \(change.newValue)")
        removePendingNotificationRequests()
    }
}
