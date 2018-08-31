//
//  Router.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import Foundation
import Alamofire

public enum Router: URLRequestConvertible {
    enum Constants {
        static let baseUrlString: String = "https://api.github.com"
    }
    
    case user(String)
    case repository(String, Int)
    
    var path: String {
        switch self {
        case .user(let username):
            return "users/\(username)"
        case .repository:
            return "search/repositories"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var url: URL {
        let url = try! Constants.baseUrlString.asURL()
        return url.appendingPathComponent(path)
    }
    
    var parameters: [String: Any] {
        switch self {
        case .user:
            return [:]
        case .repository(let query, let pageID):
            return ["page": pageID, "per_page": 20, "q": "\(query)+language:Swift"]
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
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
}
