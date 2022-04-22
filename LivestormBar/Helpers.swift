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
