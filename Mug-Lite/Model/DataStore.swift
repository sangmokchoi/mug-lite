//
//  DataStore.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/23.
//

import Foundation

class DataStore {
    static let shared = DataStore() // 싱글톤 인스턴스
    
    var totalSearch_1 : [[Any]] = []
    var totalSearch_2 : [[Any]] = []
    var totalSearch_3 : [[Any]] = []
    var totalSearch_4 : [[Any]] = []
    var totalSearch_5 : [[Any]] = []
    var totalSearch_6 : [[Any]] = []
    var totalSearch_7 : [[Any]] = []
    var totalSearch_8 : [[Any]] = []
    var totalSearch_9 : [[Any]] = []
    var totalSearch_10 : [[Any]] = []
    
    var userInputKeyword : [String] = []
    var totalSearch : [[Any]] = []
    
    var bookmarkArray : [[APIData.Bookmarked]] = []
    
    var keywordNewsArray : [APIData.webNewsSearch] = []
    var loadedKeywordNewsArray : [[APIData.webNewsSearch]] = []
    
    var newsOffset = 0
    var newsSearchArray : [APIData.webNewsSearch] = []
    var loadedNewsSearchArray : [[APIData.webNewsSearch]] = [[Mug_Lite.APIData.webNewsSearch(query: "", name: "배우 이광수가 13일 오전 서울 종로 JW메리어트동대문스퀘어에서 열린 디즈니플러스 \'더 존: 버텨야 산다 시즌2\' (연출 조효진, 김동진) 제작발표회에 참석해 포토타임을 갖고 있다.\'더 존: 버텨야 산다 시즌2\'는 일상생활을 위협하는 상황 속 더 리얼하고 강력해진 극강의 8개 시뮬레이션에서 다시 뭉친 ‘수.유.리’ 유재석, 이광수, 권유리기 펼치는 상상 초", webSearchUrl: "https://www.hankyung.com/entertainment/article/202306135870H", image: Mug_Lite.APIData.Thumbnail(contentUrl: "https://www.bing.com/th?id=OVFT.jJV_bix1G3GwWzFvg5R6-C&pid=News.png", width: 467, height: 700), description: "배우 이광수가 13일 오전 서울 종로 JW메리어트동대문스퀘어에서 열린 디즈니플러스 \'더 존: 버텨야 산다 시즌2\' (연출 조효진, 김동진) 제작발표회에 참석해 포토타임을 갖고 있다.\'더 존: 버텨야 산다 시즌2\'는 일상생활을 위협하는 상황 속 더 리얼하고 강력해진 극강의 8개 시뮬레이션에서 다시 뭉친 ‘수.유.리’ 유재석, 이광수, 권유리기 펼치는 상상 초", provider: Mug_Lite.APIData.Publisher(name: "한경닷컴") , datePublished: "2023-06-13T02:48:00.0000000")], [Mug_Lite.APIData.webNewsSearch(query: "", name: "가수 권유리가 13일 오전 서울 종로 JW메리어트동대문스퀘어에서 열린 디즈니플러스 \'더 존: 버텨야 산다 시즌2\' (연출 조효진, 김동진) 제작발표회에 참석해 발걸음을 옮기고 있다.\'더 존: 버텨야 산다 시즌2\'는 일상생활을 위협하는 상황 속 더 리얼하고 강력해진 극강의 8개 시뮬레이션에서 다시 뭉친 ‘수.유.리’ 유재석, 이광수, 권유리기 펼치는 상상 초", webSearchUrl: "https://www.hankyung.com/entertainment/article/202306135869H", image:  Mug_Lite.APIData.Thumbnail(contentUrl: "https://www.bing.com/th?id=OVFT.JOwuCCQdv06msKjBUEERGi&pid=News.png", width: 686, height: 429), description: "가수 권유리가 13일 오전 서울 종로 JW메리어트동대문스퀘어에서 열린 디즈니플러스 \'더 존: 버텨야 산다 시즌2\' (연출 조효진, 김동진) 제작발표회에 참석해 발걸음을 옮기고 있다.\'더 존: 버텨야 산다 시즌2\'는 일상생활을 위협하는 상황 속 더 리얼하고 강력해진 극강의 8개 시뮬레이션에서 다시 뭉친 ‘수.유.리’ 유재석, 이광수, 권유리기 펼치는 상상 초", provider: Mug_Lite.APIData.Publisher(name: "한경닷컴") , datePublished: "2023-06-13T03:00:00.0000000")], [Mug_Lite.APIData.webNewsSearch(query: "", name: "유재석, 아들의 예능 DNA 자랑 “조세호 전화 받고 ‘여보세호’”", webSearchUrl: "http://www.atstar1.com/news/articleView.html?idxno=6001668", image:  Mug_Lite.APIData.Thumbnail(contentUrl: "https://www.bing.com/th?id=OVFT.HT_lVT4ALudDQPoo8Oyxmy&pid=News.png", width: 300, height: 168), description: "[앳스타일 김예나 기자] 개그맨 유재석이 아들 지호 군의 전화 에피소드를 공개했다.유재석은 지난 11일 유튜브 채널 핑계로에 업로드된 영상에서 이동욱, 조세호, 남창희와 수다를 나눴다. 유재석은 올해 중학교 1학년의 아들 지호 군을 언급하며 “지호가 세호 삼촌 되게 좋아한다”고 말했다.그러자 남창희는 지호와 세호의 연관성을 잡아 “‘호’자 돌림이네. 이름에", provider: Mug_Lite.APIData.Publisher(name: ""), datePublished: "2023-06-13T04:40:00.0000000")], [Mug_Lite.APIData.webNewsSearch(query: "", name: "[SC현장]\"이젠 일상서 \'존버\'\"…\'더존2\' 유재석x이광수x권유리, 버티기도 재미도 업그레이드(종합) 스포츠조선 정빛 기자 디즈니+ \'더존2\'이 더 업그레이드된 재미를 자부했다. 디즈니+ \'더 존: 버텨야 산다2이하 \'더존2\'\'은 13일 서울 종로 JW메리어트 동대문 스퀘어 서울에서 제작발표회를 열었다. 이날 제작발표회에는 조효진 PD, 김동진 PD, 유", webSearchUrl: "https://sports.chosun.com/mobile/news.htm?id=202306130100095140011860&ServiceDate=20230613", image:  Mug_Lite.APIData.Thumbnail(contentUrl: "https://www.bing.com/th?id=OVFT.te7JlRzNdcABZb-IUq28By&pid=News.png", width: 700, height: 393), description: "[SC현장]\"이젠 일상서 \'존버\'\"…\'더존2\' 유재석x이광수x권유리, 버티기도 재미도 업그레이드(종합) 스포츠조선 정빛 기자 디즈니+ \'더존2\'이 더 업그레이드된 재미를 자부했다. 디즈니+ \'더 존: 버텨야 산다2이하 \'더존2\'\'은 13일 서울 종로 JW메리어트 동대문 스퀘어 서울에서 제작발표회를 열었다. 이날 제작발표회에는 조효진 PD, 김동진 PD, 유", provider: Mug_Lite.APIData.Publisher(name: "조선일보"), datePublished: "2023-06-13T03:28:00.0000000")], [Mug_Lite.APIData.webNewsSearch(query: "", name: "배우 권유리가 \'더 존2\'로 호흡을 맞춘 유재석 이광수를 향한 애정을 내비쳤다. 13일 디즈니+ 오리지널 예능 \'더 존: 버텨야 산다 시즌 2\'(이하 \'더 존2\')의 제작발표회가 진행됐다. 이 자리에는 조효진 김동진 PD와 유재석 이광수 권유리가 참석했다. \'더 존2\'는 일상생활을 위협하는 각종 재난 속 더 리얼하고 강력해진 극강의 8개 재난 시뮬레이션에", webSearchUrl: "https://www.msn.com/ko-kr/entertainment/news/%EB%8D%94-%EC%A1%B42-%EA%B6%8C%EC%9C%A0%EB%A6%AC-%EC%9C%A0%EC%9E%AC%EC%84%9D-%EC%9D%B4%EA%B4%91%EC%88%98%EC%99%80-%EC%B4%AC%EC%98%81-tv-%EB%B3%B4%EB%8A%94-%EB%8A%90%EB%82%8C/ar-AA1ct8FG", image:  Mug_Lite.APIData.Thumbnail(contentUrl: "https://www.bing.com/th?id=OVFT.25PGpbVbUB5Ygf7BvGKmRi&pid=News.png", width: 640, height: 538), description: "배우 권유리가 \'더 존2\'로 호흡을 맞춘 유재석 이광수를 향한 애정을 내비쳤다. 13일 디즈니+ 오리지널 예능 \'더 존: 버텨야 산다 시즌 2\'(이하 \'더 존2\')의 제작발표회가 진행됐다. 이 자리에는 조효진 김동진 PD와 유재석 이광수 권유리가 참석했다. \'더 존2\'는 일상생활을 위협하는 각종 재난 속 더 리얼하고 강력해진 극강의 8개 재난 시뮬레이션에", provider: Mug_Lite.APIData.Publisher(name: "한국일보 on MSN.com"), datePublished: "2023-06-13T03:14:52.0000000")], [Mug_Lite.APIData.webNewsSearch(query: "", name: "방송인 유재석과 배우 이광수 권유리가 \'더 존2\'를 통해 다시 뭉쳤다. 이광수는 프로그램을 통해 상상이 현실이 됐다고 귀띔해 기대를 높였다. 13일 디즈니+ 오리지널 예능 \'더 존: 버텨야 산다 시즌 2\'(이하 \'더 존2\')의 제작발표회가 진행됐다. 이 자리에는 조효진 김동진 PD와 유재석 이광수 권유리가 참석했다. \'더 존2\'는 일상생활을 위협하는 각종", webSearchUrl: "https://www.msn.com/ko-kr/news/other/%EC%83%81%EC%83%81%EC%9D%B4-%ED%98%84%EC%8B%A4%EB%A1%9C-%EB%8D%94-%EC%A1%B42-%EB%8B%A4%EC%8B%9C-%EB%AD%89%EC%B9%9C-%EC%9C%A0%EC%9E%AC%EC%84%9D-%EC%9D%B4%EA%B4%91%EC%88%98-%EA%B6%8C%EC%9C%A0%EB%A6%AC%EC%9D%98-%EC%8B%9C%EB%84%88%EC%A7%80-%EC%A2%85%ED%95%A9/ar-AA1ctb0C", image:  Mug_Lite.APIData.Thumbnail(contentUrl: "https://www.bing.com/th?id=OVFT.2__BnxiXRNcX5zkjYBnqTi&pid=News.png", width: 640, height: 448), description: "방송인 유재석과 배우 이광수 권유리가 \'더 존2\'를 통해 다시 뭉쳤다. 이광수는 프로그램을 통해 상상이 현실이 됐다고 귀띔해 기대를 높였다. 13일 디즈니+ 오리지널 예능 \'더 존: 버텨야 산다 시즌 2\'(이하 \'더 존2\')의 제작발표회가 진행됐다. 이 자리에는 조효진 김동진 PD와 유재석 이광수 권유리가 참석했다. \'더 존2\'는 일상생활을 위협하는 각종", provider: Mug_Lite.APIData.Publisher(name: "한국일보 on MSN.com"), datePublished: "2023-06-13T03:34:33.0000000")], [Mug_Lite.APIData.webNewsSearch(query: "", name: "김동진 연출,이광수,권유리,유재석,조효진 연출이 13일 오전 서울 종로구 JW 메리어트 동대문 스퀘어 서울에서 열린 디즈니+의 오리지널 예능 \'더 존: 버텨야 산다 시즌 2\' 제작발표회에 참석해 포즈를 취하고 있다. \'더 존: 버텨야 산다 시즌 2\'는 일상생활을 위협하는 각종 재난 속 더 리얼하고 강력해진 극강의 8개 재난 시뮬레이션에서 다시 뭉친 ‘수.유", webSearchUrl: "https://tenasia.hankyung.com/tv-drama/article/2023061360164", image:  Mug_Lite.APIData.Thumbnail(contentUrl: "https://www.bing.com/th?id=OVFT.x282ZLvy5TRHvHmzPNsW8C&pid=News.png", width: 630, height: 365), description: "김동진 연출,이광수,권유리,유재석,조효진 연출이 13일 오전 서울 종로구 JW 메리어트 동대문 스퀘어 서울에서 열린 디즈니+의 오리지널 예능 \'더 존: 버텨야 산다 시즌 2\' 제작발표회에 참석해 포즈를 취하고 있다. \'더 존: 버텨야 산다 시즌 2\'는 일상생활을 위협하는 각종 재난 속 더 리얼하고 강력해진 극강의 8개 재난 시뮬레이션에서 다시 뭉친 ‘수.유", provider: Mug_Lite.APIData.Publisher(name: "한경닷컴"), datePublished: "2023-06-13T02:55:00.0000000")]]
    
