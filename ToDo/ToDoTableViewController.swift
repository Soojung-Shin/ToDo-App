//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by Soojung Shin on 2020/01/12.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

class ToDoTableViewController: UITableViewController {
    
    // MARK: - Model
    
    private lazy var userToDoData: ToDo = getToDoList()
    
    //완료된 ToDo 리스트를 가져오기 위한 연산 프로퍼티. 수정된 날짜를 기준으로 내림차순 정렬되어 있다.
    private var completeToDoList: [ToDo.ToDoInfo] {
        get {
            return userToDoData.list.filter { $0.complete }.sorted(by: {$0.modifiedDate > $1.modifiedDate})
        }
    }
    
    //미완료된 ToDo 리스트를 가져오기 위한 연산 프로퍼티. 수정된 날짜를 기준으로 내림차순 정렬되어 있다.
    private var incompleteToDoList: [ToDo.ToDoInfo] {
        get {
            return userToDoData.list.filter { return !$0.complete }.sorted(by: {$0.modifiedDate > $1.modifiedDate})
        }
    }
    
    // MARK: - Add ToDo Action
    
    //현재 ToDo를 추가중인지 나타내는 프로퍼티. 텍스트 필드가 나타나있는 상태라면 true, 아니면 false.
    private var isAdding = false

    //오른쪽 상단의 add 버튼을 누르면 호출되는 액션 메소드. 첫 번째 셀에 ToDo를 추가할 수 있는 텍스트 필드가 나타난다.
    @IBAction func addToDo(_ sender: UIBarButtonItem) {
        isAdding = true
        tableView.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.top)
    }
    
    // MARK: - Complete ToDo Action
    
    //해당 셀의 complete 버튼을 누르면 호출되는 액션 메소드. 해당 ToDo의 완료/미완료 상태를 변경한다.
    @IBAction func tabCompleteButton(_ sender: UIButton) {
        //버튼의 tag 속성에 ToDo 구조체의 identifier 값을 넣었다. sender의 tag 값으로 눌러진 버튼의 index를 구한다.
        print(sender.tag)
        if let index = userToDoData.list.firstIndex(where: { $0.identifier == sender.tag }) {
            userToDoData.list[index].complete = !userToDoData.list[index].complete
            userToDoData.list[index].modifiedDate = Date()
            save()
        }
        tableView.reloadData()
    }
    
    // MARK: - Save/get data
    
    //모델의 json 파일의 URL. 샌드박스의 ApplicationSupportDirectory 안 ToDoList.json 파일 URL이다.
    let url: URL? = try? FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    ).appendingPathComponent("ToDoList.json")
    
    //모델의 json 파일을 저장한다.
    private func save() {
        if let json = userToDoData.json {
            print("save")
            try? json.write(to: url!)
        }
    }
    
    //저장되어있는 json 파일을 가져온다.
    private func getToDoList() -> ToDo {
        if let data = try? Data(contentsOf: url!), let todoList = ToDo(json: data) {
            return todoList
        }
        return ToDo()
    }
    
    // MARK: - Table view data source

    //테이블 뷰의 섹션 개수를 설정하는 메소드.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    //섹션에 따른 행의 개수를 설정하는 메소드.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isAdding ? 1 : 0
        case 1:
            return incompleteToDoList.count
        case 2:
            return completeToDoList.count
        default:
            return 0
        }
    }

    //각 행에 맞는 데이터를 설정하는 메소드. IndexPath의 section, row를 이용한다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && isAdding {
            //현재 ToDo를 추가중이라면 섹션 0에 텍스트 필드가 나타난다.
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.AddCell, for: indexPath)
            if let textFieldCell = cell as? AddToDoTableViewCell {
                textFieldCell.textField.becomeFirstResponder()
                //textFieldCell에 핸들러를 설정해 뷰 컨트롤러로 메세지를 보낼 수 있게 한다. 키보드의 리턴 버튼이 눌리면 실행될 메소드이다.
                textFieldCell.reginationHandler = { [weak self, unowned textFieldCell] in
                    //textField가 비어있지 않다면 해당 텍스트를 ToDo 모델에 추가한다.
                    if let text = textFieldCell.textField.text, !text.isEmpty {
                        self?.userToDoData.list.append(ToDo.ToDoInfo(title: text))
                        self?.save()
                    }
                    self?.isAdding = false
                    self?.tableView.reloadData()
                }
            }
            return cell
        } else if indexPath.section == 1 {
            //섹션 1에는 미완료 상태인 ToDo 리스트를 불러온다.
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ToDoCell, for: indexPath)
            if let contentCell = cell as? ToDoTableViewCell {
                let content = incompleteToDoList[indexPath.row]
                contentCell.checkButton.tag = content.identifier
                contentCell.titleLabel.text = content.title
                contentCell.checkButton.setImage(ButtonImage.incomplete, for: .normal)
                contentCell.backgroundColor = CellBackgroundColor.incompleteCell
            }
            return cell
        } else if indexPath.section == 2 {
            //섹션 2에는 완료 상태인 ToDo 리스트를 불러온다.
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ToDoCell, for: indexPath)
            if let contentCell = cell as? ToDoTableViewCell {
                let content = completeToDoList[indexPath.row]
                contentCell.checkButton.tag = content.identifier
                contentCell.titleLabel.text = content.title
                contentCell.checkButton.setImage(ButtonImage.complete, for: .normal)
                contentCell.backgroundColor = CellBackgroundColor.completeCell
            }
            return cell
        }
        return UITableViewCell()
    }
    
    //테이블 뷰의 행 높이를 설정하기 위한 메소드.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewCellSize.height
    }

    //테이블 뷰의 행을 수정하기 위해 설정한 메소드.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //행을 왼쪽으로 슬라이드하면 삭제 버튼이 나타난다.
        if editingStyle == .delete {
            userToDoData.list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Constants

extension ToDoTableViewController {
    enum TableViewCellSize {
        static let height: CGFloat = 60.0
    }

    enum ButtonImage {
        static let complete: UIImage = UIImage(systemName: "checkmark.circle")!
        static let incomplete: UIImage = UIImage(systemName: "circle")!
    }

    enum CellIdentifier {
        static let AddCell = "AddToDo"
        static let ToDoCell = "ToDoCell"
    }
    
    enum CellBackgroundColor {
        static let completeCell: UIColor = .systemGray5
        static let incompleteCell: UIColor = .white
    }
}
