//
//  ProfileViewController.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import UIKit

final class ProfileViewController: UIViewController {

    @IBOutlet var userThumbnail: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var blog: UILabel!
    @IBOutlet var email: UILabel!
    
    @IBOutlet var repositories: UILabel!
    @IBOutlet var stars: UILabel!
    @IBOutlet var followers: UILabel!
    @IBOutlet var followings: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Todos: user api 부르기
    }


}