    var videoOffset = 0
    var videoSearchArray : [APIData.webVideoSearch] = []
    var loadedVideoSearchArray : [[APIData.webVideoSearch]] = [] //[[Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "#유재석 #나경은 유재석 \"나경은 아나운서, 나 때문에 방송 그만둬..\" #shorts", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=044E320244A845210B21044E320244A845210B21",  description: "#유재석 #나경은 유재석 \"나경은 아나운서, 나 때문에 방송 그만둬..\" #shorts", thumbnailUrl: "https://tse1.mm.bing.net/th?id=OVF.7Qt1l%2bJuOMkvWS3xqBQ92Q&pid=Api", datePublished: "2023-05-24T13:27:59.0000000", publisher: Mug_Lite.APIData.Publisher(name: "YouTube"), creator: Mug_Lite.APIData.Creator(name: "오늘 머 이슈?"), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=O6DnTSsyGT8", hostPageUrl: "https://www.youtube.com/watch?v=O6DnTSsyGT8", encodingFormat: "", hostPageDisplayUrl: "https://www.youtube.com/watch?v=O6DnTSsyGT8", width: 1080, height: 1920, duration: "PT52S", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/O6DnTSsyGT8?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 8, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 292, height: 520), videoId: "044E320244A845210B21044E320244A845210B21", allowMobileEmbed: true, isSuperfresh: true)], [Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "[놀면 뭐하니?] 나의 롤모델 석진 형에게 -하하가 | #유재석 #하하 #이이경 #이미주", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=199D9857993812F63981199D9857993812F63981",  description: "#놀면뭐하니 #shorts #놀뭐 #유재석 #이성미 #지석진 #예능어버이날 #가정의달 ★★★More \'Hangout with Yoo\' clips are available★★★ iMBC http://www.imbc.com/broad/tv/ent/hangoutwithyoo/vod/ WAVVE https://www.wavve.com/player/vod?programid=M_1004711100000100000&amp;page=1", thumbnailUrl: "https://tse1.mm.bing.net/th?id=OVF.XBmZTRm6cHEsqVl2XUyuSA&pid=Api", datePublished: "2023-05-24T09:01:00.0000000", publisher: Mug_Lite.APIData.Publisher(name: "YouTube"), creator: Mug_Lite.APIData.Creator(name: "놀면 뭐하니?"), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=Hz4gpjDxs5U", hostPageUrl: "https://www.youtube.com/watch?v=Hz4gpjDxs5U", encodingFormat: "h264", hostPageDisplayUrl: "https://www.youtube.com/watch?v=Hz4gpjDxs5U", width: 1080, height: 1920, duration: "PT1M", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/Hz4gpjDxs5U?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 11292, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 337, height: 600), videoId: "199D9857993812F63981199D9857993812F63981", allowMobileEmbed: true, isSuperfresh: true)], [Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "[놀면 뭐하니?] 노래 한다 지석진 모두들 스르륵😪 | #유재석 #이이경 #하하 #이미주", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=795E9204BA53F23A33C4795E9204BA53F23A33C4",  description: "#놀면뭐하니 #shorts #놀뭐 #유재석 #이성미 #지석진 #예능어버이날 #가정의달 ★★★More \'Hangout with Yoo\' clips are available★★★ iMBC http://www.imbc.com/broad/tv/ent/hangoutwithyoo/vod/ WAVVE https://www.wavve.com/player/vod?programid=M_1004711100000100000&amp;page=1", thumbnailUrl: "https://tse1.mm.bing.net/th?id=OVF.Ju%2bCaKs7b7pgsTILfwmHAw&pid=Api", datePublished: "2023-05-24T09:00:16.0000000", publisher: Mug_Lite.APIData.Publisher(name: "YouTube"), creator: Mug_Lite.APIData.Creator(name: "놀면 뭐하니?"), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=WOurU3VACGs", hostPageUrl: "https://www.youtube.com/watch?v=WOurU3VACGs", encodingFormat: "h264", hostPageDisplayUrl: "https://www.youtube.com/watch?v=WOurU3VACGs", width: 1080, height: 1920, duration: "PT57S", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/WOurU3VACGs?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 7804, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 337, height: 600), videoId: "795E9204BA53F23A33C4795E9204BA53F23A33C4", allowMobileEmbed: true, isSuperfresh: true)], [Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "아내를 자신의 세계로 감싸고 싶은 유재석.😵‍💫😵‍💫 #유재석", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=C2812962C6A4D41FC296C2812962C6A4D41FC296",  description: "URL 링크를 눌러 영상을 시청하세요", thumbnailUrl: "https://tse3.mm.bing.net/th?id=OVF.x7h1Tesd18URH7TDmcCSwg&pid=Api", datePublished: "2023-05-24T10:03:39.0000000", publisher: Mug_Lite.APIData.Publisher(name: "YouTube"), creator: Mug_Lite.APIData.Creator(name: "포춘캣 TV"), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=k3oqtBZFbyU", hostPageUrl: "https://www.youtube.com/watch?v=k3oqtBZFbyU", encodingFormat: "h264", hostPageDisplayUrl: "https://www.youtube.com/watch?v=k3oqtBZFbyU", width: 1080, height: 1920, duration: "PT28S", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/k3oqtBZFbyU?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 3071, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 337, height: 600), videoId: "C2812962C6A4D41FC296C2812962C6A4D41FC296", allowMobileEmbed: true, isSuperfresh: true)], [Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "지호가 꼴찌를 한다면? #유재석 #조세호", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=927003AA9BA9AE73C2D4927003AA9BA9AE73C2D4",  description: "#shorts #TVN #예능 #유퀴즈온더블럭", thumbnailUrl: "https://tse1.mm.bing.net/th?id=OVF.qZVZqO0rp86AHNMZZjnkZA&pid=Api", datePublished: "2023-05-24T10:37:40.0000000", publisher: Mug_Lite.APIData.Publisher(name: "YouTube"), creator: Mug_Lite.APIData.Creator(name: "웃으면 복"), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=czBT4NWALfk", hostPageUrl: "https://www.youtube.com/watch?v=czBT4NWALfk", encodingFormat: "", hostPageDisplayUrl: "https://www.youtube.com/watch?v=czBT4NWALfk", width: 1080, height: 1920, duration: "PT34S", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/czBT4NWALfk?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 95, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 292, height: 520), videoId: "927003AA9BA9AE73C2D4927003AA9BA9AE73C2D4", allowMobileEmbed: true, isSuperfresh: true)], [Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "🛸드론 조종하는 유재석:) #유재석 #쇼츠 #릴스 #인기급상승동영상 #인기급상승 #유머 #웃긴 #웃긴짤 #개그 #구독 #좋아요 #웃음 #재미", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=39616ADE566E5DD95EB739616ADE566E5DD95EB7",  description: "URL 링크를 눌러 영상을 시청하세요", thumbnailUrl: "https://tse1.mm.bing.net/th?id=OVF.bMn88TtCIvNXD5NDh4paYQ&pid=Api", datePublished: "2023-05-24T17:06:24.0000000", publisher: Mug_Lite.APIData.Publisher(name: "YouTube"), creator: Mug_Lite.APIData.Creator(name: "율쭈니네"), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=p7cFbQNQBjg", hostPageUrl: "https://www.youtube.com/watch?v=p7cFbQNQBjg", encodingFormat: "", hostPageDisplayUrl: "https://www.youtube.com/watch?v=p7cFbQNQBjg", width: 720, height: 1280, duration: "PT12S", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/p7cFbQNQBjg?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 1, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 292, height: 520), videoId: "39616ADE566E5DD95EB739616ADE566E5DD95EB7", allowMobileEmbed: true, isSuperfresh: true)], [Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "URL 링크를 눌러 영상을 시청하세요", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=62F3BDB05706B10868AF62F3BDB05706B10868AF",  description: "URL 링크를 눌러 영상을 시청하세요", thumbnailUrl: "https://tse1.mm.bing.net/th?id=OVF.gjBsCtGNTYgnSop4gnDsLQ&pid=Api", datePublished: "2023-05-24T19:19:21.0000000", publisher: Mug_Lite.APIData.Publisher(name: "YouTube"), creator: Mug_Lite.APIData.Creator(name: "이알 Official"), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=puFdE-Kqcdc", hostPageUrl: "https://www.youtube.com/watch?v=puFdE-Kqcdc", encodingFormat: "", hostPageDisplayUrl: "https://www.youtube.com/watch?v=puFdE-Kqcdc", width: 1080, height: 1920, duration: "PT36S", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/puFdE-Kqcdc?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 4, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 292, height: 520), videoId: "62F3BDB05706B10868AF62F3BDB05706B10868AF", allowMobileEmbed: true, isSuperfresh: true)], [Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "(미주)지인들이 도와준 Movie Star 챌린지!?#유재석#이이경#키#미연#우기", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=7D55FB1779453C7EC1A57D55FB1779453C7EC1A5",  description: "URL 링크를 눌러 영상을 시청하세요", thumbnailUrl: "https://tse2.mm.bing.net/th?id=OVF.NE18CLNNuIZpYtJ7BScHHQ&pid=Api", datePublished: "2023-05-24T23:37:57.0000000", publisher: Mug_Lite.APIData.Publisher(name: "YouTube"), creator: Mug_Lite.APIData.Creator(name: "IF&#39;O.d"), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=UMOjC1U02No", hostPageUrl: "https://www.youtube.com/watch?v=UMOjC1U02No", encodingFormat: "", hostPageDisplayUrl: "https://www.youtube.com/watch?v=UMOjC1U02No", width: 720, height: 1280, duration: "PT9S", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/UMOjC1U02No?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 2, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 292, height: 520), videoId: "7D55FB1779453C7EC1A57D55FB1779453C7EC1A5", allowMobileEmbed: true, isSuperfresh: true)], [Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "[이알] 냅다 질러버리기 시리즈1 #shorts #신촌 #버스킹 #일반인노래 #처진달팽이 #유재석 #이적 #말하는대로", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=47F14A273EF329F1346C47F14A273EF329F1346C",  description: "URL 링크를 눌러 영상을 시청하세요", thumbnailUrl: "https://tse2.mm.bing.net/th?id=OVF.%2fKl8vjAjUhCwHYpbFnSVOQ&pid=Api", datePublished: "2023-05-24T19:21:14.0000000", publisher: Mug_Lite.APIData.Publisher(name: "YouTube"), creator: Mug_Lite.APIData.Creator(name: "이알 Official"), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=UqzIAa5SkjQ", hostPageUrl: "https://www.youtube.com/watch?v=UqzIAa5SkjQ", encodingFormat: "", hostPageDisplayUrl: "https://www.youtube.com/watch?v=UqzIAa5SkjQ", width: 1080, height: 1920, duration: "PT10S", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/UqzIAa5SkjQ?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 8, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 292, height: 520), videoId: "47F14A273EF329F1346C47F14A273EF329F1346C", allowMobileEmbed: true, isSuperfresh: true)], [Mug_Lite.APIData.webVideoSearch(query: "유재석", name: "[무도의 5월은 어땠을까?] 홍철, 길, 하하를 위해 형돈이가 보약을 쏜다!😮 아픈 곳만 쏙쏙 골라 침놓는 한의사 선생님에게 매료되어 다른 멤버들도 불러 모으는데!👨🏻‍⚕ 방영일자 : 20130720 무한도전 1화부터 FULL버전 다시 보기 (2006년 5월 6일~2018년 3월 31일) → ...", webSearchUrl: "https://www.bing.com/videos/search?q=%EC%9C%A0%EC%9E%AC%EC%84%9D&view=detail&mid=6D9119026D9FC99ACFFD6D9119026D9FC99ACFFD",  description: "[무도의 5월은 어땠을까?] 홍철, 길, 하하를 위해 형돈이가 보약을 쏜다!😮 아픈 곳만 쏙쏙 골라 침놓는 한의사 선생님에게 매료되어 다른 멤버들도 불러 모으는데!👨🏻‍⚕ 방영일자 : 20130720 무한도전 1화부터 FULL버전 다시 보기 (2006년 5월 6일~2018년 3월 31일) → ...", thumbnailUrl: "https://tse3.mm.bing.net/th?id=OVF.QWZH6fDv0tq%2f1y8Bt0%2fs6w&pid=Api", datePublished: "2023-05-24T09:00:36.0000000", publisher: Mug_Lite.APIData.Publisher(name: ""), creator: Mug_Lite.APIData.Creator(name: ""), isAccessibleForFree: true, isFamilyFriendly: true, contentUrl: "https://www.youtube.com/watch?v=r7QgnBewMac", hostPageUrl: "https://www.youtube.com/watch?v=r7QgnBewMac", encodingFormat: "h264", hostPageDisplayUrl: "https://www.youtube.com/watch?v=r7QgnBewMac", width: 480, height: 360, duration: "PT23M26S", embedHtml: "&lt;iframe width=&quot;1280&quot; height=&quot;720&quot; src=&quot;https://www.youtube.com/embed/r7QgnBewMac?autoplay=1&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;", allowHttpsEmbed: true, viewCount: 82133, thumbnail: Mug_Lite.APIData.Thumbnail(contentUrl: "", width: 480, height: 360), videoId: "6D9119026D9FC99ACFFD6D9119026D9FC99ACFFD", allowMobileEmbed: true, isSuperfresh: true)]]
    
    func merge() {
        
        for newsArray in loadedKeywordNewsArray {
            //print("loadedNewsSearchArray: \(loadedNewsSearchArray.count)")
            totalSearch.append(newsArray)
        }
        for videoArray in loadedVideoSearchArray {
            //print("loadedVideoSearchArray: \(loadedVideoSearchArray.count)")
            totalSearch.append(videoArray)
        }
        
        totalSearch.shuffle()
        
        //print("totalSearch: \(totalSearch)")
        //print("totalSearch.count: \(totalSearch.count)")
    }
    
    

    private init() {} // 다른 인스턴스 생성 방지
}
