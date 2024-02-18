//
//  HistoryView.swift
//  Love2drink
//
//  Created by Super on 2024/2/7.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct History {
    @ObservableState
    struct State: Equatable {
        let drinks = CacheUtil.getDrinks()
        var datasource: [[DrinkModel]] {
            drinks.reduce([]) { (result, item) -> [[DrinkModel]] in
                var result = result
                if result.count == 0 {
                    result.append([item])
                } else {
                    if var arr = result.last, let lasItem = arr.last, lasItem.date.date == item.date.date  {
                        arr.append(item)
                        result[result.count - 1] = arr
                    } else {
                        result.append([item])
                    }
                }
               return result
            }
        }
    }
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

struct HistoryView: View {
    let store: StoreOf<History>
    var body: some View {
        VStack{
            _NavigationBar(store: store)
            _ContentView(store: store)
            Spacer()
        }.background
    }
    
    struct _NavigationBar: View {
        let store: StoreOf<History>
        var body: some View {
            ZStack{
                Image("history_title")
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
        let store: StoreOf<History>
        var body: some View {
            ScrollView{
                LazyVGrid(columns: [GridItem(.flexible())]) {
                    WithPerceptionTracking {
                        ForEach(store.datasource, id: \.self) { items in
                            _SectionItem(items: items).padding(.vertical, 14)
                        }
                    }
                }
            }.padding(.all, 20)
        }
    }
    
    struct _SectionItem: View {
        let items: [DrinkModel]
        var body: some View {
            VStack(alignment: .leading){
                Text(items.first?.date.date ?? "").foregroundStyle(.black).font(.system(size: 14))
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 11), GridItem(.flexible(), spacing: 11), GridItem(.flexible(), spacing: 11)], spacing: 11, content: {
                    ForEach(items, id: \.self) { item in
                        _RowItem(item: item)
                    }
                })
            }
        }
    }
    
    struct _RowItem: View {
        let item: DrinkModel
        var body: some View {
            VStack(spacing: 4){
                HStack{
                    Spacer()
                    Image(item.item.icon).frame(width: 48, height: 48)
                    Spacer()
                }
                Text(item.trueName).font(.system(size: 16))
                Text("\(item.ml)ml").foregroundStyle(Color.black.opacity(0.3)).font(.system(size: 14.0))
            }.multilineTextAlignment(.center).lineLimit(1).padding(.vertical, 10).background(RoundedRectangle(cornerRadius: 12).stroke(Color.black))
        }
    }
}

#Preview {
    HistoryView(store: Store(initialState: History.State(), reducer: {
        History()
    }))
}
