//
//  ProfileData.swift
//  Love2drink
//
//  Created by Super on 2024/2/8.
//

import Foundation

enum SettingItem: String, CaseIterable {
    case reminder, privacy, rate
    var title: String {
        switch self {
        case .reminder:
            return "Reminder Time"
        case .privacy:
            return "Privacy Policy"
        case .rate:
            return "Rate Us"
        }
    }
    
    var icon: String {
        return "profile_\(self.rawValue)"
    }
}

enum TipItem: String, CaseIterable {
    case tip1, tip2, tip3
    
    var title: String {
        switch self {
        case .tip1:
            return "How much water do you need to drink every day?"
        case .tip2:
            return "The more water you drink, the better it is, which is a mistake"
        case .tip3:
            return "When should I drink water?"
        }
    }
    
    var icon: String {
        "tip_\((TipItem.allCases.firstIndex(of: self) ?? 0) + 1)"
    }
    
    var backgroud: String {
        "tip_bg\((TipItem.allCases.firstIndex(of: self) ?? 0) + 1)"
    }
    
    var description: String {
        switch self {
        case .tip1:
            return """
In general, a healthy adult needs between 2000-2300 milliliters of water per day, which is equivalent to 7-8 cups of a regular water glass. However, not all of this water is obtained by drinking water, and the water in food should be included. In fact, the various foods we eat every day contain a lot of water. For example, most vegetables and fruits contain over 90% water, while eggs and fish also contain about 75% water. Roughly estimated, we can consume at least 300-400 milliliters of water from food or soup during a meal. Therefore, after deducting the 1000-1200 milliliters of water intake from food in the three meals, we only need to drink another 1000-1200 milliliters of water every day. On average, 2-3 cups in the morning and 2-3 cups in the afternoon are considered basic skills.
"""
        case .tip2:
            return """
Many people believe that drinking too much water every day is actually harmful and not beneficial. Because the human body is a balanced system, the kidneys can only excrete 800-1000 milliliters of water per hour. Drinking more than 1000 milliliters of water within an hour can lead to hyponatremia. Moreover, drinking too much water can lead to electrolyte imbalance (significant loss of sodium and potassium ions), as well as easy loss of water-soluble vitamins (such as Group B and C). Nutrition experts point out that drinking water should be like consuming calories, "replenish as much as you need".
Usually, the amount of water each person needs to drink varies depending on their activity level, environment, and even weather conditions. Drinking too much water for a normal person will not have a significant impact on their health, but it may lead to increased urine output and inconvenience in daily life. However, for certain special groups of people, special attention must be paid to the amount of water they drink. For example, patients with edema, heart failure, and kidney failure should not drink too much water because drinking too much water can increase the burden on the heart and kidneys, which can easily lead to worsening of the condition. The amount of water these people should drink should depend on their condition and listen to the doctor's specific advice.
"""
        case .tip3:
            return """
As for the drinking time, experts suggest that we should drink water in moderation between meals, preferably every hour. People can also judge whether they need to drink water based on the color of their urine. Generally speaking, human urine is light yellow. If the color is too light, it may be due to drinking too much water. If the color is too dark, it indicates that more water needs to be added. Drinking less before bedtime and more after bedtime is also the correct principle for drinking water, because drinking too much water before bedtime can cause eye swelling and frequent urination in the middle of the night, resulting in poor sleep quality. After a night of sleep, the human body loses about 450 milliliters of water, which needs to be replenished in a timely manner in the morning. Therefore, drinking a glass of water on an empty stomach after waking up in the morning is beneficial for blood circulation and can also promote brain wakefulness, making the thinking clear and agile for the day.
"""
        }
    }
    
    
}
