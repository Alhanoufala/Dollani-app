//
//  AskForhelpTableViewCell.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 29/05/1444 AH.
//

import UIKit

class AskForhelpTableViewCell: UITableViewCell {

    @IBOutlet weak var askForHelpLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePic?.layer.cornerRadius = (profilePic?.frame.size.width ?? 0.0) / 2
        profilePic?.clipsToBounds = true
        profilePic?.layer.borderWidth = 3.0
        profilePic?.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
