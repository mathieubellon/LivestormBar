//
//  EventModel.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import SwiftUI
import OAuth2
import Defaults
import Alamofire


class UserCalendar {
    var classicEvents: [CalendarItem]
    var allDayEvents: [CalendarItem]
    
    init(){
        self.classicEvents = []
        self.allDayEvents = []
    }
    
    @objc
    public func fetchEvents(calendarID: String) {
        NSLog("fetch events")

        let path = "/calendar/v3/calendars/\(calendarID)/events"
        let todayDate = getDateAsString()
        let endDate = getDateAsString(delta:.today)
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.googleapis.com"
        urlComponents.path = path
        urlComponents.queryItems = [
            URLQueryItem(name: "timeMin", value: "\(todayDate)T00:00:00Z"),
            URLQueryItem(name: "timeMax", value: "\(endDate)T23:59:59Z"),
            URLQueryItem(name: "singleEvents", value: "true"),
        ]
        NSLog("url Components: \(urlComponents.url!)")
        self.classicEvents = []
        self.allDayEvents = []
        AF.request(urlComponents.url!, interceptor: OAuth2RetryHandler(oauth2: GoogleOauth2), requestModifier: { $0.timeoutInterval = 5 }).validate().response() { response in
            switch response.result {
            case .success(let data):
                do{
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let allItems = try decoder.decode(CalendarItems.self, from: data!)
    
                    for item in allItems.items {
                        if item.start.date != nil {
                            // If it has only a date prop. it is an all day event
                            self.allDayEvents.append(item)
                        }else if item.start.dateTime != nil {
                            self.classicEvents.append(item)
                        }else{
                            NSLog("Event is neither Classic nor AllDay: \(item)")
                        }
                    }

                    self.sortEventsArray()
                    self.setNotifications()
                    self.extractMeetingLink()
                    statusBarItem.updateMenu()
                }catch{
                    NSLog("Error decoding events: \(error)")
                }
            case .failure(let error):
                NSLog("Error requesting events: \(error)")
            }
        }
    }
    

    private func sortEventsArray(){
        self.classicEvents.sort(by: {$0.start.dateTime!.compare($1.start.dateTime!) == .orderedAscending})
    }
    
    private func extractMeetingLink(){
        for (i, event) in self.classicEvents.enumerated() {
            self.classicEvents[i].extractedLink = getMeetingLink(event)
        }
    }
    
    private func setNotifications(){
        for event in self.classicEvents {
            if Defaults[.userWantsNotificationsAtEventStart] {
                scheduleEventNotification(event: event, notificationTime: 0, body: NSLocalizedString("event_starts_now", comment: ""), notifType: "now")
            }
            if Defaults[.userWantsNotifications1mnBeforeEventStart] {
                scheduleEventNotification(event: event, notificationTime: 60.0, body: NSLocalizedString("event_starts_in_1mn", comment: ""), notifType: "oneMinute")
            }
            if Defaults[.userWantsNotifications5mnBeforeEventStart] {
                scheduleEventNotification(event: event, notificationTime: 300.0, body: NSLocalizedString("event_starts_in_5mn", comment: ""), notifType: "fiveMinutes")
            }
            if Defaults[.userWantsNotifications10mnBeforeEventStart] {
                scheduleEventNotification(event: event, notificationTime: 600.0, body: NSLocalizedString("event_starts_in_10mn", comment: ""), notifType: "tenMinutes")
            }
        }
    }
    
    public func purge() {
        self.classicEvents = []
        self.allDayEvents = []
    }
}


