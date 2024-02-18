//
//  ChartsView.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct Charts {
    enum Item: String, CaseIterable {
        case dayly, weekly, monthly, yearly
        var title: String {
            self.rawValue.capitalized
        }
    }
    
    @ObservableState
    struct State: Equatable {
        var drinks: [DrinkModel] = CacheUtil.getDrinks()
        
        var item: Item = .dayly
        mutating func updateItem(_ item: Item) {
            self.item = item
        }
        
        @Presents var history: History.State?
        mutating func presentHistoryView() {
            history = .init()
        }
        
        var menusource: [Int] = Array(0..<7)
        
        var menusourceString: [String] {
            switch item {
            case .dayly:
                 return menusource.map({
                    "\($0 * 200)"
                 }).reversed()
            case .weekly, .monthly:
                return menusource.map({
                   "\($0 * 500)"
                }).reversed()
            case .yearly:
                return menusource.map({
                   "\($0 * 500 * 30)"
                }).reversed()
            }
        }
        
        var datasource: [ChartsModel] {
            var max = 1
            // 数据源
            // 用于计算进度
            max = menusourceString.map({Int($0) ?? 0}).max { l1, l2 in
                l1 < l2
            } ?? 1
            switch item {
            case .dayly:
                return unitsource.map({ time in
                    let total = drinks.filter { model in
                        model.date.date == Date().date && time == model.date.time
                    }.map({
                        $0.ml
                    }).reduce(0, +)
                    return ChartsModel(progress: Double(total)  / Double(max) , ml: total, unit: time)
                })
            case .weekly:
                return unitsource.map { weeks in
                    // 当前搜索目的周几 需要从周日开始作为下标0开始的 所以 unit数组必须是7123456
                    let week = unitsource.firstIndex(of: weeks) ?? 0
                    
                    // 当前日期 用于确定当前周
                    let weekDay = Calendar.current.component(.weekday, from: Date())
                    let firstCalendar = Calendar.current.date(byAdding: .day, value: 1-weekDay, to: Date()) ?? Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    // 目标日期
                    let target = Calendar.current.date(byAdding: .day, value: week, to: firstCalendar) ?? Date()
                    let targetString = dateFormatter.string(from: target)
                    
                    let total = drinks.filter { model in
                        model.date.date == targetString
                    }.map({
                        $0.ml
                    }).reduce(0, +)
                    return ChartsModel(progress: Double(total)  / Double(max), ml: total, unit: weeks)
                }
            case .monthly:
                return unitsource.reversed().map { date in
                    let year = Calendar.current.component(.year, from: Date())
                    
                    let month = date.components(separatedBy: "/").first ?? "01"
                    let day = date.components(separatedBy: "/").last ?? "01"
                    
                    let total = drinks.filter { model in
                        return model.date.date == "\(year)-\(month)-\(day)"
                    }.map({
                        $0.ml
                    }).reduce(0, +)
                    
                    return ChartsModel(progress: Double(total)  / Double(max), ml: total, unit: date)
                    
                }
            case .yearly:
                return  unitsource.reversed().map { month in
                    let total = drinks.filter { model in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let date = formatter.date(from: model.date.date)
                        formatter.dateFormat = "MMM"
                        let m = formatter.string(from: date!)
                        return m == month
                    }.map({
                        $0.ml
                    }).reduce(0, +)
                    return ChartsModel(progress: Double(total)  / Double(max), ml: total, unit: month)
                }
            }
        }
        
        var unitsource: [String] {
            switch item {
            case .dayly:
                return drinks.filter { model in
                    return model.date.isToday
                }.compactMap { model in
                    model.date.time
                }.reversed().reduce([]) { partialResult, element in
                    return partialResult.contains(element) ?  partialResult : partialResult + [element]
                }
            case .weekly:
                return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            case .monthly:
                var days: [String] = []
                for index in 0..<30 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd"
                    let date = Date(timeIntervalSinceNow: TimeInterval(index * 24 * 60 * 60 * -1))
                    let day = formatter.string(from: date)
                    days.insert(day, at: 0)
                }
                return days
            case .yearly:
                var months: [String] = []
                for index in 0..<12 {
                    let d = Calendar.current.date(byAdding: .month, value: -index, to: Date()) ?? Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM"
                    let day = formatter.string(from: d)
                    months.insert(day, at: 0)
                }
                return months
            }
        }
    }
    enum Action: Equatable {
        case historyButtonTapped
        case didSelected(Item)
        
        case history(PresentationAction<History.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            if case .historyButtonTapped = action {
                state.presentHistoryView()
            }
            
            if case let .didSelected(item) = action {
                state.updateItem(item)
            }
            
            return .none
        }.ifLet(\.$history, action: \.history) {
            History()
        }
    }
}

