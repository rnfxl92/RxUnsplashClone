//
//  Photo.swift
//  UnsplashClone
//
//  Created by 박성민 on 2021/02/13.
//

import Foundation
import RxDataSources

class Photo: Codable, IdentifiableType {
    let id: String
    let photoURLs: PhotoURLs
    let username: String
    let width: Int
    let height: Int
    let sponsored: Bool
    var identity: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        photoURLs = try container.decode(PhotoURLs.self, forKey: .photoURLs)
        username = try container.decode(User.self, forKey: .username).name
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        sponsored = try !container.decodeNil(forKey: .sponsored)
        identity = id
    }
}

extension Photo: Hashable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private extension Photo {
    enum CodingKeys: String, CodingKey {
        case id
        case photoURLs = "urls"
        case username = "user"
        case width
        case height
        case sponsored = "sponsorship"
    }
}

struct SearchedPhoto: Codable {
    let results: [Photo]
}
