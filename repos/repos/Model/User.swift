//
//  User.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import Foundation

struct User: Codable {
    var avatarURL: URL?
    var name: String?
    var location: String?
    var blog: String?
    var email: String?
    var repos: Int
    var stars: Int
    var followers: Int
    var following: Int
    
    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
        case name
        case location
        case blog
        case email
        case repos = "public_repos"
        case stars = "public_gists"
        case followers
        case following
    }
}