struct ChartsView: View {
    @ComposableArchitecture.Bindable var store: StoreOf<Charts>
    var body: some View {
        WithPerceptionTracking {
            VStack{
                _NavigationBar(store: store)
                _TopBarView(store: store)
                _ContentView(store: store)
                Spacer()
            }.background.fullScreenCover(item: $store.scope(state: \.history, action: \.history)) { store in
                HistoryView(store: store)
            }
        }
    }
    
    struct _NavigationBar: View {
        let store: StoreOf<Charts>
        var body: some View {
            ZStack{
                Image("charts_title")
                HStack{
                    Spacer()
                    Button(action: {store.send(.historyButtonTapped)}, label: {
                        Image("charts_history")
                    })
                }.padding(.trailing, 20)
            }.frame(height: 44)
        }
    }
    
    struct _TopBarView: View {
        let store: StoreOf<Charts>
        var body: some View {
            HStack(spacing: 7){
                ForEach(Charts.Item.allCases, id: \.self) { item in
                    Button(action: {store.send(.didSelected(item))}) {
                        WithPerceptionTracking {
                            _TopItem(item: item, isSelected: item == store.item)
                        }
                    }
                }
            }.padding(.all, 16)
        }
    }
    
    struct _TopItem: View {
        let item: Charts.Item
        let isSelected: Bool
        var body: some View {
            HStack{
                Spacer()
                Text(item.title).foregroundStyle(.black)
                Spacer()
            }.padding(.vertical, 8).background(Color(uiColor: isSelected ? UIColor(hex: 0xB5FFA5) : UIColor.white).cornerRadius(12).background(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 1)))
        }
    }
    
    struct _ContentView: View {
        let store: StoreOf<Charts>
        var body: some View {
            HStack(spacing: 0){
                _MenuView(store: store)
                _DataView(store: store)
            }.background(RoundedRectangle(cornerRadius: 18).stroke(Color.black)).cornerRadius(18.0).padding(.horizontal, 15)
        }
    }
    
    struct _MenuView: View {
        let store: StoreOf<Charts>
        var body: some View {
            VStack(spacing: 0){
                WithPerceptionTracking {
                    ForEach(store.menusourceString, id: \.self) { item in
                        HStack{
                            Spacer()
                            Text(item).font(.system(size: 12.0))
                        }.foregroundColor(.black).frame(width: 46,height: 54)
                    }
                }
            }.padding(.trailing, 10).padding(.bottom, 38)
        }
    }
    
    struct _DataView: View {
        let store: StoreOf<Charts>
        var body: some View {
            ZStack(alignment: .top){
                VStack(spacing: 0){
                    WithPerceptionTracking {
                        ForEach(store.menusource.indices, id: \.self) { _ in
                            Divider().frame(height: 54)
                        }
                    }
                }.padding(.bottom, 38)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.flexible())]) {
                        WithPerceptionTracking {
                            ForEach(store.datasource, id: \.self) { item in
                                VStack(spacing: 0){
                                    VStack(spacing: 0) {
                                        Color.clear
                                        Color(uiColor: UIColor(hex: 0x88EDFF)).cornerRadius(8).background(RoundedRectangle(cornerRadius: 8).stroke(Color.black)).frame(height: 54 * 6 * (item.progress > 1.0 ? 1.0 : item.progress))
                                    }.padding(.vertical, 27).frame(height: 54 * 7)
                                    Text(item.unit).padding(.bottom, 27).frame(height: 38).font(.system(size: 10.0)).foregroundColor(.black)
                                }.frame(width: 30).padding(.leading, 1)
                            }
                        }
                    }
                }.frame(height: 54 * 7 + 38)
            }
            .padding(.leading, 20)
        }
    }
}

#Preview {
    ChartsView(store: Store(initialState: Charts.State(), reducer: {
        Charts()
    }))
}
