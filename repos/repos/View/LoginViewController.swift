//
//  LoginViewController.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import OAuthSwift

final class LoginViewController: UIViewController {
    
    @IBOutlet var loginButton: UIButton!
    var disposeBag: DisposeBag = DisposeBag()
    
    let githubOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey:    "7afe09c3db5cf1a8a63f",
        consumerSecret: "6f8184f66b46b2e1088bbd313efb3f4daab60ca2",
        authorizeUrl:   "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
        responseType:   "code"
    )
    
    var token: String? {
        get {
            let token = UserDefaults.standard.string(forKey: "tokenKey")
            return token
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "tokenKey")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton
            .rx
            .tap
            .flatMap {
                self.requestToken()
            }.subscribe(onNext: { (token) in
                self.token = token
                self.performSegue(withIdentifier: "profileViewSegue", sender: self)
            }, onError: { (error) in
                print("error while clicking loginButton")
            }).disposed(by: disposeBag)
    }
    
    func requestToken() -> Observable<String> {
        
        return Observable<String>.create {(observer) -> Disposable in
            self.githubOAuth.authorize(withCallbackURL: URL(string: "reposApp://oauth-callback/github")!, scope: "user,repo", state: "state",
                                       success: { (credential, _, _) in
                                        let oauthToken = credential.oauthToken
                                        observer.onNext(oauthToken)
                                        observer.onCompleted()
            },
                                       failure: { (error) in
                                        observer.onError(error)
            })
            return Disposables.create {}
        }
    }


}

