//
//  Router.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import Foundation
import Alamofire

public enum Router {
    case user()
    case repository(query: String, sorting: String, pageId: Int)
    case starredRepository(username: String, pageId: Int)
    case checkStarredRepos(owner: String, repo: String)
    case getRepos(owner: String, repo: String)
    case star(owner: String, repo: String)
    case unStar(owner: String, repo: String)
}

extension Router: URLRequestConvertible {
    enum Constants {
        static let baseUrlString: String = "https://api.github.com"
    }
    
    var path: String {
        switch self {
        case .user:
            return "user"
        case .repository:
            return "search/repositories"
        case let .starredRepository(username, _):
            return "users/\(username)/starred"
        case let .checkStarredRepos(owner, repo):
            return "user/starred/\(owner)/\(repo)"
        case let .getRepos(owner, repo):
            return "repos/\(owner)/\(repo)"
        case let .star(owner, repo):
            return "user/starred/\(owner)/\(repo)"
        case let .unStar(owner, repo):
            return "user/starred/\(owner)/\(repo)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .user, .repository, .starredRepository, .checkStarredRepos, .getRepos:
            return .get
        case .star:
            return .put
        case .unStar:
            return .delete
        }
    }
    
    var url: URL {
        let url = try! Constants.baseUrlString.asURL()
        return url.appendingPathComponent(path)
    }
    
    var parameters: [String: Any] {
        switch self {
        case .user, .star, .unStar, .checkStarredRepos, .getRepos:
            return [:]
        case let .starredRepository(_, pageId):
            return ["page": pageId, "per_page": 100000 ]
        case let .repository(query , sorting, pageId):
            return [
                "q": ["language:swift", query],
                "sort": sorting,
                "page": pageId,
                "order": "asc"
            ]
        }
    }
    
    var defaultHeaders: HTTPHeaders {
        var headers: HTTPHeaders = [:]
        if let token = UserDefaults.standard.string(forKey: "tokenKey"), !token.isEmpty {
            headers["Authorization"] = "token \(token)"
        }
        return headers
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try Constants.baseUrlString.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = defaultHeaders
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        switch self {
        case .user, .starredRepository, .checkStarredRepos, .getRepos:
            return try URLEncoding.default.encode(request, with: parameters)
        case .repository:
            return try URLEncoding(arrayEncoding: .noBrackets).encode(request, with: parameters)
        case .star, .unStar:
            request.setValue("0", forHTTPHeaderField: "Content-Legth")
            return try JSONEncoding.default.encode(request, with: parameters)
        }
        
    }
}
