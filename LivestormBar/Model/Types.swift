//
//  Types.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 10/05/2022.
//

import Foundation



struct CalendarItems: Decodable {
    let items: [CalendarItem]
}



struct CalendarItem: Decodable {
    let id: String
    let summary: String?
    let htmlLink: String?
    let end: End
    let start: Start
    let description: String?
    let location: String?
    let conferenceData: Conference?
    var extractedLink: String?
    
    
    func isNow() -> Bool {
        let now = Date()
        if self.start.dateTime != nil && self.end.dateTime != nil {
            return self.start.dateTime! < now && now < self.end.dateTime!
        }
        return false
    }
    
}

struct Conference: Decodable{
    let conferenceId: String?
    let entryPoints: [entryPoint]
}

struct entryPoint: Decodable{
    let entryPointType: String
    let uri: String
}




struct Start: Decodable {
    let date: String? // In case of full day event only date is given in format yyyy-mm-dd
    let dateTime: Date?
    let timeZone: String?
}

struct End: Decodable {
    let date: String? // In case of full day event only date is given in format yyyy-mm-dd
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
