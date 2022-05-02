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
    static let userWantsNotificationsAtEventStart = Key<Bool>("userWantsNotificationsAtEventStart", default:false)
    static let userWantsNotifications1mnBeforeEventStart = Key<Bool>("userWantsNotifications1mnBeforeEventStart", default:false)
    static let userWantsNotifications5mnBeforeEventStart = Key<Bool>("userWantsNotifications5mnBeforeEventStart", default:false)
    static let userWantsNotifications10mnBeforeEventStart = Key<Bool>("userWantsNotifications10mnBeforeEventStart", default:true)
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

