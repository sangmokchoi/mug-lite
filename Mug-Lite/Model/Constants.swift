//
//  Constants.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/05/25.
//

import Foundation

struct Constants {
    struct K {
        static let subscriptionKey = "b6ec61726d2d4d98bd3bf62aeffa1cee"
        static let query = "유재석"
        static let headlineNews = "뉴스"
        static let mkt = "ko-KR"
        static let keywordLimit = 10
        static let defaultPoint = 3000
        static let refreshCost = 150
        
        static let bannedKeywordList: [String] = ["COVID-19", "COVID19", "coronavirus", "SARS-CoV-2", "pandemic", "virus", "pandemic", "코로나", "코로나 바이러스", "코로나바이러스", "감염병", "coronavirus disease 2019", "coronavirus 2019", "coronavirus disease", "коронавирус", "вирус", "пандемия", "заражение", "virus corona", "コロナウイルス", "新型コロナウイルス", "コロナ", "感染症", "ウイルス", "新型冠状病毒", "新冠肺炎", "新型冠状病毒", "冠状病毒", "新冠疫情", "新冠", "新型冠状病毒肺炎", "冠狀病毒", "新冠病毒", "新冠肺炎", "疫情", "病毒", "pandemia", "infección", "pandémie", "infection", "Pandemie", "Infektion", "Virus", "virus", "فيروس" ,"عدوى", "وباء", "فيروس كورونا", "كوفيد-19", "infecção", "besmetting", "pandemi", "enfeksiyon",  "कोविड-19", "कोरोना वायरस", "महामारी", "संक्रमण", "वायरस", "โคโรนาไวรัส", "โควิด-19", "การระบาด", "การติดเชื้อ", "เชื้อไวรัส", "vi-rút corona", "đại dịch", "nhiễm trùng", "vi-rút", "infeksi", "infektion"]
                                                  
        static let BookmarkVC_FBBannerAdPlacementID = "253023537370562_254136707259245" // 북마크 기능 사용 안함
        
        static let FBinterstitialAdPlacementID = "253023537370562_255835213756061"
        static let ArchiveVC_FBBannerAdPlacementID = "253023537370562_255874240418825"
        static let KeywordRegisterVC_FBBannerAdPlacementID = "253023537370562_255876230418626"
        static let FBNativeAdPlacementID = "253023537370562_254697537203162"
        
        static let SettingVC_FBBannerAdPlacementID = "253023537370562_254136607259255"
        static let SettingVC_FBRewardedVideoAD = "253023537370562_258220163517566"
        static let SettingVC_FBRewardedInterstitialAD = "253023537370562_258222173517365"
    }
}
