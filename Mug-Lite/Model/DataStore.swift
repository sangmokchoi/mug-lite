//
//  DataStore.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/23.
//

import Foundation

class DataStore {
    static let shared = DataStore() // 싱글톤 인스턴스

    var loadedNewsSearchArray : [[APIData.webNewsSearch]] = []
    var loadedVideoSearchArray : [[APIData.webVideoSearch]] = []

    private init() {} // 다른 인스턴스 생성 방지
}
