//
//  PhotoServicing.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/13.
//

import Foundation

protocol PhotoServicing {
    func request<T: Codable>(dataType: T.Type, endPoint: EndPointType, completion: @escaping ((Result<T, NetworkError>) -> Void))
    
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, NetworkError>) -> Void)
    
    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], NetworkError>) -> Void)
    
    func fetchSearchedPhotos(page: Int, perPage: Int, query: String, completion: @escaping (Result<SearchedPhoto, NetworkError>) -> Void)
    
    func fetchRandomPhoto(completion: @escaping (Result<Photo, NetworkError>) -> Void)
}

extension PhotoServicing {
    func request<T: Codable>(dataType: T.Type, endPoint: EndPointType, completion: @escaping ((Result<T, NetworkError>) -> Void)) {
        guard let url = endPoint.url else {
            completion(.failure(.urlNotSupport))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method.rawValue
        request.allHTTPHeaderFields = endPoint.headers
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.networkError(error: error.localizedDescription)))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                guard 200..<300 ~= response.statusCode else {
                    completion(.failure(.invalidResponse(statusCode: response.statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(dataType.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.parsingFailed))
            }
        }
        task.resume()
    }
}
