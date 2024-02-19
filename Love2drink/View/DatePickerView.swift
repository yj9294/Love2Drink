//
//  DatePickerView.swift
//  Love2drink
//
//  Created by Super on 2024/2/8.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct DatePickerReducer: Reducer {
    @ObservableState
    struct State: Equatable {}
    enum Action: Equatable {
        case dateSaveButtonTapped(String)
        case cancelButtonTapped
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            return .none
        }
    }
}

struct DatePickerView: UIViewRepresentable {
    let store: StoreOf<DatePickerReducer>
    func makeUIView(context: Context) -> some UIView {
        if let view = Bundle.main.loadNibNamed("DatePickerView", owner: nil)?.first as? DateView {
            view.delegate = context.coordinator
           return view
        }
        let dateView = DateView()
        dateView.delegate = context.coordinator
        return dateView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DateViewDelegate {
        init(_ preview: DatePickerView) {
            self.parent = preview
        }
        let parent: DatePickerView
        
        func completion(time: String) {
            parent.store.send(.dateSaveButtonTapped(time))
        }
        
        func cancel() {
            parent.store.send(.cancelButtonTapped)
        }
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

protocol DateViewDelegate : NSObjectProtocol {
    func completion(time: String)
    func cancel()
}

class DateView: UIView {

    weak var delegate: DateViewDelegate?
    var selectedHours = 0
    var selectedMine = 0
    var hours:[Int] = Array(0..<24)
    var minu: [Int] = Array(0..<60)
    @IBOutlet weak var hourView: UIPickerView!
    @IBOutlet weak var minuView: UIPickerView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func saveAction() {
        let str = String(format: "%02d:%02d", selectedHours, selectedMine)
        delegate?.completion(time: str)
    }
    
    @IBAction func cancelAction() {
        delegate?.cancel()
    }
}

extension DateView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == hourView {
            return hours.count
        }
        return minu.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 56.0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let view = view as? UIButton{
            view.isSelected = pickerView == hourView ? selectedHours == row : selectedMine == row
            view.titleLabel?.font = UIFont.systemFont(ofSize: 26)
            let str = String(format: "%02d", pickerView == hourView ? hours[row] : minu[row])
            view.setTitle(str, for: .normal)
            return view
        }
        let view = UIButton()
        view.isSelected = pickerView == hourView ? selectedHours == row : selectedMine == row
        view.setTitleColor(UIColor.black, for: .selected)
        view.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 26)
        let str = String(format: "%02d", pickerView == hourView ? hours[row] : minu[row])
        view.setTitle(str, for: .normal)
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == hourView {
            selectedHours = row
        } else {
            selectedMine = row
        }
        pickerView.reloadComponent(0)
    }
}
