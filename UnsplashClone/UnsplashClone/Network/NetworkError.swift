//
//  NetworkError.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/13.
//

import Foundation

enum NetworkError: Error {
    case urlNotSupport
    case networkError(error: String)
    case invalidResponse(statusCode: Int)
    case invalidData
    case parsingFailed
    case imageError
    
    var errorDescription: String? {
        switch self {
        case .urlNotSupport:
            return "URL NOT Supported"
        case .invalidData:
            return "Invalid Data"
        case .networkError(let error):
            return "NetworkError \(error)"
        case .invalidResponse(let statusCode):
            return "InvalidResponse ErrorCode: \(statusCode)"
        case .parsingFailed:
            return "JSON Parsing Failed"
        case .imageError:
            return "Image Download Error"
        }
    }
    
}
