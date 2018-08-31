//
//  ReposCell.swift
//  repos
//
//  Created by Jean on 2018. 8. 31..
//  Copyright © 2018년 com.paskua.swift. All rights reserved.
//

import UIKit
import Kingfisher

class ReposCell: UITableViewCell {

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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
