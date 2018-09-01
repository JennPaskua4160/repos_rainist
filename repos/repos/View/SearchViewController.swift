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
    @IBOutlet var table: UITableView!
    
    let disposeBag: DisposeBag = DisposeBag()
    var repos: [Repo] = [Repo]()
    var totalCount: Int = 0
    var pageId: Int = 1
    var query: String = ""
    var currentSorting: String = "stars" {
        didSet {
            self.updateAfterGetData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createSearchBar()
        self.hideKeyboardWhenTappedAround()
        
        //알파벳 하나씩 입력할 때마다 Repository api 호출하여 테이블뷰 갱신하도록 구현
        self.searchBar
            .rx
            .text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                guard let `self` = self else { return }
                self.query = query.lowercased()
                
                self.updateAfterGetData()
                
            }).disposed(by: disposeBag)
        
        self.starsButton
            .rx
            .tap
            .subscribe({ _ in
                self.currentSorting = "stars"
            }).disposed(by: disposeBag)
        
        self.forksButton
            .rx
            .tap
            .subscribe({ _ in
                self.currentSorting = "forks"
            }).disposed(by: disposeBag)
        
        self.updateButton
            .rx
            .tap
            .subscribe({ _ in
                self.currentSorting = "updates"
            }).disposed(by: disposeBag)
    }
    
    //SearchBar 만드는 함수
    func createSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.returnKeyType = UIReturnKeyType.done
        self.searchBar.placeholder = "Search repository issue"
    }
    
    func updateAfterGetData() {
        //함수 호출 전 기존에 저장되어있던 repos 데이터 삭제
        self.repos.removeAll()
        //respositories 함수 호출
        self.fetchRepositories(query: self.query,
                               sort: self.currentSorting,
                               pageId: self.pageId,
                               completion: { [weak self] (data) in
                                guard let `self` = self else { return }
                                guard let reposData = data else { return }
                                self.totalCount = reposData.totalCount
                                
                                for item in reposData.items {
                                    self.repos.append(item)
                                }
                                
                                self.table.reloadData()
        })
    }
    
    func fetchRepositories(query: String,
                           sort: String,
                           pageId: Int,
                           completion: @escaping (Repos?) -> Void) {
        request(Router.repository(query, sort, pageId)).responseJSON { response in
            
            guard response.result.isSuccess,
                let _ = response.result.value else {
                    print("Error while fetching repository: \(String(describing: response.result.error))")
                    completion(nil)
                    return
            }
            
            let jsonData = response.data
            
            do {
                let JSON = try JSONDecoder().decode(Repos.self, from: jsonData!)
                completion(JSON)
            }catch {
                print("Error while fetching JSONDecoding\(error)")
                completion(nil)
            }
        }
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        let buttonArray = [self.starsButton, self.forksButton, self.updateButton]
        buttonArray.forEach{
            $0?.isSelected = false
        }
        sender.isSelected = true
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !self.repos.isEmpty else { return 0 }
        return self.repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReposCellID", for: indexPath) as? ReposCell else { return UITableViewCell() }
        guard !self.repos.isEmpty else { return UITableViewCell() }
        
        cell.configure(cellData: self.repos[indexPath.row])
        
        return cell
    }
}

// MARK: - UISearchBar 델리게이트 추가
extension SearchViewController: UISearchBarDelegate {
    //done버튼 눌렀을 때 키보드 사라지게 하는 함수
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    //화면 탭하면 키보드 사라지게 하는 함수
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(SearchViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
}
