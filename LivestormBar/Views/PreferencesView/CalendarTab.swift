//
//  CalendarTab.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 20/04/2022.
//

import SwiftUI
import OAuth2
import Defaults
import Alamofire

let ud = UserDefaults.standard

//guard let imageURL = URL(string: url) else { return }
//
//       // just not to cause a deadlock in UI!
//   DispatchQueue.global().async {
//       guard let imageData = try? Data(contentsOf: imageURL) else { return }
//
//       let image = UIImage(data: imageData)
//       DispatchQueue.main.async {
//           self.imageView.image = image
//       }
//   }


struct CalendarTab: View {
    
    init(){
        NSLog("Open calendar tab")
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            
            yourCalendarView()
            Spacer()
            
        }.padding()
    }
}

struct yourCalendarView: View {
    @State var showingModal = false
    
    
    @Default(.username) var username
    @Default(.email) var email
    @Default(.picture) var picture
    @Default(.isAuthenticated) var isAuthenticated
    
    
    var body: some View {
        VStack{
            if email != nil {
                HStack(alignment: .center, spacing: 10){
                    if picture != nil{
                        Image(nsImage: NSImage(contentsOf: URL(string: picture!)!)!)
                            .resizable()
                            .frame(width: 90.0, height: 90.0)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }else{
                        
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                            .font(.system(size: 30, weight: .semibold))
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                    }
                    
                    VStack(alignment: .leading,spacing: 5){
                        Text("you_are_connected").font(.system(size: 20, weight: .bold))
                        
                        HStack{
                            Text("connection_to_default_calendar").foregroundColor(.black).padding(.trailing, 0.2)
                            Text(email ?? "No email").foregroundColor(.black).font(.system(size: 12, weight: .bold))
                        }
                        
                    }
                    Spacer()
                    
                    Button(NSLocalizedString("disconnect", comment: "")) {
                        forgetTokens()
                    }
                }
            }else{
                HStack{
                    Image(systemName: "icloud.slash")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                        .font(.system(size: 30, weight: .semibold))
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                    Text("calendar_not_connected").font(.system(size: 16, weight: .bold))
                    Spacer()
                    Button("connect_to_google_calendar") {
                        oauthDanceLaunch()
                    }
                }
            }
            
            
        }
    }
}




struct yourCalendarView_Previews: PreviewProvider{
    static var previews: some View{
        yourCalendarView()
    }
}

func forgetTokens() {
    NSLog("Deleting token")
    GoogleOauth2.forgetTokens()
    // print(Bundle.main.bundleIdentifier!)
    // TODO : forEach key or Defaults.removeAll(suite: UserDefaults = .standard)
    Defaults.reset("username", "email", "picture", "isAuthenticated")
    userCalendar.purge()
}

func oauthDanceLaunch(){
    NSLog("Launch Oauth Dance")
    let baseURL = URL(string: "https://www.googleapis.com")!
    let path = "/oauth2/v1/userinfo"
    // config OAuth2
//    let urlComponents = URLComponents()
    let url = baseURL.appendingPathComponent(path)
    
    
    AF.request(url, interceptor: OAuth2RetryHandler(oauth2: GoogleOauth2), requestModifier: { $0.timeoutInterval = 5 }).validate().response() {response in
        switch response.result {
        case .success(let data):
            do {
                let user = try JSONDecoder().decode(UserInfo.self, from: data!)
                print("USERINFO : \(user)")
                Defaults[.picture] = user.picture
                Defaults[.email] = user.email
                Defaults[.username] = user.name
                userCalendar.fetchEvents(calendarID: user.email)
            }catch{
                NSLog("Error decoding JSON")
            }
        case .failure(let error):
            NSLog("Error requesting UserInfo : \(error)")
        }
    }
}
