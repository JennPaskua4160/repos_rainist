//
//  SearchViewController.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

final class SearchViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var starsButton: UIButton!
    @IBOutlet var forksButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReposCellID", for: indexPath) as! ReposCell

        return cell
    }
    
    
}
