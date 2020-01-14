//
//  AddToDoTableViewCell.swift
//  ToDo
//
//  Created by Soojung Shin on 2020/01/12.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

class AddToDoTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
            textField.clearsOnBeginEditing = true
        }
    }
    
    //테이블 뷰에게 메세지를 받아오기 위해 사용할 클로저 변수.
    var reginationHandler: (() -> Void)?
    
    //textField의 Editing이 끝나면 호출되는 메소드.
    func textFieldDidEndEditing(_ textField: UITextField) {
        //테이블 뷰에서 받아온 클로저를 실행한다.
        reginationHandler?()
    }
    
    //키보드의 리턴 키를 누르면 호출되는 메소드.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField의 firstResponder 상태를 반환한다.
        textField.resignFirstResponder()
        return true
    }
}
