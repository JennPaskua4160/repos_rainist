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
    let userName = "JennPaskua4160"
    var user: User?
    var userRepos: [Repo] = [Repo]()
    
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
        
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.global().async {
            //user api
            self.requestUserInfo(username: self.userName) { [weak self] (data) in
                guard let `self` = self else { return }
                guard let userData = data else { return }
                self.user = userData
                
                group.leave()
            }
        }
        
        group.enter()
        DispatchQueue.global().async {
            //starred repo api
            self.fetchMyStarredRepo(pageId: self.pageId) { [weak self] (data) in
                guard let `self` = self else { return }
                guard let reposData = data else { return }
                self.userRepos = reposData
        
                group.leave()
            }
        }
      
        group.notify(queue: DispatchQueue.global()) {
            guard let user = self.user else { return }
            DispatchQueue.main.async {
                self.updateUI(userData: user, repoCount: self.userRepos.count)
            }
        }
    }
    
    //Pull To Refresh 생성 함수
    func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    //User 정보 리프레시
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
    
    // MARK: - starred repository list api
    func fetchMyStarredRepo(pageId: Int, completion: @escaping ([Repo]?) -> Void) {
        
        request(Router.starredRepository(username: self.userName, pageId: pageId)).responseJSON { response in
            guard response.result.isSuccess,
                let _ = response.result.value else {
                    print("Error while fetching repository: \(String(describing: response.result.error))")
                    completion(nil)
                    return
            }
            
            let jsonData = response.data
            
            do {
                let JSON = try JSONDecoder().decode([Repo].self, from: jsonData!)
                completion(JSON)
            }catch {
                print("Error while fetching JSONDecoding\(error)")
                completion(nil)
            }
        }
    }
}
