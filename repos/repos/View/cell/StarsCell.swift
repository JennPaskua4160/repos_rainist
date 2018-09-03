//
//  StarsCell.swift
//  repos
//
//  Created by Jean on 2018. 9. 1..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import UIKit

final class StarsCell: UITableViewCell {
    @IBOutlet var repoTitle: UILabel!
    @IBOutlet var repoSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.repoTitle.text = ""
        self.repoSubTitle.text = ""
    }
    
    func configure(cellData: Repo) {
        self.repoTitle.text = cellData.repoFullName
        self.repoSubTitle.text = cellData.description
    }
    
}
