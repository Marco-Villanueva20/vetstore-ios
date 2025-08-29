import UIKit

class PedidoTableViewCell: UITableViewCell {
    
    weak var delegate: PedidoTableViewCellDelegate?
    
    @IBOutlet weak var lblCodigo: UILabel!
    @IBOutlet weak var lblRaza: UILabel!
    @IBOutlet weak var lblPrecioTotal: UILabel!
    
    @IBOutlet weak var ivFoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnVerDetalles(_ sender: UIButton) {
        delegate?.didTapComprar(in: self)
    }
    
}

protocol PedidoTableViewCellDelegate: AnyObject {
    func didTapComprar(in cell: PedidoTableViewCell)
}
