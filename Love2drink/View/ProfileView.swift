//
//  ProfileView.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct Profile {
    @ObservableState
    struct State: Equatable {
        
        var ad: GADNativeViewModel = .none
        
        @Presents var reminder: Reminder.State?
        mutating func presetnReminder() {
            reminder = .init(ad: ad)
        }
        
        @Presents var detail: Detail.State?
        mutating func presentDetail(_ item: TipItem) {
            detail = .init(item: item)
        }
        
        @Presents var privacy: Privacy.State?
        mutating func presentPrivacy() {
            privacy = .init()
        }
    }
    enum Action: Equatable {
        
        case presentReminder
        case presentPrivacy
        case presentTip(TipItem)
        
        case reminder(PresentationAction<Reminder.Action>)
        case detail(PresentationAction<Detail.Action>)
        case privacy(PresentationAction<Privacy.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            if case .presentReminder = action {
                state.presetnReminder()
            }
            if case let .presentTip(item) = action {
                state.presentDetail(item)
            }
            if case .presentPrivacy = action {
                state.presentPrivacy()
            }
            return .none
        }.ifLet(\.$reminder, action: \.reminder) {
            Reminder()
        }.ifLet(\.$detail, action: \.detail) {
            Detail()
        }.ifLet(\.$privacy, action: \.privacy) {
            Privacy()
        }
    }
}

struct ProfileView: View {
    let store: StoreOf<Profile>
    var body: some View {
        VStack{
            _NavigationBar()
            WithPerceptionTracking {
                ScrollView(showsIndicators: false, content: {
                    _ContentView(store: store)
                })
            }
            Spacer()
        }.background
    }
    
    struct _NavigationBar: View {
        var body: some View {
            ZStack{
                Image("profile_title")
            }.frame(height: 44)
        }
    }
    
    struct _ContentView: View {
        @ComposableArchitecture.Bindable var store: StoreOf<Profile>
        var body: some View {
            WithPerceptionTracking {
                ScrollView{
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 14) {
                        ForEach(SettingItem.allCases, id: \.self) { item in
                            Button {
                                if item == .reminder {
                                    store.send(.presentReminder)
                                } else if item == .privacy {
                                    store.send(.presentPrivacy)
                                } else if item == .rate {
                                    if let url = URL(string: "https://apps.apple.com/app/6478846041") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            } label: {
                                _ItemView(item: item)
                            }
                        }
                    }.padding(.all, 20)
                    LazyVGrid(columns: [GridItem(.flexible())]) {
                        ForEach(TipItem.allCases, id: \.self) { item in
                            Button(action: {
                                store.send(.presentTip(item))
                            }, label: {
                                _TipView(tip: item)
                            })
                        }
                    }
                }.foregroundStyle(Color.black).fullScreenCover(item: $store.scope(state: \.reminder, action: \.reminder)) { store in
                    ReminderView(store: store)
                }.fullScreenCover(item: $store.scope(state: \.detail, action: \.detail)) { store in
                    DetailView(store: store)
                }.fullScreenCover(item: $store.scope(state: \.privacy, action: \.privacy)) { store in
                    PrivacyView(store: store)
                }
            }
        }
    }

    struct _ItemView: View {
        let item: SettingItem
        var body: some View {
            HStack{
                Image(item.icon)
                Text(item.title)
                Spacer()
            }.padding(.leading, 12).padding(.vertical, 18).background(Image("profile_button").resizable())
        }
    }
    
    struct _TipView: View {
        let tip: TipItem
        var body: some View {
            HStack(spacing: 10){
                Image(tip.icon)
                Text(tip.title).lineLimit(2).multilineTextAlignment(.leading)
                Spacer()
            }.padding(.all, 12).background(Image(tip.backgroud).resizable()).padding(.horizontal, 20)
        }
    }
}

#Preview {
    ProfileView(store: Store(initialState: Profile.State(), reducer: {
        Profile()
    }))
}
