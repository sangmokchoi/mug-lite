//
//  APIManager.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/15.
//

import Foundation

struct UserData { // 유저가 등록한 키워드, 스크랩한 기사의 주소 등을 저장하는 구조체. 서버와 연동 시 해당 서버에 내용을 불러와야 함
    var userInputKeyword : [String] = []
    var scarpedList : [String : String] = [:] // 유저가 스크랩한 기사들
    // 필요정보: 기사제목, 발행일자, 신문사
}
