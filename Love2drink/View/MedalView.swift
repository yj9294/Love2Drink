//
//  MedalView.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct Medal {
    @ObservableState
    struct State: Equatable {}
    enum Action: Equatable {}
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            return .none
        }
    }
}

struct MedalView: View {
    let store: StoreOf<Medal>
    var body: some View {
        VStack{
            _NavigationBar(store: store)
            ScrollView(showsIndicators: false){
                VStack{
                    _ContinuousView()
                    _AchievementView()
                    Spacer()
                }
            }
        }.background
    }
    
    struct _NavigationBar: View {
        let store: StoreOf<Medal>
        var body: some View {
            ZStack{
                Image("medal_title")
            }.frame(height: 44)
        }
    }
    
    struct _ContinuousView: View {
        var body: some View {
            VStack{
                HStack{
                    Text("Continuously drinking water").background(Image("medal_type")).font(.system(size: 16))
                    Spacer()
                }.padding(.leading, 14)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 18),GridItem(.flexible(), spacing: 8),GridItem(.flexible(), spacing: 18)], spacing: 16, content: {
                    ForEach(ContinuousItem.allCases, id: \.self) { item in
                        Image(item.icon)
                    }
                })
            }.padding(.all, 14)
        }
    }
    
    struct _AchievementView: View {
        var body: some View {
            VStack{
                HStack{
                    Text("Drinking Water Achievement").background(Image("medal_type")).font(.system(size: 16))
                    Spacer()
                }.padding(.leading, 14)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 18),GridItem(.flexible(), spacing: 8),GridItem(.flexible(), spacing: 18)], spacing: 16, content: {
                    ForEach(AchievementItem.allCases, id: \.self) { item in
                        Image(item.icon)
                    }
                })
            }.padding(.all, 14)
        }
    }
}

#Preview {
    MedalView(store: Store(initialState: Medal.State(), reducer: {
        Medal()
    }))
}
