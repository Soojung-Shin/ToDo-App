//
//  ToDo.swift
//  ToDo
//
//  Created by Soojung Shin on 2020/01/12.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import Foundation

struct ToDo: Codable {
    var list: [ToDoInfo]
        
    struct ToDoInfo: Codable {
        var identifier: Int
        var title: String
        var modifiedDate: Date
        var complete: Bool
        
        //ToDo의 유일한 identifier를 만들기 위한 static 변수와 메소드.
        static var identifierFactory: Int = 0
        private static func getUniqueIdentifier() -> Int {
            identifierFactory += 1
            return identifierFactory
        }
        
        init(title: String) {
            identifier = ToDoInfo.getUniqueIdentifier()
            self.title = title
            modifiedDate = Date()
            complete = false
        }
    }
    
    init() {
        self.list = []
    }
    
    //JSON 데이터를 해당 모델로 디코딩한다.
    init?(json: Data) {
        do {
            self = try JSONDecoder().decode(ToDo.self, from: json)
            setLastIdentifier()
        } catch let error {
            print(error)
            return nil
        }
    }
    
    //해당 모델의 데이터를 JSON으로 인코딩한다.
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    //list의 마지막 identifier를 계산하여 ToDoInfo의 identifierFactory에 설정한다.
    func setLastIdentifier() {
        var max = 0
        list.forEach {
            if $0.identifier > max { max = $0.identifier }
        }
        ToDoInfo.identifierFactory = max
    }
}
