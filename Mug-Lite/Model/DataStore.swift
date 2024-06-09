//
//  DataStore.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/23.
//

import Foundation

class DataStore {
    static let shared = DataStore() // 싱글톤 인스턴스
    
    var userInputKeyword : [String] = []
    var totalSearch : [[Any]] = []
    
    var bookmarkArray : [[APIData.Bookmarked]] = []
    
    var keywordSearchArray : [APIData.webNewsSearch] = []
    var loadedKeywordSearchArray : [[APIData.webNewsSearch]] = []
    
    var keywordNewsArray : [APIData.webNewsSearch] = []
    var loadedKeywordNewsArray : [[APIData.webNewsSearch]] = []
    
    var newsOffsetForTrendingNews = 0
    var newsOffsetForKeyword = 0
    var newsSearchArray : [APIData.webNewsSearch] = []
    var loadedNewsSearchArray : [[APIData.webNewsSearch]] = []
    
    var videoOffsetForTrendingNews = 0
    var videoOffsetForKeyword = 0
    var videoSearchArray : [APIData.webVideoSearch] = []
    var loadedVideoSearchArray : [[APIData.webVideoSearch]] = []
    
    func merge() {
        
        for newsArray in loadedKeywordNewsArray {
            //print("loadedNewsSearchArray: \(loadedNewsSearchArray.count)")
            totalSearch.append(newsArray)
        }
        
//        for newsArray in loadedKeywordNewsArray {
//            //print("loadedNewsSearchArray: \(loadedNewsSearchArray.count)")
//            totalSearch.append(newsArray)
//        }
        for videoArray in loadedVideoSearchArray {
            //print("loadedVideoSearchArray: \(loadedVideoSearchArray.count)")
            totalSearch.append(videoArray)
        }
        
        //totalSearch.shuffle()
        
        //print("totalSearch: \(totalSearch)")
        //print("totalSearch.count: \(totalSearch.count)")
    }
    

    private init() {} // 다른 인스턴스 생성 방지
}
