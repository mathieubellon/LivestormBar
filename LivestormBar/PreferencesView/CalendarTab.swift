//
//  CalendarTab.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 20/04/2022.
//

import SwiftUI
import OAuth2
import Defaults

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
        print("Open calendar tab")
        
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
            HStack{
                Image(systemName: "icloud.slash")
                    .foregroundColor(.gray)
                    .imageScale(.large)
                    .font(.system(size: 30, weight: .semibold))
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                Text("Calendar not connected").font(.system(size: 16, weight: .bold))
                Spacer()
                Button("Connect to Google Calendar") {
                    oauthDanceLaunch()
                }
            }
            HStack(alignment: .center, spacing: 10){
                if picture != nil{
                    Image(nsImage: NSImage(contentsOf: URL(string: picture!)!)!)
                        .resizable()
                        .frame(width: 90.0, height: 90.0)
                }else{
                    
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                        .font(.system(size: 30, weight: .semibold))
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                }
                
                VStack(alignment: .leading,spacing: 5){
                    Text(username!).font(.system(size: 16, weight: .bold))
                    Text(email).foregroundColor(.purple)
                }
                Spacer()
                
                Button("Disconnect") {
                    forgetTokens()
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
    loader.oauth2.forgetTokens()
    print(Bundle.main.bundleIdentifier!)
    // TODO : forEach key or Defaults.removeAll(suite: UserDefaults = .standard)
    Defaults.reset("username", "email", "picture", "isauthenticated")
}

func oauthDanceLaunch(){
    NSLog("Launch Oauth Dance")
    // config OAuth2
    loader.requestUserdata() { dict, error in
        if let error = error {
            switch error {
            case OAuth2Error.requestCancelled:
                ud.set("cancelled", forKey: "oautherror")
            default:
                ud.set("globale", forKey: "oautherror")
            }
        }
        else {
            
            if let imgURL = dict?["picture"] as? String {
                // This does not work for NSImageView and drives my crazy and forces me to use IKImageView
                //let image = NSImage(byReferencing:NSURL(string: imgURL)! as URL)
                //self.avatarImage?.image = image
                Defaults[.picture] = imgURL
                
            }
            if let username = dict?["name"] as? String {
                
                Defaults[.username] = username
            }
            if let email = dict?["email"] as? String {
                
                Defaults[.email] = email
            }
        }
    }
}