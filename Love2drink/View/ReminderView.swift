//
//  ReminderView.swift
//  Love2drink
//
//  Created by Super on 2024/2/8.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import GADUtil

@Reducer
struct Reminder {
    @ObservableState
    struct State: Equatable {

        var ad: GADNativeViewModel = .none

        var weekMode: Bool = CacheUtil.getWeekMode()
        mutating func updateMode(_ mode: Bool) {
            weekMode = mode
            CacheUtil.setWeekMode(mode)
        }
        
        var reminders: [ReminderModel] = CacheUtil.getReminders()
        mutating func deleteReminder(_ reminder: ReminderModel) {
            reminders = reminders.filter({$0 != reminder})
            CacheUtil.setReminders(reminders)
            NotificationHelper.shared.deleteNotifications(reminder.title)
        }
        mutating func appendReminder(_ time: String) {
            let hour = Int(time.components(separatedBy: ":").first ?? "0") ?? 0
            let min = Int(time.components(separatedBy: ":").last ?? "0") ?? 0
            let reminder = ReminderModel(hour: hour, minute: min)
            reminders.append(reminder)
            reminders.sort { l1, l2 in
                l1.title < l2.title
            }
            CacheUtil.setReminders(reminders)
            NotificationHelper.shared.appendReminder(time)
        }
        
        var showTime = false
        mutating func updateShowDatePicker(_ isShow: Bool) {
            showTime = isShow
        }
        var datePicker: DatePickerReducer.State = .init()
    }
    enum Action: Equatable {
        case updateMode(Bool)
        case deleteReminder(ReminderModel)
        
        case dismissButtonTapped
        case datePicker(DatePickerReducer.Action)
        case updateShowDatePicker(Bool)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            if case .dismissButtonTapped = action {
                return .run { send in
                    await self.dismiss()
                }
            }
            
            if case let .updateMode(mode) = action {
                state.updateMode(mode)
            }
            
            if case let .deleteReminder(model) = action {
                state.deleteReminder(model)
            }
            
            if case let .updateShowDatePicker(isShow) = action {
                state.updateShowDatePicker(isShow)
            }
            if case let .datePicker(.dateSaveButtonTapped(time)) = action {
                state.appendReminder(time)
                state.updateShowDatePicker(false)
            }
            if case .datePicker(.cancelButtonTapped) = action {
                state.updateShowDatePicker(false)
            }
            return .none
        }
        Scope.init(state: \.datePicker, action: \.datePicker) {
            DatePickerReducer()
        }
    }
}

struct ReminderView: View {
    let store: StoreOf<Reminder>
    var body: some View {
        ZStack{
            VStack{
                _NavigationBar(store: store)
                _WeekView(store: store)
                ScrollView{
                    _ReminderListView(store: store)
                }
                Spacer()
                HStack{
                    WithPerceptionTracking {
                        GADNativeView(model: store.ad)
                    }
                }.padding(.horizontal, 20).frame(height: 116).padding(.bottom, 20)
            }.background.onAppear{
                GADUtil.share.disappear(.native)
                GADUtil.share.load(.native)
            }
            
            WithPerceptionTracking {
                if store.showTime {
                    _TimerView(store: store)
                }
            }
        }
    }
    
    struct _NavigationBar: View {
        let store: StoreOf<Reminder>
        var body: some View {
            ZStack{
                Image("reminder_title")
                HStack{
                    Button(action: {store.send(.dismissButtonTapped)}, label: {
                        Image("back").padding(.leading, 16)
                    })
                    Spacer()
                }
                HStack{
                    Spacer()
                    Button(action: {store.send(.updateShowDatePicker(true))}, label: {
                        Image("reminder_add").padding(.trailing, 16)
                    })
                }
            }
        }
    }
    
    struct _WeekView: View {
        let store: StoreOf<Reminder>
        var body: some View {
            VStack{
                HStack{
                    Text("Weekend Mode").foregroundStyle(Color.black)
                    Spacer()
                    Button(action: {store.send(.updateMode(!store.weekMode))}, label: {
                        WithPerceptionTracking {
                            store.weekMode ? Image("reminder_on") : Image("reminder_off")
                        }
                    })
                }.padding(.vertical, 20).padding(.horizontal, 16).background(Image("reminder_button").resizable()).padding(.all, 20)
                Text("After opening, you won't receive any messages on weekends").font(.system(size: 14.0)).foregroundStyle(Color.black).lineLimit(nil).padding(.horizontal, 20)
            }
        }
    }
    
    struct _ReminderListView: View {
        let store: StoreOf<Reminder>
        var body: some View {
            VStack(alignment: .leading){
                Image("reminder_list")
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 14, content: {
                    WithPerceptionTracking {
                        ForEach(store.reminders, id: \.self) { item in
                            _ReminderItem(item: item, action: {
                                store.send(.deleteReminder(item))
                            })
                        }
                    }
                })
            }.padding(.all, 20)
        }
    }
    
    struct _ReminderItem: View {
        let item: ReminderModel
        let action: ()->Void
        var body: some View {
            HStack{
                Text(item.title).font(.system(size: 20)).foregroundStyle(Color.black)
                Spacer()
                Button(action: action, label: {
                    Image("reminder_close")
                })
            }.padding(.all, 16).background(Image("reminder_item").resizable())
        }
    }
    
    struct _TimerView: View {
        let store: StoreOf<Reminder>
        var body: some View {
            ZStack{
                Color.black.opacity(0.3).ignoresSafeArea()
                VStack{
                    DatePickerView(store: store.scope(state: \.datePicker, action: \.datePicker)).frame(height: 288)
                }.background(Color.white).cornerRadius(12).padding(.horizontal, 24)
            }
        }
    }
}

#Preview {
    ReminderView(store: Store.init(initialState: Reminder.State(), reducer: {
        Reminder()
    }))
}
