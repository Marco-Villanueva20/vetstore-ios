//
//  DetallePedidoTableViewCell.swift
//  vet store
//
//  Created by Jacktter on 29/08/25.
//

import UIKit

class PedidoPendienteTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var lblCodigo: UILabel!
    @IBOutlet weak var ivFoto: UIImageView!
    @IBOutlet weak var lblRaza: UILabel!
    @IBOutlet weak var lblPrecioTotal: UILabel!
    @IBOutlet weak var lblEstado: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
