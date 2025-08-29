//
//  ModificarDatosViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class ModificarDatosViewController: UIViewController {

    var finalizarPedido: FinalizarPedido!
    
    
    @IBOutlet weak var txtNombreUsuario: UITextField!
    @IBOutlet weak var txtCorreoUsuario: UITextField!
    @IBOutlet weak var txtDireccionUsuario: UITextField!
    @IBOutlet weak var txtFechaEntrega: UITextField!
    @IBOutlet weak var ivFoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtNombreUsuario.text = finalizarPedido.nombreUsuario
        txtCorreoUsuario.text = finalizarPedido.correoUsuario
        txtDireccionUsuario.text = finalizarPedido.direccion
        txtFechaEntrega.text = finalizarPedido.fechaEntrega
        
        if let url = URL(string: finalizarPedido.pedido?.mascota?.foto ?? "") {
            ivFoto.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "producto_icon")
            )
        }
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func btnActualizar(_ sender: UIButton) {
        
        // Actualizar objeto en memoria
           finalizarPedido.nombreUsuario = obtenerNombreUsuario()
           finalizarPedido.correoUsuario = obtenerCorreoUsuario()
           finalizarPedido.direccion = obtenerDireccionUsuario()
           finalizarPedido.fechaEntrega = obtenerFechaEntrega()
           
           // Llamar al service para guardar cambios
           let service = FinalizarPedidoService()
           let actualizado = service.updateFinalizarPedido(pedido: finalizarPedido)
           
           if actualizado {
               print("✅ Pedido actualizado correctamente")
               mostrarAlerta(mensaje: "Datos actualizados con éxito")
               Routes.navigate(to: .modificarDatosAPedidos, from: self)
           } else {
               print("❌ Error al actualizar pedido")
               mostrarAlerta(mensaje: "No se pudo actualizar el pedido")
           }
        
    }
    
    func mostrarAlerta(mensaje: String) {
        let alert = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func obtenerNombreUsuario() -> String {
        return txtNombreUsuario.text ?? ""
    }
    func obtenerCorreoUsuario() -> String {
        return txtCorreoUsuario.text ?? ""
    }
    
    func obtenerDireccionUsuario() -> String {
        return txtDireccionUsuario.text ?? ""
    }
    
    func obtenerFechaEntrega() -> String {
        return txtFechaEntrega.text ?? ""
    }
    
    
    
    

}
