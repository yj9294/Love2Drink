//
//  ChartsModel.swift
//  Love2drink
//
//  Created by Super on 2024/2/7.
//

import Foundation

struct ChartsModel: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var progress: CGFloat
    var ml: Int
    var unit: String // 描述 类似 9:00 或者 Mon  或者03/01 或者 Jan
}
