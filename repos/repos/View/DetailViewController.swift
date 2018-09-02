//
//  DetailViewController.swift
//  repos
//
//  Created by Jean on 2018. 9. 1..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import UIKit
import Alamofire

final class DetailViewController: UIViewController {
    
    @IBOutlet var repoTitle: UILabel!
    @IBOutlet var repoSubTitle: UILabel!
    @IBOutlet var starsCountTitle: UILabel!
    @IBOutlet var starsButton: UIButton!
    
    var starCount: Int = 0 {
        didSet {
            self.starsCountTitle.text = "\(starCount)"
        }
    }

    var detailRepo: Repo? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        guard let detailRepo = detailRepo else { return }
        
        if let repoTitle = repoTitle,
            let repoSubTitle = repoSubTitle,
            let starsCountTitle = starsCountTitle {
            
            repoTitle.text = detailRepo.repoFullName
            repoSubTitle.text = detailRepo.description
            starsCountTitle.text = "\(detailRepo.starsCount)"
            
            title = detailRepo.repoFullName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.checkIfStarredRepos()
        self.getRepos { (data) in
            self.starCount = data?.starsCount ?? 0
        }
    }
    
    @IBAction func starsButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.putStars()
        } else {
            self.deleteStars()
        }
    }
    
    func getRepos(completion: @escaping (Repo?) -> Void ) {
        guard let detailRepo = detailRepo else { return }
        
        request(Router.getRepos(owner: detailRepo.owner.login,
                                repo: detailRepo.repoName)).responseJSON { response in
                                    
                                    guard response.result.isSuccess,
                                        let _ = response.result.value else {
                                            print("Error while fetching repository: \(String(describing: response.result.error))")
                                            completion(nil)
                                            return
                                    }
                                    
                                    let jsonData = response.data
                                    
                                    do {
                                        let JSON = try JSONDecoder().decode(Repo.self, from: jsonData!)
                                        completion(JSON)
                                    }catch {
                                        print("Error while fetching JSONDecoding\(error)")
                                        completion(nil)
                                    }
        }
    }
    
    func checkIfStarredRepos() {
        guard let detailRepo = detailRepo else { return }
        
        request(Router.checkStarredRepos(owner: detailRepo.owner.login,
                                         repo: detailRepo.repoName)).response { response in
                                            
                                            switch (response.response?.statusCode) {
                                            case 204:
                                                self.starsButton.isSelected = true
                                                return
                                            case 404:
                                                self.starsButton.isSelected = false
                                                return
                                            case .none, .some(_):
                                                return
                                            }
        }
    }
    
    // MARK: - starring repo api
    
    func putStars() {
        
        request(Router.star(owner: self.detailRepo?.owner.login ?? "",
                            repo: self.detailRepo?.repoName ?? "")).response { response in
                                
                                switch (response.response?.statusCode) {
                                case 204:
                                    //화면에 바로 카운팅이 증가하도록 수정
                                    //TODO: back button 눌렀다가 돌아왔을 때 starCount 5초 후 갱신되고 있음.
                                    self.starCount = self.starCount + 1
                                case 404:
                                    print("error while put star")
                                    return
                                case .none, .some(_):
                                    return
                                }
        }
    }
    
    // MARK: - unstarring repo api
    
    func deleteStars() {
        
        request(Router.unStar(owner: self.detailRepo?.owner.login ?? "",
                              repo: self.detailRepo?.repoName ?? "")).response { response in
                                
                                switch (response.response?.statusCode) {
                                case 204:
                                    //화면에 바로 카운팅이 증가하도록 수정
                                    //TODO: back button 눌렀다가 돌아왔을 때 starCount 5초 후 갱신되고 있음.
                                    self.starCount = self.starCount - 1
                                    return
                                case 404:
                                    print("error while delete star")
                                    return
                                case .none, .some(_):
                                    return
                                }
        }
    }
}






