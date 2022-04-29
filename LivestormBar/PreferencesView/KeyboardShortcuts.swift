//
//  KeyboardShortcuts.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 29/04/2022.
//
import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let openNextEvent = Self("openNextEvent")
}

struct SetKeyboardShortcuts: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            
            Form {
                KeyboardShortcuts.Recorder("Open next event:", name: .openNextEvent)
            }
            Spacer()
            
        }.padding()

    }
}
