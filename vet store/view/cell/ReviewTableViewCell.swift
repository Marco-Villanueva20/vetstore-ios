//
//  ClienteTableViewCell 2.swift
//  vet store
//
//  Created by Jacktter on 26/08/25.
//


import UIKit

class ClienteTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ivFoto: UIImageView!
    @IBOutlet weak var lblExperiencias: UILabel!
    @IBOutlet weak var lblNombre: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}