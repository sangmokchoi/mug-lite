//
//  XMLParser.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/08.
//

import Foundation

class MyXMLParser: NSObject, XMLParserDelegate {
    
    var currentElement: String = ""
    var currentTitle: String = ""
    var currentLink: String = ""
    var currentPubDate: String = ""
    var currentDescription: String = ""
    
    var titles: [String] = []
    var links: [String] = []
    var pubDates: [String] = []
    var descriptions: [String] = []
    
    func parseXML(from url: URL) {
        let xmlParser = XMLParser(contentsOf: url)
        xmlParser?.delegate = self
        xmlParser?.parse()
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("Parsing started")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("Parsing ended")
        print(titles)
        print(links)
        print(pubDates)
        print(descriptions)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            currentTitle += string
        case "link":
            currentLink += string
        case "pubDate":
            currentPubDate += string
        case "description":
            currentDescription += string
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch currentElement {
        case "title":
            titles.append(currentTitle)
            currentTitle = ""
        case "link":
            links.append(currentLink)
            currentLink = ""
        case "pubDate":
            pubDates.append(currentPubDate)
            currentPubDate = ""
        case "description":
            descriptions.append(currentDescription)
            currentDescription = ""
        default:
            break
        }
    }
}

