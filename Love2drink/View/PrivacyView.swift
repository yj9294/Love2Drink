//
//  PrivacyView.swift
//  Love2drink
//
//  Created by Super on 2024/2/8.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct Privacy {
    @ObservableState
    struct State: Equatable {}
    enum Action: Equatable {
        case dismissButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            if case .dismissButtonTapped = action {
                return .run { send in
                    await self.dismiss()
                }
            }
            return .none
        }
    }
}

struct PrivacyView: View {
    let store: StoreOf<Privacy>
    var body: some View {
        VStack{
            _NavigationBar(store: store)
            _ContentView()
        }.background
    }
    
    struct _NavigationBar: View {
        let store: StoreOf<Privacy>
        var body: some View {
            ZStack{
                Image("privacy_title")
                HStack{
                    Button(action: {store.send(.dismissButtonTapped)}, label: {
                        Image("back").padding(.leading, 16)
                    })
                    Spacer()
                }
            }
        }
    }
    
    struct _ContentView: View {
        var body: some View {
            ScrollView{
                Text("""
Privacy Policy
Please read this privacy policy in detail. This Privacy Policy is intended to inform you about the personal data we collect from you. We will use and protect your personal information through formal means and we will legally share your personal information.
What information will we collect
In the process of using the application, we may collect the following information: user set water consumption goals and reminder frequencies, as well as water consumption record data. At the same time, our application may also automatically collect some technical information to improve the user experience and application performance, such as device information (model, operating system version, etc.), application usage statistics, IP address, application crash report.
How we use your information
The information we collect will be used for the following purposes:
Provide drinking water reminder service and send customized reminders based on user settings
Statistics on user drinking habits to help them better achieve their goal of healthy drinking water
Improve the functionality and performance of applications
Send notifications and updates related to applications
How will we share your information
We promise not to sell, exchange, or transfer your personal information to third parties, except in the following situations: with your consent, in accordance with legal provisions or compliance requirements, in order to protect our rights, property, or security
About children's privacy
We promise that our applications and services are not suitable for people aged 17 and below. If we find that children under the age of 17 have provided us with personal information, we will immediately delete that information from the server. If you are a parent or guardian and know that your child has provided us with personal information, please contact us and we will actively cooperate.
Update
We may update this Privacy Policy on this page.
""").font(.system(size: 14)).foregroundStyle(Color.black).lineLimit(nil)
            }.padding(.all, 20)
        }
    }
}
