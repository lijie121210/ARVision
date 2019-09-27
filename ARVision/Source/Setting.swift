//
//  AnchorNodeStylePicker.swift
//  ARVision
//
//  Created by viwii on 2019/9/27.
//  Copyright © 2019 com.viwii. All rights reserved.
//

import UIKit

extension Setting {
    
    static let newValueKey = "AnchorNodeStylePicker.newValue"
    
    static let styleValueDidChange = Notification.Name(rawValue: "AnchorNodeStylePicker.style.valueDidChange")
    
    static let joinedValueDidChange = Notification.Name(rawValue: "AnchorNodeStylePicker.joinAllSentences.valueDidChange")
    
}

class AnchorNodeStylePickerDataSource: NSObject, UIPickerViewDataSource {
    
    private let styles = [
        "Only Source",
        "Only Target",
        "Splice",
        "Combine",
        "Mirror"
    ]
    
    subscript(_ index: Int) -> String {
        styles[index]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        styles.count
    }
}

class Setting: UIViewController, UIPickerViewDelegate {
    
    var defaultValue = 0
    
    @IBOutlet weak var picker: UIPickerView! {
        didSet {
            picker.dataSource = dataSource
        }
    }
    
    @IBOutlet weak var joinSwitch: UISwitch!
    
    var dataSource = AnchorNodeStylePickerDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.selectRow(defaultValue, inComponent: 0, animated: false)
    }
    
    @IBAction func onDoneAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NotificationCenter.default
            .post(
                name: Setting.styleValueDidChange,
                object: nil,
                userInfo: [Setting.newValueKey:row]
            )
    }

    @IBAction func onJoinValueChangeAction(_ sender: UISwitch) {
        NotificationCenter.default
            .post(
                name: Setting.joinedValueDidChange,
                object: nil,
                userInfo: [Setting.newValueKey:sender.isOn]
            )
    }
    
}
