//
//  ReminderData.swift
//  Love2drink
//
//  Created by Super on 2024/2/8.
//

import Foundation

struct ReminderModel: Codable, Hashable {
    var hour: Int
    var minute: Int
    var title: String {
        // 注意 hour 采用 24 进制
        return String(format: "%02d:%02d", hour, minute)
    }
    
    var timeSinceNowInSec: TimeInterval {
        let dateStr = Date().date + " " + title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = formatter.date(from: dateStr)
        var d = date?.timeIntervalSinceNow ?? 0
        if d < 0 {
            // 在当前之前就往后推一天
            d += (24 * 3600)
        }
        return d
    }
    
    static let models: [ReminderModel] = Array(8...20).filter({$0 % 2 == 0}).map({ReminderModel(hour: $0, minute: 0)})
    
    static func parse(_ time: String ) -> ReminderModel {
        let hour: Int = Int(time.components(separatedBy: ":").first ?? "") ?? 0
        let minute: Int = Int(time.components(separatedBy: ":").last ?? "") ?? 0
        return ReminderModel(hour: hour, minute: minute)
    }
}
