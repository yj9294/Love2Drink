//
//  DetailView.swift
//  Love2drink
//
//  Created by Super on 2024/2/8.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct Detail {
    @ObservableState
    struct State: Equatable {
        let item: TipItem
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

struct DetailView: View {
    let store: StoreOf<Detail>
    var body: some View {
        VStack{
            _NavigationBar(store: store)
            WithPerceptionTracking {
                _ContentView(item: store.item)
            }
            Spacer()
        }.background
    }
    
    struct _NavigationBar: View {
        let store: StoreOf<Detail>
        var body: some View {
            ZStack{
                Image("detail_title")
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
        let item: TipItem
        var body: some View {
            ScrollView{
                VStack(alignment: .leading, spacing: 16){
                    Text(item.title).font(.system(size: 20))
                    Text(item.description).font(.system(size: 14))
                }.foregroundColor(.black).lineLimit(nil).padding(.all, 20)
            }
        }
    }
}

#Preview {
    DetailView(store: Store.init(initialState: Detail.State(item: .tip1), reducer: {
        Detail()
    }))
}
