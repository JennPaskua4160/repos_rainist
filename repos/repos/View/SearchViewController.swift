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
        self.createSearchBar()
        self.hideKeyboardWhenTappedAround()
        
        //Todo: 현재 알파벳 하나씩 Repository api 호출하여 테이블뷰 갱신하도록 구현
        self.searchBar
            .rx
            .text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                guard let `self` = self else { return }
                //respositories 함수 호출 필요
            })
    }
    
    //SearchBar 만드는 함수
    func createSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.returnKeyType = UIReturnKeyType.done
        self.searchBar.placeholder = "Search repository issue"
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
