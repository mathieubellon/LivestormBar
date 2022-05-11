//
//  Helpers.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 22/04/2022.
//

import Foundation
import KeyboardShortcuts
import OAuth2
import Alamofire

class OAuth2RetryHandler: Alamofire.RequestInterceptor {
    
    let loader: OAuth2DataLoader

    init(oauth2: OAuth2) {
        loader = OAuth2DataLoader(oauth2: oauth2)
        loader.alsoIntercept403 = true
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
       
        
        if let response = request.task?.response as? HTTPURLResponse, 401 == response.statusCode, let req = request.request {
            var dataRequest = OAuth2DataRequest(request: req, callback: { _ in })
          
            dataRequest.context = completion
            loader.enqueue(request: dataRequest)
            loader.attemptToAuthorize() { authParams, error in
                self.loader.dequeueAndApply() { req in
                    if let comp = req.context as? (RetryResult) -> Void {
                        comp(nil != authParams ? .retry : .doNotRetry)
                    }
                }
            }
        }
        else {
             completion(.doNotRetry)   // not a 401, not our problem
        }
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard nil != loader.oauth2.accessToken else {
            completion(.success(urlRequest))
            return
        }
        
        do {
            let request = try urlRequest.signed(with: loader.oauth2)
            
            return completion(.success(request))
        } catch {
            print("Unable to sign request: \(error)")
            return completion(.failure(error))
        }
    }
}

extension Date {
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var afterTomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 2, to: self)!
    }
}

enum Deltas {
    case today
    case tomorrow
    case dayAfterTomorrow
}


func getDateAsString(choosenFormat: String = "yyyy-MM-dd", locale: String = "FR-fr", delta: Deltas = .today) -> String{
    
    let date: Date

    switch delta {
    case .today:
        date = Date()
    case .tomorrow:
        date = Date().tomorrow
    case .dayAfterTomorrow:
        date = Date().afterTomorrow
    }

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
func getMeetingLink(_ event: CalendarItem) -> String {
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
            return meetingLink!.url.absoluteString
        }
    }

    return ""
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
    userCalendar.purge()
}

//func printUserDefaults(){
//    let domain = Bundle.main.bundleIdentifier!
//    UserDefaults.standard.synchronize()
//    print(UserDefaults.standard.persistentDomain(forName: domain))
//}
