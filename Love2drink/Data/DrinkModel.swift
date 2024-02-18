//
//  DrinkModel.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import Foundation

struct DrinkModel: Codable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var date: Date
    var item: Record.Item // 列别
    var name: String
    var ml: Int // 毫升
    var goal: Int
    
    var trueName: String {
        item == .custom ? name : item.title
    }
}
