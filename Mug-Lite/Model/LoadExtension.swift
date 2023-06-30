//
//  LoadExtension.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/23.
//

import UIKit

extension UIViewController { //AcrhiveViewController {
    
    func webSearch(query: String) { // webSearch
        let webSearch = APIData.webSearch(
            query: "",
            id: "",
            name: "",
            webSearchUrl: "",
            isFamilyFriendly: true,
            displayUrl: "",
            snippet: "",
            varlanguage: "",
            isNavigational: false
        )
        
        var webSearchArray : [APIData.webSearch] = []
        
        let mkt = "ko-KR"
        var count = ""
        var totalEstimatedMatches = ""
        var offset = ""
        
        guard let encodedQuery = Constants.K.query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            print("Error: cannot encode the query.")
            return
        }
        //        let urlString = "https://api.bing.microsoft.com/v7.0/search?q=\(encodedQuery)&textDecorations=true&mkt=\(mkt)&textFormat=HTML"
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.bing.microsoft.com"
        components.path = "/v7.0/search"
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "count", value: "20"),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "textDecorations", value: "true"),
            URLQueryItem(name: "mkt", value: Constants.K.mkt),
            URLQueryItem(name: "textFormat", value: "HTML"),
            URLQueryItem(name: "freshness", value: "Day")
        ]
        
        guard let url = components.url else {
            print("Error: cannot create URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Constants.K.subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error: cannot get data.")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Error: cannot parse JSON data.")
                return
            }
            guard let webPages = json["webPages"] as? [String: Any], let value = webPages["value"] as? [[String: Any]] else {
                print("웹 서치 API Error: cannot find webPages or value in JSON data.")
                return
            }
            
            for item in value {
                if let name = item["snippet"] as? String {
                    if name.contains("<b>") || name.contains("&#39;") || name.contains("&quot;") || name.contains("&amp;"){
                        let strippedName0 = name.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                        let strippedName1 = strippedName0.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "\"")
                        let strippedName2 = strippedName1.replacingOccurrences(of: "&amp;", with: "&")
                        //webSearch.append()
                        //print(strippedName1)
                        
                    } else {
                        print(name)
                    }
                }
            }
            print(value)
        }
        task.resume()
    }
    
    func apiNewsSearch(query: String, count: Int, mkt: String, offset: Int, keywordSearch: Bool) { //webNewsSearch

        var name = ""
        var URL = ""
        var image_thumbnail_contentUrl = ""
        var image_thumbnail_width = 0
        var image_thumbnail_height = 0
        var description = ""
        var provider_type = ""
        var provider_name = ""
        var provider_image_thumbnail_contentUrl = ""
        var provider_image_thumbnail_width = 0
        var provider_image_thumbnail_height = 0
        var datePublished = ""
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            print("Error: cannot encode the query.")
            return
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.bing.microsoft.com"
        components.path = "/v7.0/news/search"
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "count", value: "\(count)"),
            URLQueryItem(name: "offset", value: "\(offset)"), //The offset parameter specifies the number of results to skip. The offset is zero-based and should be less than (totalEstimatedMatches - count).
            URLQueryItem(name: "textDecorations", value: "false"),
            URLQueryItem(name: "mkt", value: mkt),
            URLQueryItem(name: "textFormat", value: "HTML"),
            URLQueryItem(name: "freshness", value: "Week") //Week, Month
        ]
        
        guard let url = components.url else {
            print("Error: cannot create URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Constants.K.subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                print("Error: cannot get data.")
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Error: cannot parse JSON data.")
                return
            }

            guard let value = json["value"] as? [[String: Any]] else {
                print("뉴스 API Error: cannot find webPages or value in JSON data.")
                return
            }
            //print("value: \(value)")
            DataStore.shared.newsOffset = DataStore.shared.newsOffset + count + 1
            // 배열 초기화
            DataStore.shared.newsSearchArray = []
            
            for item in value {
                // 변수 초기화
                name = ""
                URL = ""
                image_thumbnail_contentUrl = ""
                image_thumbnail_width = 0
                image_thumbnail_height = 0
                description = ""
                provider_type = ""
                provider_name = ""
                provider_image_thumbnail_contentUrl = ""
                provider_image_thumbnail_width = 0
                provider_image_thumbnail_height = 0
                datePublished = ""
                
                if let newName = item["name"] as? String,
                   let newUrl = item["url"] as? String,
                   let newDescription = item["description"] as? String,
                   let newDatePublished = item["datePublished"] as? String {
                    
                    print("newName: \(newName)")
//                    print("newUrl: \(newUrl)")
                    print("newDescription: \(newDescription)")
                    var newImage0 = item["image"] as? [String: Any]
                    print("newImage0: \(newImage0)")
                    print("value: \(value)")
                    
                    if let newImage = item["image"] as? [String: Any] {
                        if let newThumbnail = newImage["thumbnail"] as? [String: Any] {
                            let newContentUrl = newThumbnail["contentUrl"] as! String
                            let newWidth = newThumbnail["width"] as! Int
                            let newHeight = newThumbnail["height"] as! Int
                            
                            //print("newImage: \(newImage)")
                            //print("newThumbnail: \(newThumbnail)")
                            
                            image_thumbnail_contentUrl = newContentUrl+".jpg"
                            print("image_thumbnail_contentUrl: \(image_thumbnail_contentUrl)")
                            image_thumbnail_width = newWidth
                            image_thumbnail_height = newHeight
                        }
                    }
                    
                    if query != Constants.K.headlineNews { // 손흥민, 유재석 등의 키워드
                        //print("query != Constants.K.headlineNews")
                        var containQuery = newDescription.contains(query)
                        
                        if containQuery == true { //쿼리명이 쿼리 내용에 포함된 것들만 가져옴
                            var modifiedDescription = newDescription
                            var modifiedName = newName
                            var modifiedDatePublished = newDatePublished
                            
                            //print("modifiedDescription: \(modifiedDescription)")
                            //print("modifiedName: \(modifiedName)")
                            
                            if newDescription.contains("<b>") || newDescription.contains("&#39;") || newDescription.contains("&quot;") || newDescription.contains("&amp;") || newDescription.contains("&nbsp;") || newDescription.contains("&lt;") || newDescription.contains("&gt;") || newDescription.contains("&#35;") || newDescription.contains("&#035;") || newDescription.contains("&#039;") {
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "\"")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#amp;", with: "&").replacingOccurrences(of: "&nbsp;", with: " ")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#35;", with: "#").replacingOccurrences(of: "&#035;", with: "#")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#039;", with: "'")
                            }
                            if newName.contains("<b>") || newName.contains("&#39;") || newName.contains("&quot;") || newName.contains("&amp;") || newName.contains("&nbsp;") || newName.contains("&lt;") || newName.contains("&gt;") || newName.contains("&#35;") || newName.contains("&#035;") || newName.contains("&#039;") {
                                modifiedName = modifiedName.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                                modifiedName = modifiedName.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "\"")
                                modifiedName = modifiedName.replacingOccurrences(of: "&#amp;", with: "&").replacingOccurrences(of: "&nbsp;", with: " ")
                                modifiedName = modifiedName.replacingOccurrences(of: "&#lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
                                modifiedName = modifiedName.replacingOccurrences(of: "&#35;", with: "#").replacingOccurrences(of: "&#035;", with: "#")
                                modifiedName = modifiedName.replacingOccurrences(of: "&#039;", with: "'")
                            }
                            if newDatePublished.contains("Z"){
                                modifiedDatePublished = modifiedDatePublished.replacingOccurrences(of: "Z", with: "")
                            }
                            
                            name = modifiedName
                            //print("name: \(name)")
                            description = modifiedDescription
                            URL = newUrl
                            datePublished = modifiedDatePublished
                            
                            if let newProviderArray = item["provider"] as? [[String: Any]],
                               let newProvider = newProviderArray.first {
                                //print("newProvider: \(newProvider)")
                                
                                //print("newProviderArray: \(newProviderArray)")
                                //print("newProvider: \(newProvider)")
                                
                                if let newProvider_name = newProvider["name"] as? String {
                                    let newProvider_type = newProvider["_type"] as! String
                                    
                                    //print("newProvider_type: \(newProvider_type)")
                                    //print("newProvider_name: \(newProvider_name)")
                                    //print("newProvider_image: \(newProvider_image)")
                                    //print("provider_image_thumbnail: \(provider_image_thumbnail)")
                                    
                                    provider_type = newProvider_type
                                    provider_name = newProvider_name
                                    
                                    if let newProvider_image = newProvider["image"] as? [String: Any], let provider_image_thumbnail = newProvider_image["thumbnail"] as? [String: Any], let newContentUrl = provider_image_thumbnail["contentUrl"] as? String {
                                        
                                        //print("newContentUrl: \(newContentUrl)")
                                        provider_image_thumbnail_contentUrl = newContentUrl
                                        
                                        if image_thumbnail_contentUrl == nil || image_thumbnail_contentUrl == "" {
                                            image_thumbnail_contentUrl = provider_image_thumbnail_contentUrl+".jpg"
                                            print("image_thumbnail_contentUrl: \(image_thumbnail_contentUrl)")
                                        }
                                        
                                    }
                                }
                            }
                            
                            var newData = APIData.webNewsSearch(
                                query: query,
                                name: name,
                                webSearchUrl: URL,
                                image: APIData.Thumbnail(
                                    contentUrl: image_thumbnail_contentUrl,
                                    width: image_thumbnail_width,
                                    height: image_thumbnail_height
                                ),
                                description: description,
                                provider: APIData.Publisher(name: provider_name),
                                datePublished: datePublished
                            )
                            print("newData: \(newData)")
                            if keywordSearch == true { // 키워드 검색용임 (어레이 분리 필요)
                                DataStore.shared.keywordNewsArray.append(newData)
                                DataStore.shared.loadedKeywordNewsArray.append(DataStore.shared.keywordNewsArray)
                                // 배열 초기화
                                DataStore.shared.keywordNewsArray = []
                            } else {
                                DataStore.shared.keywordNewsArray.append(newData)
                                DataStore.shared.loadedKeywordNewsArray.append(DataStore.shared.keywordNewsArray)
                                // 배열 초기화
                                DataStore.shared.keywordNewsArray = []
                            }
                            
                        }
                    } else { // query == Constants.K.headlineNews 이므로 주요 기사만을 가져오며, 쿼리명이 쿼리 내용에 포함된 여부와 상관없이 모두 가져옴
                        //print("query == Constants.K.headlineNews")
                        var modifiedDescription = newDescription
                        var modifiedName = newName
                        var modifiedDatePublished = newDatePublished
                        
                        //print("modifiedDescription: \(modifiedDescription)")
                        //print("modifiedName: \(modifiedName)")
                        
                        if newDescription.contains("<b>") || newDescription.contains("&#39;") || newDescription.contains("&quot;") || newDescription.contains("&amp;") || newDescription.contains("&nbsp;") || newDescription.contains("&lt;") || newDescription.contains("&gt;") || newDescription.contains("&#35;") || newDescription.contains("&#035;") || newDescription.contains("&#039;") {
                            modifiedDescription = modifiedDescription.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                            modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "\"")
                            modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#amp;", with: "&").replacingOccurrences(of: "&nbsp;", with: " ")
                            modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
                            modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#35;", with: "#").replacingOccurrences(of: "&#035;", with: "#")
                            modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#039;", with: "'")
                        }
                        if newName.contains("<b>") || newName.contains("&#39;") || newName.contains("&quot;") || newName.contains("&amp;") || newName.contains("&nbsp;") || newName.contains("&lt;") || newName.contains("&gt;") || newName.contains("&#35;") || newName.contains("&#035;") || newName.contains("&#039;") {
                            modifiedName = modifiedName.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                            modifiedName = modifiedName.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "\"")
                            modifiedName = modifiedName.replacingOccurrences(of: "&#amp;", with: "&").replacingOccurrences(of: "&nbsp;", with: " ")
                            modifiedName = modifiedName.replacingOccurrences(of: "&#lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
                            modifiedName = modifiedName.replacingOccurrences(of: "&#35;", with: "#").replacingOccurrences(of: "&#035;", with: "#")
                            modifiedName = modifiedName.replacingOccurrences(of: "&#039;", with: "'")
                        }
                        if newDatePublished.contains("Z"){
                            modifiedDatePublished = modifiedDatePublished.replacingOccurrences(of: "Z", with: "")
                        }
                        
                        name = modifiedName
                        description = modifiedDescription
                        URL = newUrl
                        datePublished = modifiedDatePublished
                        
                        if let newProviderArray = item["provider"] as? [[String: Any]],
                           let newProvider = newProviderArray.first {
                            
                            //print("newProviderArray: \(newProviderArray)")
                            //print("newProvider: \(newProvider)")

                            if let newProvider_type = newProvider["_type"] as? String,
                               let newProvider_name = newProvider["name"] as? String,
                               let newProvider_image = newProvider["image"] as? [String: Any],
                               let provider_image_thumbnail = newProvider_image["thumbnail"] as? [String: Any] {
                                
                                //print("newProvider_type: \(newProvider_type)")
                                //print("newProvider_name: \(newProvider_name)")
                                //print("newProvider_image: \(newProvider_image)")
                                //print("provider_image_thumbnail: \(provider_image_thumbnail)")
                                
                                provider_type = newProvider_type
                                provider_name = newProvider_name
                                
                                if let newContentUrl = provider_image_thumbnail["contentUrl"] as? String {
                                    
                                    //print("newContentUrl: \(newContentUrl)")
                                    provider_image_thumbnail_contentUrl = newContentUrl
                                    
                                    if image_thumbnail_contentUrl == nil || image_thumbnail_contentUrl == "" {
                                        image_thumbnail_contentUrl = provider_image_thumbnail_contentUrl+".jpg"
                                        print("image_thumbnail_contentUrl: \(image_thumbnail_contentUrl)")
                                    }
                                    
                                }
                            }
                        }
                        
                        var newData = APIData.webNewsSearch(
                            query: query,
                            name: name,
                            webSearchUrl: URL,
                            image: APIData.Thumbnail(
                                contentUrl: image_thumbnail_contentUrl,
                                width: image_thumbnail_width,
                                height: image_thumbnail_height
                            ),
                            description: description,
                            provider: APIData.Publisher(name: provider_name),
                            datePublished: datePublished
                        )
                        print("newData: \(newData)")
                        DataStore.shared.newsSearchArray.append(newData)
                        DataStore.shared.loadedNewsSearchArray.append(DataStore.shared.newsSearchArray)
                        // 배열 초기화
                        DataStore.shared.newsSearchArray = []
                    }
                }
                
            }
            // for 문 종료됨
            //print("DataStore.shared.loadedNewsSearchArray: \(DataStore.shared.loadedNewsSearchArray)")
            
            //print("DataStore.shared.loadedNewsSearchArray.count: \(DataStore.shared.loadedNewsSearchArray.count)")
            NotificationCenter.default.post(name: Notification.Name("UserInputKeywordSearch"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("mergeIsReadyFromNews"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("loadingIsDone"), object: nil)
            
        }
        task.resume()
        
        
    }
    
    func apiVideoSearch(query: String, count: Int, mkt: String, offset: Int) { //webVideoSearch
        print("apiVideoSearch 실행!")
        var webSearchUrl : String = ""
        var name : String = ""
        var description : String = ""
        var thumbnailUrl : String = ""
        var datePublished : String = ""
        
        var publisher_name : String = ""
        var creator_name : String = ""
        var isAccessibleForFree : Bool = true
        var isFamilyFriendly : Bool = true
        var contentUrl : String = ""
        var hostPageUrl : String = ""
        var encodingFormat : String = ""
        var hostPageDisplayUrl : String = ""
        var width : Int = 0
        var height : Int = 0
        var duration : String = ""
        var embedHtml : String = ""
        var allowHttpsEmbed : Bool = true
        var viewCount : Int = 0
        var thumbnail_contentUrl : String = ""
        var thumbnail_width : Int = 0
        var thumbnail_height : Int = 0
        var videoId : String = ""
        var allowMobileEmbed : Bool = true
        var isSuperfresh : Bool = true
        
        let videoSearch = APIData.webVideoSearch(
            publisher: APIData.Publisher(),
            creator: APIData.Creator(),
            thumbnail: APIData.Thumbnail()
        )
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            print("Error: cannot encode the query.")
            return
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.bing.microsoft.com"
        components.path = "/v7.0/videos/search"
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "count", value: "\(count)"),
            URLQueryItem(name: "offset", value: "\(offset)"), //The offset parameter specifies the number of results to skip. The offset is zero-based and should be less than (totalEstimatedMatches - count).
            URLQueryItem(name: "textDecorations", value: "false"),
            URLQueryItem(name: "mkt", value: mkt),
            URLQueryItem(name: "textFormat", value: "HTML"),
            URLQueryItem(name: "freshness", value: "Day") //Day, Week, Month
        ]
        
        guard let url = components.url else {
            print("Error: cannot create URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Constants.K.subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error: cannot get data.")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Error: cannot parse JSON data.")
                return
            }
            guard let value = json["value"] as? [[String: Any]] else { //let totalEstimatedMatches = json["totalEstimatedMatches"] as? Int,
                print("비디오 API Error: cannot find webPages or value in JSON data.")
                return
            }
            //self.totalEstimatedResults = totalEstimatedMatches
            DataStore.shared.videoOffset = DataStore.shared.videoOffset + count + 1
            //print("DataStore.shared.videoOffset: \(DataStore.shared.videoOffset)")
            
            // 배열 초기화
            DataStore.shared.videoSearchArray = []
            
            for item in value {
                //print("item: \(item)")
                // 변수 초기화
                webSearchUrl = ""
                name = ""
                description = ""
                thumbnailUrl = ""
                datePublished = ""
                
                publisher_name = ""
                creator_name = ""
                
                isAccessibleForFree = true //1 또는 0
                isFamilyFriendly = true //1 또는 0
                
                contentUrl = ""
                hostPageUrl = ""
                encodingFormat = ""
                hostPageDisplayUrl = ""
                
                width = 0
                height = 0
                duration = ""
                embedHtml = ""
                allowHttpsEmbed = true
                viewCount = 0
                
                thumbnail_contentUrl = ""
                thumbnail_width = 0
                thumbnail_height = 0
                
                videoId = ""
                allowMobileEmbed = true
                isSuperfresh = true
                
                if let newWebSearchUrl = item["webSearchUrl"] as? String {
                    var containQuery = newWebSearchUrl.contains("youtube")
                    // 유튜브만 뺴고 가져오려면? var containQuery = newDescription.contains(query)
                    if containQuery == false {
                        
                        let newDescription = item["description"] as? String ?? "URL 링크를 눌러 영상을 시청하세요"
                        
                        if let newWebSearchUrl = item["webSearchUrl"] as? String,
                           let newName = item["name"] as? String,
                           let newThumbnailUrl = item["thumbnailUrl"] as? String,
                           let newDatePublished = item["datePublished"] as? String {
                            
                            var modifiedDescription = newDescription
                            var modifiedName = newName
                            var modifiedDatePublished = newDatePublished
                            
                            if newDescription.contains("<b>") || newDescription.contains("&#39;") || newDescription.contains("&quot;") || newDescription.contains("&amp;") || newDescription.contains("&nbsp;") || newDescription.contains("&lt;") || newDescription.contains("&gt;") || newDescription.contains("&#35;") || newDescription.contains("&#035;") || newDescription.contains("&#039;"){
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "\"")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#amp;", with: "&").replacingOccurrences(of: "&nbsp;", with: " ")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#35;", with: "#").replacingOccurrences(of: "&#035;", with: "#")
                                modifiedDescription = modifiedDescription.replacingOccurrences(of: "&#039;", with: "'")
                            }
                            if newName.contains("<b>") || newName.contains("&#39;") || newName.contains("&quot;") || newName.contains("&amp;") || newName.contains("&nbsp;") || newName.contains("&lt;") || newName.contains("&gt;") || newName.contains("&#35;") || newName.contains("&#035;") || newName.contains("&#039;") {
                                modifiedName = modifiedName.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                                modifiedName = modifiedName.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "\"")
                                modifiedName = modifiedName.replacingOccurrences(of: "&#amp;", with: "&").replacingOccurrences(of: "&nbsp;", with: " ")
                                modifiedName = modifiedName.replacingOccurrences(of: "&#lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
                                modifiedName = modifiedName.replacingOccurrences(of: "&#35;", with: "#").replacingOccurrences(of: "&#035;", with: "#")
                                modifiedName = modifiedDescription.replacingOccurrences(of: "&#039;", with: "'")
                            }
                            if newDatePublished.contains("Z"){
                                modifiedDatePublished = modifiedDatePublished.replacingOccurrences(of: "Z", with: "")
                            }
                            webSearchUrl = newWebSearchUrl
                            name = modifiedName
                            description = modifiedDescription
                            thumbnailUrl = newThumbnailUrl
                            datePublished = modifiedDatePublished
                            //                        print("webSearchUrl: \(webSearchUrl)")
                            //                        print("name: \(name)")
                            //                        print("description: \(description)")
                            //                        print("thumbnailUrl: \(thumbnailUrl)")
                            //                        print("datePublished: \(datePublished)")
                            //                        print("\n")
                        }
                        
                        if let newPublisherArray = item["publisher"] as? [[String: Any]],
                           let newPublisher = newPublisherArray.first,
                           let newCreatorArray = item["creator"] as? [String: Any] {
                            
                            let newPublisher_Name = newPublisher["name"] as! String
                            let newCreator = newCreatorArray["name"] as! String
                            
                            publisher_name = newPublisher_Name
                            creator_name = newCreator
                        }
                        
                        if let newIsAccessibleForFree = item["isAccessibleForFree"] as? Bool,
                           let newIsFamilyFriendly = item["isFamilyFriendly"] as? Bool {
                            
                            isAccessibleForFree = newIsAccessibleForFree
                            isFamilyFriendly = newIsFamilyFriendly
                        }
                        if let newContentUrl = item["contentUrl"] as? String,
                           let newHostPageUrl = item["hostPageUrl"] as? String,
                           let newEncodingFormat = item["encodingFormat"] as? String,
                           let newHostPageDisplayUrl = item["hostPageDisplayUrl"] as? String {
                            
                            contentUrl = newContentUrl
                            hostPageUrl = newHostPageUrl
                            encodingFormat = newEncodingFormat
                            hostPageDisplayUrl = newHostPageDisplayUrl
                        }
                        
                        if let newWidth = item["width"] as? Int,
                           let newHeight = item["height"] as? Int,
                           let newDuration = item["duration"] as? String,
                           let newEmbedHtml = item["embedHtml"] as? String,
                           let newAllowHttpsEmbed = item["allowHttpsEmbed"] as? Bool,
                           let newviewCount = item["viewCount"] as? Int {
                            
                            width = newWidth
                            height = newHeight
                            duration = newDuration
                            embedHtml = newEmbedHtml
                            allowHttpsEmbed = newAllowHttpsEmbed
                            viewCount = newviewCount
                        }
                        
                        if let newThumbnailArray = item["thumbnail"] as? [String: Any] {
                            
                            thumbnail_contentUrl = ""
                            thumbnail_width = newThumbnailArray["width"] as! Int
                            thumbnail_height = newThumbnailArray["height"] as! Int
                            
                        }
                        
                        if let newVideoId = item["videoId"] as? String,
                           let newAllowMobileEmbed = item["allowMobileEmbed"] as? Bool,
                           let newIsSuperfresh = item["isSuperfresh"] as? Bool {
                            
                            videoId = newVideoId
                            allowMobileEmbed = newAllowMobileEmbed
                            isSuperfresh = newIsSuperfresh
                        }
                    }
                    
                    var newData = APIData.webVideoSearch(
                        query: query,
                        name: name,
                        webSearchUrl: webSearchUrl,
                        description: description,
                        thumbnailUrl: thumbnailUrl,
                        datePublished: datePublished,
                        publisher: APIData.Publisher(
                            name: publisher_name
                        ),
                        creator: APIData.Creator(
                            name: creator_name
                        ),
                        isAccessibleForFree: isAccessibleForFree,
                        isFamilyFriendly: isFamilyFriendly,
                        contentUrl: contentUrl,
                        hostPageUrl: hostPageUrl,
                        encodingFormat: encodingFormat,
                        hostPageDisplayUrl: hostPageDisplayUrl,
                        width: width,
                        height: height,
                        duration: duration,
                        embedHtml: embedHtml,
                        allowHttpsEmbed: allowHttpsEmbed,
                        viewCount: viewCount,
                        thumbnail: APIData.Thumbnail(
                            contentUrl: thumbnail_contentUrl,
                            width: thumbnail_width,
                            height: thumbnail_height
                        ),
                        videoId: videoId,
                        allowMobileEmbed: allowMobileEmbed,
                        isSuperfresh: isSuperfresh)
                    
                    //print("newData: \(newData)")
                    
                    DataStore.shared.videoSearchArray.append(newData)
                    //self.loadedVideoSearchArray.append(self.videoSearchArray)
                    DataStore.shared.loadedVideoSearchArray.append(DataStore.shared.videoSearchArray)
                    // 배열 초기화
                    DataStore.shared.videoSearchArray = []
                }
            }
            //print("DataStore.shared.loadedVideoSearchArray: \(DataStore.shared.loadedVideoSearchArray)")
            print("DataStore.shared.loadedVideoSearchArray.count: \(DataStore.shared.loadedVideoSearchArray.count)")
            // for 문 종료됨
            NotificationCenter.default.post(name: Notification.Name("mergeIsReadyFromVideo"), object: nil)
            // 데이터 설정
            //DataStore.shared.loadedVideoSearchArray = self.loadedVideoSearchArray
        }
        task.resume()
    }
    
    func extractFirstImageURL(from htmlString: String) -> String? {
        print("extractFirstImageURL 진입")
        print("htmlString: \(htmlString)")
        let pattern = "<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>"

        //DispatchQueue.main.async {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                print("regex: \(regex)")
                if let match = regex.firstMatch(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count)) {
                    print("match: \(match)")
                    let nsRange = match.range(at: 1)
                    print("nsRange: \(nsRange)")
                    if let range = Range(nsRange, in: htmlString) {
                        print("range: \(range)")
                        let imageUrlString = String(htmlString[range])
                        print("imageUrlString: \(imageUrlString)")
                        return imageUrlString
                    }
                }
            }
        //}
            
        return nil
        
        }
    
}

extension CGSize {
    func aspectFit(to boundingSize: CGSize) -> CGSize {
        let aspectRatio = self.width / self.height // 디바이스의 사이즈
        let targetAspectRatio = boundingSize.width / boundingSize.height // 입력된 view의 사이즈
        var scaledSize = CGSize.zero
        
        if aspectRatio > targetAspectRatio {
            let scaledHeight = boundingSize.width / aspectRatio
            scaledSize = CGSize(width: boundingSize.width, height: scaledHeight)
        } else {
            let scaledWidth = boundingSize.height * aspectRatio
            scaledSize = CGSize(width: scaledWidth, height: boundingSize.height)
        }
        return scaledSize
    }

}
