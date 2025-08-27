//
//  MascotaTableViewCell.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class MascotaTableViewCell: UITableViewCell {
    @IBOutlet weak var lblRaza: UILabel!
    @IBOutlet weak var lblPrecio: UILabel!
    @IBOutlet weak var ivFoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
