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
    var isLoading: Bool = false
    var query: String = ""
    var currentSorting: String = "stars" {
        didSet {
            //함수 호출 전 기존에 저장되어있던 repos 데이터 삭제
            self.repos.removeAll()
            // 쿼리문 업데이트 시 repository api 호출
            self.updateAfterGetRepo()
        }
    }
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createSearchBar()
        self.hideKeyboardWhenTappedAround()
        self.setupPullToRefresh()
        //searchBar에 알파벳 입력시 Repository api 호출
        self.searchBar
            .rx
            .text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                guard let `self` = self else { return }
                self.query = query.lowercased()
                //함수 호출 전 기존에 저장되어있던 repos 데이터 삭제
                self.repos.removeAll()
                self.updateAfterGetRepo()
            }).disposed(by: disposeBag)
        
        //체크박스버튼 눌릴 때 sort쿼리값 변경
        self.starsButton.isSelected = true
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
    
    //Pull To Refresh 생성 함수
    func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.table.addSubview(refreshControl)
    }
    
    //Repo 정보 리프레시
    @objc func didPullToRefresh() {
        self.pageId = 1
        //함수 호출 전 기존에 저장되어있던 repos 데이터 삭제
        self.repos.removeAll()
        self.updateAfterGetRepo()
        refreshControl?.endRefreshing()
    }
    
    // MARK: - repos 데이터 업데이트 및 테이블뷰 갱신
    func updateAfterGetRepo() {
        self.isLoading = true
        self.fetchRepositories(query: self.query,
                               sort: self.currentSorting,
                               pageId: self.pageId,
                               completion: { [weak self] (data) in
                                guard let `self` = self else { return }
                                guard let reposData = data else { return }
                                
                                self.totalCount = reposData.totalCount
                                
                                reposData.items.forEach {
                                    self.repos.append( $0 )
                                }
                                
                                self.isLoading = false
                                self.table.reloadData()
        })
    }
    
    // MARK: - repository api 통신
    func fetchRepositories(query: String,
                           sort: String,
                           pageId: Int,
                           completion: @escaping (Repos?) -> Void) {
        request(Router.repository(query: query, sorting: sort, pageId: pageId)).responseJSON { response in
            
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
    
    //체크박스버튼 눌리면 나머지 버튼 select 해제해주는 액션
    @IBAction func buttonClicked(_ sender: UIButton) {
        let buttonArray = [self.starsButton, self.forksButton, self.updateButton]
        
        buttonArray.forEach {
            $0?.isSelected = false
        }
        
        sender.isSelected = true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.repos.count - 1) {
            if !isLoading, self.repos.count < self.totalCount {
                
                //loadMoreIndicator 마지막셀에 추가
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                self.table.tableFooterView = spinner
                self.table.tableFooterView?.isHidden = false
               
                //페이징에 1카운트 추가 후에 repo 함수 호출 
                self.pageId = self.pageId + 1
                self.updateAfterGetRepo()
                
            }
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail" else { return }
        guard let indexPath = table.indexPathForSelectedRow else { return }
        guard !self.repos.isEmpty else { return }
        
        if let controller = segue.destination as? DetailViewController {
            controller.detailRepo = self.repos[indexPath.row]
        }
    }
}

// MARK: - UISearchBarDelegate
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
