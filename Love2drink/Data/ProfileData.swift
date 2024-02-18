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
            return "The key to keeping your body hydrated"
        case .tip2:
            return "Choose which is better, warm or cold"
        case .tip3:
            return "Scientific drinking time, improve water use efficiency"
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
Keeping enough water is essential to good health. Maintaining the body's water balance not only helps eliminate waste and toxins, but also maintains normal physiological functions. Here are some tips to help you keep your body hydrated more scientifically.
First, understanding your body's needs is fundamental to maintaining a water balance. Each person's water needs are different, depending on factors such as age, sex, weight, activity level and climatic conditions. The scientific method is to adjust the amount of water according to their own conditions, in general, the recommended amount of water for adults is about 8 cups (about 2 liters) per day, but it needs to be moderately increased under high temperature, exercise and other circumstances.
Secondly, reasonable arrangement of drinking time is the key to maintaining water balance. The first glass of water after you wake up can help clear out nighttime metabolites and activate your body's metabolism. Proper drinking water before and after meals helps to promote digestion and absorption, and it is necessary to replenish water in time during exercise to maintain body fluid balance. Gradually develop a good habit of regular drinking water, help the body to better absorb water, improve the body water use efficiency.
Finally, it's not just drinking water, the water in food is also an important source of water balance. Eat more fruits, vegetables and other foods rich in water, help to supplement the body needs water. In addition, avoid excessive consumption of caffeine and sugary drinks, as they may cause excessive excretion of urine and affect the body's water balance.
In short, by understanding your individual needs, rationalizing your drinking time, and supplementing your food with water, you can maintain your body's water balance more scientifically. Maintaining good drinking habits will lay a solid foundation for good health.
"""
        case .tip2:
            return """
In daily life, choosing to drink warm water or cold water has always been a topic of concern. In fact, both have their own advantages in different situations. Here are some tips to help you more scientifically choose the right water temperature for maximum health benefits.
First, warm water helps to boost metabolism. The right amount of warm water can stimulate the gastrointestinal peristalsis, promote the digestion and absorption of food, and help accelerate the metabolic process. This is especially important for people who want to control their weight or improve indigestion. Therefore, drinking a glass of warm water after waking up in the morning can quickly wake up the body and provide energy for the day's activities.
Secondly, cold water is more advantageous during hot weather or after strenuous exercise. The right amount of cold water can quickly lower the body temperature and relieve the temperature rise caused by hot weather or exercise. In addition, cold water also helps to constrict blood vessels and improve blood circulation, which helps to relieve fatigue.
However, it is necessary to choose according to the individual's physique and preferences. Some people prefer warm water because it is more gentle and comfortable; Some people prefer cold water because it can bring a refreshing feeling. In daily life, warm water and cold water can be alternately selected according to the specific situation to meet the individual taste and needs.
In general, warm and cold water each have their own application, according to personal preferences and actual needs, to help better enjoy the health benefits of drinking water.
"""
        case .tip3:
            return """
Drinking water is a basic need to maintain life, and scientific and reasonable drinking time is also crucial. Here are some tips to help you time your water more scientifically, improve the efficiency of water use in your body, and thus better maintain your health.
First of all, waking up in the morning is the best time of day to drink water. At this point, the body has just spent the night and is already in a state of dehydration. Drinking a glass of warm water can quickly wake up the body, activate the metabolism, and provide energy for the day's activities.
Secondly, proper drinking water before and after meals helps to promote digestion and absorption. Drinking the right amount of water 30 minutes before and after meals helps to slow the speed of food passing through the gastrointestinal tract, improve the efficiency of food digestion, and thus better absorb nutrients.
During exercise, it is very important to hydrate properly. A lot of exercise causes the body to sweat a lot and lose water. Therefore, before, during and after exercise, it is necessary to drink adequate amounts of water to maintain fluid balance and prevent dehydration.
Drinking a moderate amount of water before going to bed at night is also a scientific healthy habit. The right amount of water helps relieve thirst at night, maintain the body's water balance, and promote good sleep quality.
Through reasonable arrangement of drinking time, it helps to better meet the physiological needs of the body, improve water use efficiency, and promote health. It is recommended to scientifically and reasonably arrange daily drinking time according to personal living habits and actual situation to provide a full range of water support for the body.
"""
        }
    }
    
    
}
