//
//  HomeView.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import AppTrackingTransparency

@Reducer
struct Home {
    enum Item: String, CaseIterable {
        case drink, charts, medal, profile
        var title: String {
            self.rawValue.capitalized
        }
        var icon: String {
            "home_\(self.rawValue)"
        }
        var selectedIcon: String {
            "home_\(self.rawValue)_selected"
        }
        
        func isSelected(_ item: Item) -> Bool {
            item == self
        }
    }
    
    @ObservableState
    struct State: Equatable {
        var item: Item = .drink
        mutating func updateItem(_ item: Item) {
            self.item = item
        }
        
        var drink: Drink.State = .init()
        var charts: Charts.State = .init()
        var medal: Medal.State = .init()
        var profile: Profile.State = .init()
        
        mutating func updatedGoal() {
            let goal = CacheUtil.getGoal()
            drink.goal = goal
        }
        
        mutating func updatedDrinks() {
            let drinks = CacheUtil.getDrinks()
            drink.drinks = drinks
            charts.drinks = drinks
        }
    }
    enum Action: Equatable {
        case updateItem(Item)
        
        case drink(Drink.Action)
        case charts(Charts.Action)
        case medal(Medal.Action)
        case profile(Profile.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            if case let .updateItem(item) = action {
                state.updateItem(item)
            }
            
            // daily view 点击更改每日目标饮水量
            if case .drink(.dailyGoal(.presented(.updatedGoal))) = action {
                state.updatedGoal()
            }
            
            // recod view 新增饮水记录
            if case .drink(.record(.presented(.updatedDrinks))) = action {
                state.updatedDrinks()
            }
            return .none
        }
        
        Scope(state: \.drink, action: \.drink) {
            Drink()
        }
        
        Scope(state: \.charts, action: \.charts) {
            Charts()
        }
        
        Scope(state: \.medal, action: \.medal) {
            Medal()
        }
        
        Scope(state: \.profile, action: \.profile) {
            Profile()
        }
    }
}

struct HomeView: View {
    let store: StoreOf<Home>
    var body: some View {
        VStack{
            ScrollView(showsIndicators: false){
                _ContentView(store: store)
            }
            _TabbarItemView(store: store)
            
        }.background.onAppear{
            ATTrackingManager.requestTrackingAuthorization { _ in
            }
        }
    }
    
    struct _ContentView: View {
        let store: StoreOf<Home>
        var body: some View {
            VStack{
                WithPerceptionTracking {
                    if store.item == .drink {
                        DrinkView(store: store.scope(state: \.drink, action: \.drink))
                    } else if store.item == .charts {
                        ChartsView(store: store.scope(state: \.charts, action: \.charts))
                    } else if store.item == .medal {
                        MedalView(store: store.scope(state: \.medal, action: \.medal))
                    } else if store.item == .profile {
                        ProfileView(store: store.scope(state: \.profile, action: \.profile))
                    }
                }
            }
        }
    }
    
    struct _TabbarItemView: View {
        let store: StoreOf<Home>
        var body: some View {
            HStack{
                ForEach(Home.Item.allCases, id: \.self) { item in
                    WithPerceptionTracking {
                        ItemView(item: item, isSelected: item.isSelected(store.item)) {
                            store.send(.updateItem(item))
                        }
                    }
                }
            }.padding(.horizontal, 6).padding(.bottom, 4)
        }
    }
    
    struct ItemView: View {
        let item: Home.Item
        let isSelected: Bool
        let action: ()->Void
        var body: some View {
            Button(action: action, label: {
                HStack(spacing: 6){
                    Spacer()
                    Image(!isSelected ? item.icon : item.selectedIcon)
                    Text(item.title).font(.system(size: 11)).foregroundStyle(Color(uiColor: UIColor(hex: 0x1B2A46)))
                    Spacer()
                }.padding(.vertical, 12)
            }).background(isSelected ? AnyView(Image("home_selected")) : AnyView(Color.clear))
        }
    }
}

#Preview {
    HomeView(store: Store(initialState: Home.State(), reducer: {
        Home()
    }))
}
