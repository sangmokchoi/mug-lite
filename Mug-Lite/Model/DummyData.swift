//
//  DummyData.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/22.
//

import Foundation

class DummyData {
    var progress : String
    var keyword : String
    var title : String
    var image : String
    var content : String
    var url : String
    
    init(progress: String, keyword: String, title: String, image: String, content: String, url: String) {
        self.progress = progress
        self.keyword = keyword
        self.title = title
        self.image = image
        self.content = content
        self.url = url
    }
    
    static var dummyList = [DummyData(progress: "Progress", keyword: "Keyword", title: "Title", image: "Image", content: "Content", url: "URL")]
}
