//
//  EventModel.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import Foundation


struct calendarEvent: Decodable {
    let id: String
    let summary: String
    let htmlLink: String
}



func getTodayEvents() -> Array<calendarEvent> {
    
    let eventList = [
        calendarEvent(id: "6sqop5rg058ke0bcc41q34km96", summary: "Mathieu Writer's Zoom Meeting", htmlLink: "https://www.google.com/calendar/event?eid=NnNxb3A1cmcwNThrZTBiY2M0MXEzNGttOTYgZWNyaXJldGVjaEBt"),
        calendarEvent(id: "6i30pcj416tqbefjfe6fp360iu", summary: "☕️ Coffee with him", htmlLink: "https://www.google.com/calendar/event?eid=NnNxb3A1cmcwNThrZTBiY2M0MXEzNGttOTYgZWNyaXJldGVjaEBt")
    ]
    
    return eventList
    
}
