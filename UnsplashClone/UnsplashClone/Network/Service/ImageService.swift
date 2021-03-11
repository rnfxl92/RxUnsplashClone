//
//  ImageService.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/16.
//

import UIKit

final class ImageService: ImageServicing {
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    func imageURL(endPoint: EndPointType, completion: @escaping (Result<UIImage?, NetworkError>) -> Void) {
        guard let url = endPoint.url  else {
            completion(.failure(.urlNotSupport))
            return
        }
        
        if let cachedImage = imageCache.object(forKey: url.lastPathComponent as NSString) {
            completion(.success(cachedImage))
            return
        }
        
        imageURLFromServer(endPoint: endPoint) { [weak self] result in
            switch result {
            case .success(let image):
                guard let image = image else {
                    completion(.failure(.imageError))
                    return
                }
                self?.imageCache.setObject(image, forKey: url.lastPathComponent as NSString)
                completion(.success(image))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    func imageURLFromServer(endPoint: EndPointType, completion: @escaping (Result<UIImage?, NetworkError>) -> Void) {
        
        guard let url = endPoint.url else {
            completion(.failure(.urlNotSupport))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
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
            
            guard let image = UIImage(data: data) else {
                completion(.failure(.imageError))
                return
            }
            
            completion(.success(image))
        }
        
        task.resume()
    }
    
    func removeCache() {
        imageCache.removeAllObjects()
    }
}
