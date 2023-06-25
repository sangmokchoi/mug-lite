//
//  APIData.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/16.
//

import Foundation

struct APIData {
    //MARK: - webSearch
    struct webSearch {
        var query : String
        var id : String // https://api.bing.microsoft.com/api/v7/#WebPages.7",
        var name : String// "유재석 미담 모음 2",
        var webSearchUrl: String //"https://sarogoo.tistory.com/entry/%EC%9C%A0%EC%9E%AC%EC%84%9D-%EB%AF%B8%EB%8B%B4-%EB%AA%A8%EC%9D%8C-2",
        var isFamilyFriendly: Bool
        var displayUrl : String //"https://sarogoo.tistory.com/entry/<b>유재석</b>-<b>미담</b>-모음-2",
        var snippet : String //"<b>유재석 미담</b> 모음 2 <b>유재석 미담</b> 모음 두 번째입니다. 오늘 알아볼 내용은 &#39;<b>유재석 미담</b>&#39;에 대해서입니다. 미담을 까도 까도 계속 나오는 유재석입니다. 오늘은 어떤 이야기를 가져왔을지 궁금하지 않으신가요? ㅎㅎ 아래를 참고해주세요!! 목차 첫 번째 - 백진희 배우 백진희가 유재석에게 특별히 ...",
        var varlanguage : String // "ko",
        var isNavigational : Bool

    }
    //MARK: - webNewsSearch
    struct webNewsSearch {
        var query : String = ""
        var name : String = "" //<b>유재석</b>, 재입대 위기 &quot;훈련소서 뵙겠다&quot; (플레이유 레벨업)",
        var webSearchUrl : String = "" // 10개
        let image : Thumbnail
        var description : String = "" // 10개
        let provider : Publisher // 원래 api 콜을 하면, Provider 구조체와 같은 데이터를 반환하지만, 퍼블리셔의 썸네일은 잘 쓰이지 않고, ReadingVC에서 썸네일을 효과적으로 불러오기 위해 Publisher 구조체로 통합시킴
        var datePublished : String = "" // "2023-05-16T05:14:33.0000000Z" 10개
        
    }
    
    struct Thumbnail {
        var contentUrl : String = "" //https://www.bing.com/th?id=OVFT.PTQsorAJFv1hQr4IzgedQi&pid=News",
        var width : Int = 0 //550
        var height : Int = 0  //306
    }
    
    struct Provider {
        var _type : String = ""  // Organization",
        var name : String = "" // "엑스포츠뉴스 on MSN.com",
        let image : Thumbnail
    }
    
     //MARK: - webImageSearch
    struct webImageSearch {
        
    }
    
    //MARK: - webVideoSearch
    struct webVideoSearch {
        var query : String = ""
        var name : String = ""
        var webSearchUrl : String = ""
        var description : String = "" // "#유재석 #명언 #자기계발 #유재석명언",
        var thumbnailUrl : String = "" // "https://tse3.mm.bing.net/th?id=OVF.AQiRxIi8%2fjQKCta8ZTfHnA&pid=Api",
        var datePublished : String = "" //2023-05-14T21:30:03.0000000",
        var publisher : Publisher
        var creator : Creator
        var isAccessibleForFree : Bool = true // true,
        var isFamilyFriendly : Bool = true // true,
        var contentUrl : String = ""//"https://www.youtube.com/watch?v=luWcH8HYzgY",
        var hostPageUrl : String = ""//"https://www.youtube.com/watch?v=luWcH8HYzgY",
        var encodingFormat : String = ""// 대부분 "" 이지만, h264의 형태도 있음
        var hostPageDisplayUrl : String = "" // "https://www.youtube.com/watch?v=luWcH8HYzgY",
        var width : Int = 0 // 1080,
        var height : Int = 0 // 1920,
        var duration : String = "" // "PT46S",
        var embedHtml : String = "" // "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/luWcH8HYzgY?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;",
        var allowHttpsEmbed : Bool = true // true,
        var viewCount : Int = 0 // 702
        var thumbnail : Thumbnail
        var videoId : String = ""// "73B2FF7031113A1A66B473B2FF7031113A1A66B4",
        var allowMobileEmbed : Bool = true// true,
        var isSuperfresh : Bool = true // true
    }
    
    struct Publisher {
        var name : String = ""
    }
    
    struct Creator {
        var name : String = ""
    }
    //MARK: - 북마크 저장 시의 구조체
    
    struct Bookmarked : Equatable {
        var query : String = ""
        var url : String = ""
        var name : String = ""
        var datePublished : String = ""
        var distributor : String = ""
    }

}
