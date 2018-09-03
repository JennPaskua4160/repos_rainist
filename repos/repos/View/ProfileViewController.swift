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
    
    var userName: String? {
        get {
            let userName = UserDefaults.standard.string(forKey: "userName")
            return userName
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userName")
        }
    }
    
    @IBOutlet var userThumbnail: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var blog: UILabel!
    @IBOutlet var email: UILabel!
    
    @IBOutlet var repositoriesTitle: UILabel!
    @IBOutlet var starsTitle: UILabel!
    @IBOutlet var followersTitle: UILabel!
    @IBOutlet var followingTitle: UILabel!
    
    @IBOutlet var repositories: UILabel!
    @IBOutlet var stars: UILabel!
    @IBOutlet var followers: UILabel!
    @IBOutlet var followings: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    var refreshControl: UIRefreshControl!
    var pageId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.setupPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchUserAndRepoData()
    }
    
    // MARK: - User api 와 Repo api 호출 후 화면에 업데이트하는 함수
    
    func fetchUserAndRepoData() {
        
        //user api
        self.requestUserInfo() { [weak self] (userData) in
            guard
                let `self` = self,
                let userData = userData,
                let userName = userData.login
            else { return }
            
            //userDefaults에 userName저장
            self.userName = userName
            
            //starred repo api
            self.fetchMyStarredRepo(userName: self.userName ?? "",
                                    pageId: self.pageId) { [weak self] (repoData) in
                                        guard
                                            let `self` = self,
                                            let repoData = repoData
                                        else { return }
                                        
                                        self.updateUI(userData: userData, repoCount: repoData.count)
            }
        }
    }
    
    //Pull To Refresh 생성 함수
    func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    //UserAndRepo 정보 리프레시
    @objc func didPullToRefresh() {
        self.fetchUserAndRepoData()
        refreshControl?.endRefreshing()
    }
    
    //User 정보 화면에 그려주는 부분
    func updateUI(userData: User, repoCount: Int) {
        
        self.userThumbnail.layer.borderColor = UIColor.darkGray.cgColor
        self.userThumbnail.layer.cornerRadius = self.userThumbnail.frame.height/2
        self.userThumbnail.clipsToBounds = true
        self.userThumbnail.kf.setImage(with: userData.avatarURL)
        
        self.name.text = userData.name ?? ""
        self.address.text = userData.location ?? ""
        self.blog.text = userData.blog ?? ""
        self.email.text = userData.email ?? ""
        
        self.repositoriesTitle.text = "Repositories"
        self.starsTitle.text = "Stars"
        self.followersTitle.text = "Followers"
        self.followingTitle.text = "Following"
        
        self.repositories.text = "\(userData.repos)"
        self.stars.text = "\(repoCount)"
        self.followers.text = "\(userData.followers)"
        self.followings.text = "\(userData.following)"
        
    }
    
    // MARK: - User api 호출하는 함수
    
    func requestUserInfo(completion: @escaping (User?) -> Void) {
        
        request(Router.user()).responseJSON { response in
            
            guard
                response.result.isSuccess,
                let _ = response.result.value
            else {
                    print("Error while fetching user: \(String(describing: response.result.error))")
                    completion(nil)
                    return
            }
            
            let jsonData = response.data
            
            do {
                let JSON = try JSONDecoder().decode(User.self, from: jsonData!)
                completion(JSON)
            } catch {
                print("error \(error)")
                completion(nil)
            }
        }
    }
    
    // MARK: - starred repository list api
    
    func fetchMyStarredRepo(userName: String,
                            pageId: Int,
                            completion: @escaping ([Repo]?) -> Void) {
        
        request(Router.starredRepository(username: userName,
                                         pageId: pageId)).responseJSON { response in
                                            
                                            guard
                                                response.result.isSuccess,
                                                let _ = response.result.value
                                            else {
                                                    print("Error while fetching repository count: \(String(describing: response.result.error))")
                                                    completion(nil)
                                                    return
                                            }
                                            
                                            let jsonData = response.data
                                            
                                            do {
                                                let JSON = try JSONDecoder().decode([Repo].self, from: jsonData!)
                                                completion(JSON)
                                            } catch {
                                                print("Error while fetching JSONDecoding\(error)")
                                                completion(nil)
                                            }
        }
    }
}
