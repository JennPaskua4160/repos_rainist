//
//  Model.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import Foundation

struct User: Codable {
    var avatarURL: URL?
    var login: String?
    var name: String?
    var location: String?
    var blog: String?
    var email: String?
    var repos: Int
    var followers: Int
    var following: Int
    
    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
        case login
        case name
        case location
        case blog
        case email
        case repos = "public_repos"
        case followers
        case following
    }
}

struct Repos: Decodable {
    var totalCount: Int
    var items: [Repo]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

struct Owner: Codable {
    var login: String
}

struct Repo: Codable {
    var owner: Owner
    var repoName: String
    var repoFullName: String
    var description: String?
    var starsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case owner
        case repoName = "name"
        case repoFullName = "full_name"
        case description
        case starsCount = "stargazers_count"
    }
}

