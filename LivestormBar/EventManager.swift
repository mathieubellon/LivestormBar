//
//  EventModel.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import Foundation
import OAuth2


struct CalendarResponse: Decodable {
    let items: [CalendarItem]
}

struct CalendarItem: Decodable {
    let id: String
    let summary: String?
    let htmlLink: String?
    let end: End?
    let start: Start?
}

struct End: Decodable {
    let dateTime: String?
    let timeZone: String?
}

struct Start: Decodable {
    let dateTime: Date?
    let timeZone: String?
}




