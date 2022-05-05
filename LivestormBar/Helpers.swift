//
//  Helpers.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 22/04/2022.
//

import Foundation
import KeyboardShortcuts


func getTodayDate(choosenFormat: String = "yyyy-MM-dd", locale: String = "FR-fr") -> String{
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale    = Locale(identifier: locale)
    dateFormatter.dateFormat = choosenFormat
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
        #"https?:\/\/app\.livestorm\.co\/.*\/live.*"#,
        #"https?:\/\/app\.livestorm\.co\/livestorm\/meet\/.*"#
    ]

    for pattern in patterns {
        if let regex = try? NSRegularExpression(pattern: pattern) {
            // Do we find a Livestorm link
            if let link = getMatch(text: field, regex: regex) {
                //Livestorm link found, now extract it because it can be mixed with other data
                //(like   "location": "https://app.livestorm.co/livestorm/product-sharing-session/live, SSD-1-Brainstorm (8)", )
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: link, options: [], range: NSRange(location: 0, length: link.utf16.count))

                guard let range = Range(matches[0].range, in: link) else { continue }
                let url = link[range]
                if let LSurl = URL(string: String(url)) {
                    return MeetingLink(url: LSurl)
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


func resetFactoryDefault(){
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
    print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
}

//func printUserDefaults(){
//    let domain = Bundle.main.bundleIdentifier!
//    UserDefaults.standard.synchronize()
//    print(UserDefaults.standard.persistentDomain(forName: domain))
//}
