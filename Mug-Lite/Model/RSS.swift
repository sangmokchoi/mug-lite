//
//  File.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/08.
//

import Foundation

protocol RSSDelegate {
    
}

struct RSS {
    
    let URLbody = "news.google.com/rss"
    var delegate : RSSDelegate?
    
    func trendNews(hl: String, gl: String, ceid: String) {
        let homePage = "\(URLbody)?hl=\(hl)&gl=\(gl)&ceid=\(ceid)"
    }
    
    func pickTopic(topic: String) {
        let topic = "\(URLbody)/topics/\(topic)"
    }
    
    func search(searchWord: String, hl: String, gl: String, ceid: String) {
        // hl는 검색 결과의 인터페이스 언어
        // gl은 검색 결과의 지역 설정
        // "ceid=KR%3Ako"는 검색 결과의 컨텐츠 발행 국가를 대한민국(KR)으로, 언어를 한국어(ko)로 설정한 것을 나타냅니다. 이렇게 설정된 검색 결과는 대한민국에서 발행된 한국어 뉴스 기사를 우선적으로 보여주게 됩니다.
        let keyword = "\(URLbody)/search?q=\(searchWord)&hl=\(hl)&gl=\(gl)&ceid=\(ceid)"
    }
    
    func detailSearch(searchWord: String) {
        let detail = "\(URLbody)/search?q=\(searchWord)%20site%3A(사이트 주소)%20%20-(제외할 단어)&hl=ko&gl=KR&ceid=KR%3Ako"
    }

    
    //- 구글 뉴스 링크 예시 https://news.google.com/home?hl=ko&gl=KR&ceid=KR:ko (한국)
    // - 구글 뉴스 링크 예시: https://news.google.com/home?hl=en-US&gl=US&ceid=US:en (영어, 미국)
    
//    <title>"서로 모른다더니"…이재명-김성태 '대리 조문' - 연합뉴스TV</title>
//    <link>https://news.google.com/rss/articles/CBMiOGh0dHBzOi8vd3d3LnlvbmhhcG5ld3N0di5jby5rci9uZXdzL01ZSDIwMjMwMjAxMDA2NzAwNjQx0gEA?oc=5</link>
//    <guid isPermaLink="false">CBMiOGh0dHBzOi8vd3d3LnlvbmhhcG5ld3N0di5jby5rci9uZXdzL01ZSDIwMjMwMjAxMDA2NzAwNjQx0gEA</guid>
//    <pubDate>Wed, 01 Feb 2023 08:00:00 GMT</pubDate>
//    <description><a href="https://news.google.com/rss/articles/CBMiOGh0dHBzOi8vd3d3LnlvbmhhcG5ld3N0di5jby5rci9uZXdzL01ZSDIwMjMwMjAxMDA2NzAwNjQx0gEA?oc=5" target="_blank">"서로 모른다더니"…이재명-김성태 '대리 조문'</a>&nbsp;&nbsp;<font color="#6f6f6f">연합뉴스TV</font></description>
//    <source url="https://www.yonhapnewstv.co.kr">연합뉴스TV</source>
    
}
