//
//  Helpers.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 22/04/2022.
//

import Foundation


func getTodayDate() -> String{
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}

struct MeetingLink: Equatable { 
    var url: URL
}


/**
 * this method will collect text from the location, url and notes field of an event and try to find a known meeting url link.
 * As meeting links can be part of a outlook safe url, we will extract the original link from outlook safe links.
 */
func getMeetingLink(_ event: CalendarItem) -> MeetingLink? {
    var searchFields: [String] = []

    if let location = event.location {
        searchFields.append(location)
    }

    if let conferenceUri = event.conferenceData?.entryPoints[0].uri {
        searchFields.append(conferenceUri)
    }

    if let description = event.description {
        searchFields.append(description)
    }

    for var field in searchFields {
        let meetingLink = detectLink(&field)
        if meetingLink != nil {
            return meetingLink
        }
    }

    return nil
}

func detectLink(_ field: inout String) -> MeetingLink? {

    
    let patterns = [
        #"https?://app\.livestorm\.co/p/.*/live.*"#,
        #"https?://app\.livestorm\.co/livestorm/meet/.*"#
    ]

    for pattern in patterns {
        if let regex = try? NSRegularExpression(pattern: pattern) {
            if let link = getMatch(text: field, regex: regex) {
                if let url = URL(string: link) {
                    return MeetingLink(url: url)
                }
            }
        }
    }
    return nil
}

func getMatch(text: String, regex: NSRegularExpression) -> String? {
    let resultsIterator = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
    let resultsMap = resultsIterator.map { String(text[Range($0.range, in: text)!]) }

    if !resultsMap.isEmpty {
        let match = resultsMap[0]
        return match
    }
    return nil
}
