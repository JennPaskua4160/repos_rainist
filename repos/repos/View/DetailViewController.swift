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
    @IBOutlet var starsCount: UILabel!
    @IBOutlet var starsButton: UIButton!
    
    var detailRepo: Repo? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        guard let detailRepo = detailRepo else { return }
        
        if let repoTitle = repoTitle,
            let repoSubTitle = repoSubTitle,
            let starsCount = starsCount {
            
            repoTitle.text = detailRepo.repoFullName
            repoSubTitle.text = detailRepo.description
            starsCount.text = "\(detailRepo.starsCount)"
            title = detailRepo.repoFullName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.starsButton.backgroundColor = .lightGray
        self.starsButton.layer.cornerRadius = 5
        
        configureView()
    }
    
    @IBAction func starsButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.putStars()
        } else {
            self.deleteStars()
        }
    }
    
    // MARK: - starring repo api
    func putStars() {
    }
    // MARK: - unstarring repo api
    func deleteStars() {
    }
}






