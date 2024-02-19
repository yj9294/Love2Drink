//
//  GoalView.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import Foundation
import SwiftUI
import GADUtil
import ComposableArchitecture

@Reducer
struct DailyGoal {
    @ObservableState
    struct State: Equatable {
        var progress = Double(CacheUtil.getGoal()) / 4000.0 {
            didSet {
                let goal = Int(progress * 40.0) * 100
                if goal <= 0 {
                    updateGoal(100)
                    return
                }
                updateGoal(goal)
            }
        }
        var goal: Int = CacheUtil.getGoal()
        
        mutating func updateGoal(_ goal: Int) {
            self.goal = goal
        }
        
        mutating func updateProgress(_ progress: Double) {
            self.progress = progress
        }
    }
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case dismissButtonTapped
        case updateGoal(Int)
        case addButtonTapped
        case subsButtonTapped
        case saveButtonTapped
        
        //
        case updatedGoal
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce{ state, action in
            if case .dismissButtonTapped = action {
                GADUtil.share.disappear(.native)
                GADUtil.share.load(.native)
                return .run { _ in
                  await self.dismiss()
                }
            }
            
            if case let .updateGoal(goal) = action {
                state.updateGoal(goal)
            }
            
            if case .addButtonTapped = action {
                let goal = state.goal + 100
                if goal > 4000 {
                    state.updateGoal(4000)
                    state.updateProgress(1.0)
                    return .none
                }
                state.updateGoal(goal)
                let progress = Double(goal) / 4000.0
                state.updateProgress(progress)
            }
            
            if case .subsButtonTapped = action {
                let goal = state.goal - 100
                if goal < 100 {
                    state.updateGoal(100)
                    state.updateProgress(100.0 / 4000.0)
                    return .none
                }
                state.updateGoal(goal)
                let progress = Double(goal) / 4000.0
                state.updateProgress(progress)
            }
            
            if case .saveButtonTapped = action {
                CacheUtil.setGoal(state.goal)
                return .run { send in
                    await send(.updatedGoal)
                    await self.dismiss()
                }
            }
            return .none
        }
    }
}

struct DailyGoalView: View {
    @ComposableArchitecture.Bindable var store: StoreOf<DailyGoal>
    var body: some View {
        VStack(spacing: 0){
            _NavigationBar(store: store)
            _ContentView(store: store).padding(.top, 37)
            Spacer()
        }.background
    }
    
    struct _NavigationBar: View {
        let store: StoreOf<DailyGoal>
        var body: some View {
            ZStack{
                Image("goal_title")
                Button(action: {store.send(.dismissButtonTapped)}, label: {
                    HStack{
                        Image("back").padding(.leading, 16)
                        Spacer()
                    }
                })
            }.frame(height: 44)
        }
    }
    
    struct _ContentView: View {
        @ComposableArchitecture.Bindable var store: StoreOf<DailyGoal>
        var body: some View {
            ZStack(alignment: .center){
                HStack{
                    Spacer()
                    Image("goal_bg")
                    Spacer()
                }.padding(.horizontal, 20)
                HStack{
                    Spacer()
                    Text("Hello, please enter your goal here").font(.system(size: 13))
                    Spacer()
                }.foregroundStyle(.white).padding(.top, -78)
                WithPerceptionTracking {
                    Text("\(store.goal)ml").font(.system(size: 36)).padding(.vertical, 27).padding(.horizontal, 54).background(.white).cornerRadius(16)
                }
                HStack{
                    Button(action: {store.send(.subsButtonTapped)}, label: {
                        Image("goal_-")
                    })
                    WithPerceptionTracking {
                        Slider(value: $store.progress).tint(Color(uiColor: UIColor(hex: 0xDCFF3A))).onAppear {
                            let thumbImage = UIImage(named: "goal_point")
                            UISlider.appearance().setThumbImage(thumbImage, for: .normal)
                            UISlider.appearance().maximumTrackTintColor = .white
                        }
                    }
                    Button(action: {store.send(.addButtonTapped)}, label: {
                        Image("goal_+")
                    })
                }.padding(.horizontal, 70).padding(.top, 150)
                
                Button(action: {store.send(.saveButtonTapped)}, label: {
                    Text("Save").background(Image("goal_button")).foregroundStyle(.black)
                }).padding(.top, 300)
            }
        }
    }
}


#Preview {
    DailyGoalView(store: Store(initialState: DailyGoal.State(), reducer: {
        DailyGoal()
    }))
}
