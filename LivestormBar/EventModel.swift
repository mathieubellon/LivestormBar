//
//  EventModel.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import SwiftUI
import OAuth2
import Defaults




struct CalendarResponse: Decodable {
    let items: [CalendarItem]
}

struct CalendarItem: Decodable {
    let id: String
    let summary: String?
    let htmlLink: String?
    let end: End?
    let start: Start?
    let description: String?
    let location: String?
    let conferenceData: Conference?
    
    var extractedLink: String?
    
}

struct Conference: Decodable{
    let conferenceId: String?
    let entryPoints: [entryPoint]
}

struct entryPoint: Decodable{
    let entryPointType: String
    let uri: String
}

struct End: Decodable {
    let dateTime: Date?
    let timeZone: String?
}

struct Start: Decodable {
    let dateTime: Date?
    let timeZone: String?
}

struct UserInfo: Decodable {
    let id: String
    let email: String
    let name: String?
    let given_name: String?
    let family_name: String?
    let picture: String?
    let locale: String
}

//
//class calEvent: ObservableObject{
//    let id: String
//    let summary: String?
//    let htmlLink: String?
//    let end: End?
//    let start: Start?
//    let description: String?
//}


class evenManager: NSObject {
    @Default(.email) var email
    var eventsArray: [CalendarItem] = []
    
    override init() {
        super.init()
        guard self.email != nil else {return}
    }
    
    func fetchEvents(){
        NSLog("fetch events")
        loader.requestTodayEvents(calendarID: email!, callback: { calendarResponse, error in
            if let error = error {
                switch error {
                case OAuth2Error.requestCancelled:
                    NSLog("first error : \(error)")
                default:
                    NSLog("second error : \(error)")
                }
            }else {
                self.eventsArray = []
                removePendingNotificationRequests()
                for var event in calendarResponse?.items ?? [] {
                    if event.start != nil  && event.start?.dateTime != nil {
                        
                        // extract link from description, location or url
                        event.extractedLink = getMeetingLink(event)?.url.absoluteString ?? ""
                        scheduleEventNotification(event)
                        self.eventsArray.append(event)
                    }
                }
                self.eventsArray.sort(by: {$0.start!.dateTime!.compare($1.start!.dateTime!) == .orderedAscending})
            }
            statusBarItem.updateMenu()
        })
    }
    
}

