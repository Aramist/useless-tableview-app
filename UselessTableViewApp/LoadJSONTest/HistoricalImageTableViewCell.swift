//
//  HistoricalImageTableViewCell.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/10/21.
//

import UIKit

class HistoricalImageTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var historicalImage: UIImageView!
    @IBOutlet weak var imageDescription: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
