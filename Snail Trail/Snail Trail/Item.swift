//
//  Item.swift
//  Snail Trail
//
//  Created by Logan Gutknecht on 9/5/24.
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
