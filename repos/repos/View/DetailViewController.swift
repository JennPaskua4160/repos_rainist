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
    
    var reposCount: Int = 0 {
        didSet {
            self.starsCountTitle.text = "\(reposCount)"
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
            self.reposCount = detailRepo.starsCount
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
    }
    
    @IBAction func starsButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.starsButton.isSelected = true
            self.putStars()
            self.reposCount = self.reposCount + 1
        } else {
            self.starsButton.isSelected = false
            self.deleteStars()
            self.reposCount = self.reposCount - 1
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
                            repo: self.detailRepo?.repoName ?? "")).responseJSON { response in
                                
                                guard response.result.error == nil else {
                                    print("error calling PUT on current repo")
                                    if let error = response.result.error {
                                        print("Error: \(error)")
                                    }
                                    return
                                }
        }
    }
    
    // MARK: - unstarring repo api
    
    func deleteStars() {
        
        request(Router.unStar(owner: self.detailRepo?.owner.login ?? "",
                              repo: self.detailRepo?.repoName ?? "")).responseJSON { response in
                                
                                guard response.result.error == nil else {
                                    print("error calling DELETE on current repo")
                                    if let error = response.result.error {
                                        print("Error: \(error)")
                                    }
                                    return
                                }
        }
    }
}






