//
//  StarsViewController.swift
//  repos
//
//  Created by Jean on 2018. 9. 1..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import UIKit
import Alamofire

final class StarsViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    let username: String = "JennPaskua4160"
    var pageId: Int = 1
    var repos: [Repo] = [Repo]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.updateAfterGetStarredRepo()
    }
    
    //Pull To Refresh 생성 함수
    func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.table.addSubview(refreshControl)
    }
    
    //Repo 정보 리프레시해주는 부분
    @objc func didPullToRefresh() {
        self.pageId = 1
        self.repos.removeAll()
        self.updateAfterGetStarredRepo()
        refreshControl?.endRefreshing()
    }
    
    func updateAfterGetStarredRepo() {
        self.fetchMyStarredRepo() { [weak self] (data) in
            guard let `self` = self else { return }
            guard let reposData = data else { return }
            
            self.repos = reposData
            self.title = "My Starred Repos [\(self.repos.count)]"
            self.table.reloadData()
        }
    }
    
    // MARK: - starred repository list api
    func fetchMyStarredRepo(completion: @escaping ([Repo]?) -> Void) {
        
        request(Router.starredRepository(username: self.username, pageId: self.pageId)).responseJSON { response in
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension StarsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !self.repos.isEmpty else { return 0 }
        return self.repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StarsCellID", for: indexPath) as? StarsCell else { return UITableViewCell() }
        guard !self.repos.isEmpty else { return UITableViewCell() }
        
        cell.configure(cellData: self.repos[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
