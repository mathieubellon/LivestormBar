//
//  OnboardingView.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 29/04/2022.
//

import SwiftUI

struct OnboardingView: View {
    
    var body: some View {
        VStack(alignment: .center) {
            HStack{
                Text("greeting_app_installed").font(.system(size: 30)).bold().padding(10)
            }.padding()
            VStack (alignment: .leading, spacing: 10.0){
                Text("tip_connect_calendar").font(.system(size: 20))
                Text("onboarding_tip_shortcut").font(.system(size: 20))
            }
            Image(nsImage: NSImage(named: "youdidit")!).resizable().frame(width: 911.75, height: 600.0).padding()

        }
    }
}


struct OnboardingView_Previews: PreviewProvider{
    static var previews: some View{
        OnboardingView()
            .frame(width: 600.0, height: 700.0)
    }
}

