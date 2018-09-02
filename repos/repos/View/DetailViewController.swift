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
    
    fileprivate let userName = "JennPaskua4160"
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
    
    // MARK: - starring repo api
    
    func putStars() {
        
        request(Router.star(owner: self.userName,
                            repo: "\(self.detailRepo?.repoFullName ?? "")")).responseJSON { response in
                                
            guard response.result.error == nil else {
                print("error calling PUT on current repo")
                if let error = response.result.error {
                    print("Error: \(error)")
                }
                return
            }
            
            print("PUT ok")
        }
    }
    // MARK: - unstarring repo api
    func deleteStars() {
        
        request(Router.unStar(owner: self.userName,
                              repo: "\(self.detailRepo?.repoFullName ?? "")")).responseJSON { response in
                                
            guard response.result.error == nil else {
                print("error calling DELETE on current repo")
                if let error = response.result.error {
                    print("Error: \(error)")
                }
                return
            }
            
            print("DELETE ok")
        }
    }
}






