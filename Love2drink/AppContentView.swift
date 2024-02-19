//
//  ContentView.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import SwiftUI
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
                state.updateLoading(false)
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
        })
    }
}

#Preview {
    AppContentView(store: Store(initialState: AppContent.State(), reducer: {
        AppContent()
    }))
}
