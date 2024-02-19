//
//  LoadingView.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import Foundation
import SwiftUI
import Combine
import GADUtil
import ComposableArchitecture


@Reducer
struct Loading {
    enum CancelID { case progress }
    @ObservableState
    struct State: Equatable {
        var progress = 0.0
        var duration = 3.0
        
        mutating func updateProgress(_ progress: Double) {
            self.progress = progress
        }
        
        mutating func updateDuration(_ duration: Double) {
            self.duration = duration
        }
    }
    enum Action: Equatable {
        case updateProgress(Double)
        case updateDuration(Double)
        case start
        case update
        case end
        case showLoadingAD
        
        // data to super view
        case launched
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            if case let .updateProgress(progress) = action {
                state.updateProgress(progress)
            }
            if case let .updateDuration(duration) = action {
                state.updateDuration(duration)
            }
            if case .start = action {
                state.updateDuration(13.0)
                state.updateProgress(0.0)
                GADUtil.share.load(.open)
                GADUtil.share.load(.native)
                GADUtil.share.load(.interstitial)
                let publisher = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().map { _ in
                    Action.update
                }
                return .publisher {
                    publisher
                }.cancellable(id: CancelID.progress)
            }
            if case .end = action {
                return .cancel(id: CancelID.progress)
            }
            if case .update = action {
                let progress = state.progress + 0.01 / state.duration
                if progress > 1.0 {
                    state.updateProgress(1.0)
                    return .run { send in
                        await send(.end)
                        await send(.showLoadingAD)
                    }
                } else {
                    state.updateProgress(progress)
                }
                
                if progress > 0.3, GADUtil.share.isLoaded(.open) {
                    state.updateDuration(1.0)
                }
            }
            if case .showLoadingAD = action {
                let publisher = Future<Action, Never> { promise in
                    GADUtil.share.show(.open) { _ in
                        promise(.success(.launched))
                    }
                }
                return .publisher {
                    publisher
                }
            }
            return .none
        }
    }
}

struct LoadingView: View {
    let store: StoreOf<Loading>
    var body: some View {
        VStack {
            VStack(spacing: 40){
                HStack{
                    Spacer()
                    Image("loading_icon")
                    Spacer()
                }
                Image("loading_title")
            }.padding(.top, 145)
            Spacer()
            VStack(spacing: 13){
                WithPerceptionTracking {
                    Text("loading…\(Int(store.progress * 100))%").foregroundStyle(Color(uiColor: UIColor(hex: 0x040404, alpha: 0.3))).font(.system(size: 14))
                    ProgressView(value: store.progress, total: 1.0).tint(Color(UIColor(hex: 0xCAEC2A))).background(Color(uiColor: UIColor(hex: 0x040404))).cornerRadius(2)
                }
            }.padding(.horizontal, 70).padding(.bottom, 60)
        }.background.onAppear{
            store.send(.start)
        }
    }
}

#Preview {
    LoadingView(store: Store(initialState: Loading.State(), reducer: {
        Loading()
    }))
}
