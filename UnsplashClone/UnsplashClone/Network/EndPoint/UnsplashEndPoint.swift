//
//  UnsplashEndPoint.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/12.
//

import Foundation

enum UnsplashEndPoint {
    case photos(page: Int, perPage: Int)
    case photo(id: String)
    case photoURL(url: String, width: Int)
    case searchPhotos(page: Int, perPage: Int, query: String)
    case randomPhoto
}

extension UnsplashEndPoint: EndPointType {
    
    var url: URL? {
        switch self {
        case .photos(let page, let perPage):
            return URL(string: "\(UnsplashEndPoint.baseURL)/photos?page=\(page)&per_page=\(perPage)")
        case .photo(let id):
            return URL(string: "\(UnsplashEndPoint.baseURL)/photos/\(id)")
        case .photoURL(let url, let width):
            return URL(string: "\(url)/&w=\(width)&fit=max")
        case .searchPhotos(let page, let perPage, let query):
            return URL(string: "\(UnsplashEndPoint.baseURL)/search/photos?page=\(page)&per_page=\(perPage)&query=\(query)")
        case .randomPhoto:
            return URL(string: "\(UnsplashEndPoint.baseURL)/photos/random")
        }
    }
    
    var headers: HTTPHeaders? {
        ["Authorization": "Client-ID \(UnsplashApiKey.accessKey.rawValue)",
         "Content-Type": "application/json"]
    }

    var method: HTTPMethod {
        return .GET
    }
    
}

private extension UnsplashEndPoint {
    static let baseURL: String = "https://api.unsplash.com"
}
