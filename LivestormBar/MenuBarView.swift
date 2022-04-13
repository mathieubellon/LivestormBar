//
//  MenuBarView.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import SwiftUI

struct MenuBarView: View{
    @Namespace var animation
    @State var currentTab = "Uploads"
    var body: some View{
        VStack{
            HStack{
                VStack {
                    Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                    VStack{
                        HStack{
                            TabButton(title: "Help", currentTab: $currentTab)
                            TabButton(title: "Uploads", currentTab: $currentTab)
                        }
                    }
                }
                
            }.frame(width: 400, height: 400, alignment: .center)
        }
    }
}

struct MenuBarView_Previews: PreviewProvider{
    static var previews: some View{
        MenuBarView()
    }
}

struct TabButton: View{
    var title: String
    @Binding var currentTab: String
    
    var body: some View{
        Button(action: {}, label: {
            Text(title)
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(currentTab == title ? .white : .primary)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack{
                        
                    }
                )
        })
    }
}

