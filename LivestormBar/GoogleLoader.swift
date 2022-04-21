//
//  GoogleDataLoader.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import Foundation
import OAuth2

let loader = GoogleLoader()

class GoogleLoader: OAuth2DataLoader {
    
    let baseURL = URL(string: "https://www.googleapis.com")!
    
//    294330188609-s5t4l16lrpmkpc73jmu4kd368gjqjgj7
//    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
    
    public init() {
        let oauth = OAuth2CodeGrant(settings: [
            "client_id": "294330188609-s5t4l16lrpmkpc73jmu4kd368gjqjgj7.apps.googleusercontent.com",
            "client_secret": "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",
            "authorize_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://www.googleapis.com/oauth2/v3/token",
            "scope": "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/calendar.events https://www.googleapis.com/auth/userinfo.email",
            "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob"],
        ])
        oauth.authConfig.authorizeEmbedded = true
        oauth.logger = OAuth2DebugLogger(.debug)
        super.init(oauth2: oauth, host: "https://www.googleapis.com")
        alsoIntercept403 = true
    }
    
    /** Perform a request against the API and return decoded JSON or an Error. */
    func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
        let url = baseURL.appendingPathComponent(path)
        let req = oauth2.request(forURL: url)
        
        perform(request: req) { response in
            do {
                let dict = try response.responseJSON()
                var profile = [String: String]()
                if let name = dict["name"] as? String {
                    profile["name"] = name
                }
                if let avatar = dict["picture"] as? String {
                    profile["picture"] = avatar
                }
                if let error = (dict["error"] as? OAuth2JSON)?["message"] as? String {
                    DispatchQueue.main.async {
                        callback(nil, OAuth2Error.generic(error))
                    }
                }
                else {
                    DispatchQueue.main.async {
                        callback(profile, nil)
                    }
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    callback(nil, error)
                }
            }
        }
    }
    
    func requestTodayEvents(path: String, callback: @escaping ((CalendarResponse?, Error?) -> Void)) {
        //let url = baseURL.appendingPathComponent(path)
        
        let todayDate = getTodayDate()
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.googleapis.com"
        urlComponents.path = path
        urlComponents.queryItems = [
           URLQueryItem(name: "timeMax", value: "\(todayDate)T23:59:59Z"),
           URLQueryItem(name: "timeMin", value: "\(todayDate)T00:00:00Z"),
        ]
        print(urlComponents.url!)
        
        let req = oauth2.request(forURL: urlComponents.url!)
        
        perform(request: req) { response in
            do {
                let data = try response.responseData()
//                print(try response.responseJSON())
                let error = response.error
                let decoder = JSONDecoder()
                let calResponse = try decoder.decode(CalendarResponse.self, from: data)
                
                
                if error != nil {
                    DispatchQueue.main.async {
                        print(error)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        callback(calResponse, nil)
                    }
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    callback(nil, error)
                }
            }
        }
    }
    
    func requestUserdata(callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void)) {
        request(path: "/oauth2/v1/userinfo", callback: callback)
    }
    
    func requestTodayEvents(calendarID: String, callback: @escaping ((_ dict: CalendarResponse?, _ error: Error?) -> Void)) {
        requestTodayEvents(path: "/calendar/v3/calendars/\(calendarID)/events", callback: callback)
    }
}

