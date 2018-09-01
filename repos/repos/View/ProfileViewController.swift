//
//  ProfileViewController.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

final class ProfileViewController: UIViewController {
    let username = "JennPaskua4160"
    
    @IBOutlet var userThumbnail: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var blog: UILabel!
    @IBOutlet var email: UILabel!
    
    @IBOutlet var repositories: UILabel!
    @IBOutlet var stars: UILabel!
    @IBOutlet var followers: UILabel!
    @IBOutlet var followings: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.setupPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //TODO: user Api 요청할 때 UI그리는 속도개선필요.
        self.requestUserInfo(username: self.username) { [weak self] (data) in
            guard let `self` = self else { return }
            guard let userData = data else { return }
            self.updateUI(userData: userData)
        }
    }
    
    //Pull To Refresh 생성 함수
    func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    //User 정보 리프레시해주는 부분
    @objc func didPullToRefresh() {
        self.requestUserInfo(username: self.username) { [weak self] (data) in
            guard let `self` = self else { return }
            guard let userData = data else { return }
            self.updateUI(userData: userData)
        }
        refreshControl?.endRefreshing()
    }
    
    
    //User 정보 화면에 그려주는 부분
    func updateUI(userData: User) {
        self.userThumbnail.layer.borderColor = UIColor.darkGray.cgColor
        self.userThumbnail.layer.cornerRadius = self.userThumbnail.frame.height/2
        self.userThumbnail.clipsToBounds = true
        self.userThumbnail.kf.setImage(with: userData.avatarURL)
        
        self.userName.text = userData.name ?? ""
        self.address.text = userData.location ?? ""
        self.blog.text = userData.blog ?? ""
        self.email.text = userData.email ?? ""
        self.repositories.text = "\(userData.repos)"
        self.stars.text = "\(userData.stars)"
        self.followers.text = "\(userData.followers)"
        self.followings.text = "\(userData.following)"
    }
    
    // MARK: - User api 호출하는 함수
    func requestUserInfo(username: String, completion: @escaping (User?) -> Void) {
        
        request(Router.user(username: username)).responseJSON { response in
            guard response.result.isSuccess,
                let _ = response.result.value else {
                    print("Error while fetching userList: \(String(describing: response.result.error))")
                    completion(nil)
                    return
            }
            
            let jsonData = response.data
            
            do{
                let JSON = try JSONDecoder().decode(User.self, from: jsonData!)
                completion(JSON)
            } catch{
                print("error \(error)")
                completion(nil)
            }
        }
    }
}
