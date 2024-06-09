//
//  searchTableViewCell.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/20.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var distributorLabel : UILabel!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var searchTableViewimageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
