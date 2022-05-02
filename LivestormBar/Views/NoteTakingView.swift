//
//  EventDetailView.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 21/04/2022.
//

import SwiftUI

struct NoteTakingView: View {
    @State private var fullText: String = "Take some notes for this meeting - DEMO ONLY CONTENT IS NOT SAVED"

    var body: some View {
        TextEditor(text: $fullText)
            .foregroundColor(Color.black)
            .font(.custom("HelveticaNeue", size: 16))
            .cornerRadius(16)
            .padding(16)
    }
}


struct NoteTakingView_Previews: PreviewProvider{
    static var previews: some View{
        NoteTakingView()
    }
}

