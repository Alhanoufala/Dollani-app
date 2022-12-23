//
//  CustomTableViewCell.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 29/05/1444 AH.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var sendHelp: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
