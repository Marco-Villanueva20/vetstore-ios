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
        
        if let urlString = finalizarPedido?.pedido?.mascota?.foto,
                  let url = URL(string: urlString) {
                   ivFoto.sd_setImage(with: url, placeholderImage: UIImage(named: "producto_icon"))
               } else {
                   ivFoto.image = UIImage(named: "producto_icon")
               }
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func btnActualizar(_ sender: UIButton) {
        
        // 0) Asegurarnos que venga el objeto
               guard finalizarPedido != nil else {
                   AlertHelper.showAlert(on: self, title: "Atención", message: "No hay pedido cargado para actualizar.")
                   return
               }
               
               // 1) Validar campos no vacíos (según tu petición)
               let nombre = txtNombreUsuario.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
               let correo = txtCorreoUsuario.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
               let direccion = txtDireccionUsuario.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
               let fecha = txtFechaEntrega.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
               
               if nombre.isEmpty {
                   AlertHelper.showAlert(on: self, title: "Atención", message: "El nombre no puede estar vacío.")
                   return
               }
               if correo.isEmpty {
                   AlertHelper.showAlert(on: self, title: "Atención", message: "El correo no puede estar vacío.")
                   return
               }
               if direccion.isEmpty {
                   AlertHelper.showAlert(on: self, title: "Atención", message: "La dirección no puede estar vacía.")
                   return
               }
               if fecha.isEmpty {
                   AlertHelper.showAlert(on: self, title: "Atención", message: "La fecha de entrega no puede estar vacía.")
                   return
               }
               
               // 2) Confirmación antes de actualizar
               AlertHelper.showConfirmation(on: self,
                                            title: "Confirmación",
                                            message: "¿Deseas actualizar los datos del pedido?",
                                            confirmTitle: "Sí",
                                            cancelTitle: "No") { [weak self] in
                   guard let self = self else { return }
                   
                   // 3) Sobrescribir objeto en memoria
                   self.finalizarPedido.nombreUsuario = nombre
                   self.finalizarPedido.correoUsuario = correo
                   self.finalizarPedido.direccion = direccion
                   self.finalizarPedido.fechaEntrega = fecha
                   
                   // 4) Llamar al service para guardar cambios
                   let service = FinalizarPedidoService()
                   let actualizado = service.updateFinalizarPedido(pedido: self.finalizarPedido)
                   
                   // 5) Mostrar resultado y navegar de regreso si fue OK
                   if actualizado {
                       let alert = UIAlertController(title: "Éxito", message: "Datos actualizados correctamente.", preferredStyle: .alert)
                       alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
                           // Navegar de regreso a la lista (usa tu ruta)
                           //Routes.navigate(to: .modificarDatosAPedidos, from: self)
                           self.view.window?.rootViewController?.dismiss(animated: true)
                       }))
                       self.present(alert, animated: true)
                   } else {
                       AlertHelper.showAlert(on: self, title: "Error", message: "No se pudo actualizar el pedido. Intenta de nuevo.")
                   }
               }
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
