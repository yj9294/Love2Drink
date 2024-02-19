//
//  RecordView.swift
//  Love2drink
//
//  Created by Super on 2024/2/7.
//

import Foundation
import SwiftUI
import Combine
import ComposableArchitecture
import GADUtil

@Reducer
struct Record {
    enum Item: String, CaseIterable, Codable {
        case water, drinks, milk, coffee, tea, custom
        var title: String {
            self.rawValue.capitalized
        }
        var icon: String {
            "record_\(self.rawValue)"
        }
    }
    
    @ObservableState
    struct State: Equatable {
        var drinks: [DrinkModel] = CacheUtil.getDrinks()
        var item: Item = .water
        var name: String = "Custom"
        var ml: String = "200"
        
        mutating func updateItem(_ item: Item) {
            self.item = item
            self.ml = "200"
        }
        
        mutating func appedDrinks(ml: Int) {
            let drinkModel = DrinkModel(date: Date(), item: item, name: name, ml: ml, goal: CacheUtil.getGoal())
            drinks.insert(drinkModel, at: 0)
            CacheUtil.setDrinks(drinks)
        }
    }
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case dismissButtonTapped
        case saveButtonTapped
        case didSelected(Item)
        
        case showInterAD
        case updatedDrinks
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce{ state, action in
            if case .dismissButtonTapped = action {
                GADUtil.share.disappear(.native)
                GADUtil.share.load(.native)
                return .run { _ in
                    await dismiss()
                }
            }
            if case let .didSelected(item) = action {
                state.updateItem(item)
            }
            if case .saveButtonTapped = action {
                if let ml = Int(state.ml), ml > 0 {
                    state.appedDrinks(ml: ml)
                    return .run { send in
                        await send(.updatedDrinks)
                        await self.dismiss()
                    }
                }
            }
            if case .showInterAD = action {
                let pulbisher = Future<Action, Never> { promise in
                    GADUtil.share.load(.interstitial)
                    GADUtil.share.show(.interstitial) { _ in
                        promise(.success(.saveButtonTapped))
                    }
                }
                return .publisher {
                    pulbisher
                }
            }
            return .none
        }
    }
}

struct RecordView: View {
    @ComposableArchitecture.Bindable var store: StoreOf<Record>
    var body: some View {
        VStack{
            _NavigationBar(store: store)
            _ContentView(store: store)
            Spacer()
        }.background
    }
    
    struct _NavigationBar: View {
        let store: StoreOf<Record>
        var body: some View {
            ZStack{
                Image("record_title")
                HStack{
                    Button(action: {store.send(.dismissButtonTapped)}, label: {
                        Image("back").padding(.leading, 16)
                    })
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Button(action: {store.send(.showInterAD)}, label: {
                        Text("Save").foregroundStyle(.black).background(Image("record_button")).font(.system(size: 14.0)).padding(.trailing, 35)
                    })
                }
            }.frame(height: 44)
        }
    }
    
    struct _ContentView: View {
        @ComposableArchitecture.Bindable var store: StoreOf<Record>
        var body: some View {
            VStack{
                _ContentTitleView(store: store)
                _ContentListView(store: store)
            }
        }
    }
    
    struct _ContentTitleView: View {
        @ComposableArchitecture.Bindable var store: StoreOf<Record>
        var body: some View {
            ZStack{
                Image("record_bg")
                VStack{
                    VStack(spacing: 0){
                        HStack{
                            Spacer()
                            WithPerceptionTracking{
                                if store.item == .custom {
                                    TextField("", text: $store.name).padding(.horizontal, 60).multilineTextAlignment(.center)
                                } else {
                                    Text(store.item.title)
                                }
                            }
                            Spacer()
                        }.font(.system(size: 24)).padding(.vertical, 12)
                        Color.black.frame(height: 1)
                        HStack{
                            Spacer()
                            HStack(spacing: 0){
                                WithPerceptionTracking {
                                    TextField("", text: $store.ml).multilineTextAlignment(.center)
                                }
                                Text("ml")
                            }.font(.system(size: 20)).padding(.horizontal, 60)
                            Spacer()
                        }.padding(.vertical, 12).background(Color(uiColor: UIColor(hex: 0xEDFF8F)).cornerRadius(12))
                    }.background(Color.white.cornerRadius(12).background( RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 2)))
                }.padding(.horizontal, 85)
            }
        }
    }
    
    struct _ContentListView: View {
        let store: StoreOf<Record>
        var body: some View {
            LazyVGrid(columns: [GridItem(.flexible())], content: {
                ForEach(Record.Item.allCases, id: \.self) { item in
                    Button(action: {store.send(.didSelected(item))}, label: {
                        HStack(spacing: 16){
                            Image(item.icon)
                            Text(item.title)
                            Spacer()
                            Text("200ml").font(.system(size: 14)).foregroundStyle(Color.black.opacity(0.3)).padding(.trailing, 23)
                        }.foregroundStyle(.black)
                    }).background(RoundedRectangle(cornerRadius: 12).stroke(Color.black))
                }
            }).padding(.horizontal, 20).padding(.top, 15)
        }
    }
}

#Preview {
    RecordView(store: Store(initialState: Record.State(), reducer: {
        Record()
    }))
}

