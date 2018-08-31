//
//  ReposCell.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import UIKit
import Kingfisher

final class ReposCell: UITableViewCell {

    @IBOutlet var squareIcon: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var arrowIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.squareIcon.backgroundColor = .green
        self.title.text = "title"
        self.subTitle.text = "subTitle"
    }

    func configure(cellData: Repo) {
        self.title.text = cellData.repoFullName
        self.subTitle.text = cellData.description
    }

}
