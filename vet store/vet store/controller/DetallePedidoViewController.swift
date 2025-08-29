//
//  DetallePedidoViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class DetallePedidoViewController: UIViewController {

    var finalizarPedido: FinalizarPedido!
    
    @IBOutlet weak var ivFoto: UIImageView!
    
    
    @IBOutlet weak var lblRaza: UILabel!
    
    @IBOutlet weak var lblCantidadPedida: UILabel!
    
    @IBOutlet weak var lblPrecioTotal: UILabel!
    
    @IBOutlet weak var lblNombreUsuario: UILabel!
    
    @IBOutlet weak var lblCorreo: UILabel!
    
    @IBOutlet weak var lblDireccion: UILabel!
    
    @IBOutlet weak var lblFechaEntrega: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imprimirDatos()
        // Do any additional setup after loading the view.
    }
    
    func imprimirDatos(){
        
        lblRaza.text = finalizarPedido.pedido?.mascota?.raza ?? "Sin raza"
        lblCantidadPedida.text = "\(finalizarPedido.pedido?.cantidad ?? 0)"
        lblPrecioTotal.text = "\(finalizarPedido.pedido?.precioTotal ?? 0.0)"
        
        if let url = URL(string: finalizarPedido.pedido?.mascota?.foto ?? "") {
            ivFoto.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "producto_icon")
            )
        }
        
        
        lblNombreUsuario.text = finalizarPedido.nombreUsuario
        lblCorreo.text = finalizarPedido.correoUsuario
        lblDireccion.text = finalizarPedido.direccion
        lblFechaEntrega.text = finalizarPedido.fechaEntrega
        
        
        
    }
    
    
    
    @IBAction func btnEditar(_ sender: UIButton) {
        Routes.navigate(to: .detallePedidoAModificarDatos, from: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "detallePedidoAModificarDatos" {
                let modificarDatos = segue.destination as! ModificarDatosViewController
                modificarDatos.finalizarPedido = finalizarPedido
            }
        }

    @IBAction func btnVolver(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

}
