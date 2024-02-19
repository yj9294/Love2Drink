//
//  ContentView.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import SwiftUI
import GADUtil
import ComposableArchitecture

@Reducer
struct AppContent {
    @ObservableState
    struct State: Equatable {
        var loading: Loading.State = .init()
        var home: Home.State = .init()
        
        var isLoading = true
        mutating func updateLoading(_ isLoading: Bool) {
            self.isLoading = isLoading
            if self.isLoading {
                loading.progress = 0.0
                loading.duration = 12.5
            }
        }
    }
    enum Action: Equatable {

        case updateLoading(Bool)
        
        // child view to data
        case loading(Loading.Action)
        case home(Home.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            if case let .updateLoading(isLoading) = action {
                state.updateLoading(isLoading)
            }
            
            if case .loading(.launched) = action {
                if state.loading.progress >= 1.0 {
                    state.updateLoading(false)
                }
            }
            return .none
        }
        
        Scope(state: \.loading, action: \.loading) {
            Loading()
        }
        
        Scope(state: \.home, action: \.home) {
            Home()
        }
    }
}

struct AppContentView: View {
    let store: StoreOf<AppContent>
    var body: some View {
        VStack{
            WithPerceptionTracking {
                if store.isLoading {
                    LoadingView(store: store.scope(state: \.loading, action: \.loading))
                } else {
                    HomeView(store: store.scope(state: \.home, action: \.home))
                }
            }
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
            store.send(.updateLoading(true))
            store.send(.loading(.start))
            Task {
                await GADUtil.share.dismiss()
            }
        })
    }
}

#Preview {
    AppContentView(store: Store(initialState: AppContent.State(), reducer: {
        AppContent()
    }))
}
