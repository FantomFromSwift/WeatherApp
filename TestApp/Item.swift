//
//  Item.swift
//  TestApp
//
//  Created by Иван Непорадный on 02.03.2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
