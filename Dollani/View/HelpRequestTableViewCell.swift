//
//  HelpRequestTableViewCell.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 30/05/1444 AH.
//

import UIKit

class HelpRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var VIProfilePhoto: UIImageView!
    @IBOutlet weak var helpRequestLabel: UILabel!
    @IBOutlet weak var videoCallButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        VIProfilePhoto?.layer.cornerRadius = (VIProfilePhoto?.frame.size.width ?? 0.0) / 2
        VIProfilePhoto?.clipsToBounds = true
        VIProfilePhoto?.layer.borderWidth = 3.0
        VIProfilePhoto?.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
