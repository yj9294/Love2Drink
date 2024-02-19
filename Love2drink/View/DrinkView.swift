//
//  DrinkView.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import ComposableArchitecture
import SwiftUI
import GADUtil
import Combine


@Reducer
struct Drink{
    @ObservableState
    struct State: Equatable {
        
        var ad: GADNativeViewModel = .none
        
        var drinks: [DrinkModel] = CacheUtil.getDrinks(){
            didSet{
                CacheUtil.setDrinks(drinks)
            }
        }
        
        var goal: Int = CacheUtil.getGoal() {
            didSet {
                CacheUtil.setGoal(goal)
            }
        }
        
        var rotationAngle: Double = 0.0
        mutating func updateAngle(_ angle: Double) {
            rotationAngle = angle
        }
        
        var getTodayProgress: Double {
            let today = drinks.filter({$0.date.isToday}).map({$0.ml}).reduce(0, +)
            return Double(today) / Double(goal)
        }
        
        @Presents var dailyGoal: DailyGoal.State?
        mutating func presentGoalState() {
            dailyGoal = .init()
        }
        
        @Presents var record: Record.State?
        mutating func presentRecordView() {
            record = .init()
        }
    }
    enum Action: Equatable {
        
        case startRotation
        case rotationUpdate
        case stopRotation
        
        case presentGoalView
        case presentRecordView
        
        case showInterAD
        
        case dailyGoal(PresentationAction<DailyGoal.Action>)
        case record(PresentationAction<Record.Action>)
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case timer }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            if case .startRotation = action {
                state.updateAngle(0)
                return .run { send in
                    for await _ in  clock.timer(interval: .milliseconds(10)) {
                        await send(.rotationUpdate)
                    }
                }.cancellable(id: CancelID.timer)
            }
            if case .rotationUpdate = action {
                let angle = state.rotationAngle + 1
                state.updateAngle(angle)
            }
            if case .stopRotation = action {
                return .cancel(id: CancelID.timer)
            }
            
            if case .presentGoalView = action {
                state.presentGoalState()
            }
            if case .presentRecordView = action {
                state.presentRecordView()
            }
            if case .showInterAD = action {
                let pulbisher = Future<Action, Never> { promise in
                    GADUtil.share.load(.interstitial)
                    GADUtil.share.show(.interstitial) { _ in
                        promise(.success(.presentGoalView))
                    }
                }
                return .publisher {
                    pulbisher
                }
            }
            return .none
        }.ifLet(\.$dailyGoal, action: \.dailyGoal) {
            DailyGoal()
        }.ifLet(\.$record, action: \.record) {
            Record()
        }
    }
}

struct DrinkView: View {
    @ComposableArchitecture.Bindable var store: StoreOf<Drink>
    
    var body: some View {
        WithPerceptionTracking {
            VStack{
                Image("drink_title").frame(height: 44)
                _ContentView(store: store).padding(.top, 30)
                Spacer()
                HStack{
                    WithPerceptionTracking {
                        GADNativeView(model: store.ad)
                    }
                }.padding(.horizontal, 20).frame(height: 116)
            }.background.onAppear(perform: {
                store.send(.startRotation)
                GADUtil.share.disappear(.native)
                GADUtil.share.load(.native)
            }).onDisappear(perform: {
                store.send(.stopRotation)
            }).fullScreenCover(item: $store.scope(state: \.dailyGoal, action: \.dailyGoal)) { store in
                DailyGoalView(store: store)
            }.fullScreenCover(item: $store.scope(state: \.record, action: \.record)) { store in
                RecordView(store: store)
            }
        }
    }
    
    struct _ContentView: View {
        let store: StoreOf<Drink>
        var body: some View {
            HStack{
                _ProgressView(store: store)
                Spacer()
                _ButtonView(store: store).padding(.trailing, 20)
            }
        }
    }
    
    struct _ProgressView: View {
        let store: StoreOf<Drink>
        var body: some View {
            ZStack(alignment: .center){
                WithPerceptionTracking {
                    Image("drink_progress_1").rotationEffect(.degrees(store.rotationAngle))
                    Image("drink_progress")
                    Text("\(Int(store.getTodayProgress * 100))%").font(.system(size: 34)).foregroundStyle(.black).padding(.leading, 80)

                }
            }.padding(.leading,  -180)
        }
    }
    
    struct _ButtonView: View {
        let store: StoreOf<Drink>
        var body: some View {
            VStack(spacing: 36){
                Button(action: { store.send(.showInterAD) }, label: {
                    ZStack(alignment: .bottom){
                        Image("drink_goal")
                        HStack{
                            WithPerceptionTracking {
                                Text("\(store.goal)ml")
                            }
                            Image("drink_edit")
                        }.padding(.bottom, 10)
                    }
                })
                Button(action: { store.send(.presentRecordView)}, label: {
                    ZStack(alignment: .bottom) {
                        Image("drink_add")
                        Text("Add Record").padding(.bottom, 10)
                    }
                })
            }.font(.system(size: 14)).foregroundStyle(.black)
        }
    }
}

#Preview {
    DrinkView(store: Store(initialState: Drink.State(), reducer: {
        Drink()
    }))
}
