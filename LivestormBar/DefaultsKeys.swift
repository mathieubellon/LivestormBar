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
    static let userWantsNotifications10mnBeforeEventStart = Key<Bool>("userWantsNotifications10mnBeforeEventStart", default:false)
    static let isOnboardingDone = Key<Bool>("isOnboardingDone", default: false)
    static let showEventNameInMenubar = Key<Bool>("showEventNameInMenubar", default: false)
}



