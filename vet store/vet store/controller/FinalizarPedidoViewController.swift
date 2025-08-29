//
//  FinalizarPedidoViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class FinalizarPedidoViewController: UIViewController {

    
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblCorreo: UILabel!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtFechaEntrega: UITextField!
    @IBOutlet weak var txtDireccionEntrega: UITextField!
    
    @IBOutlet weak var lblRaza: UILabel!
    @IBOutlet weak var lblCantidadPedida: UILabel!
    @IBOutlet weak var txtTotal: UILabel!
    
    var detallePedido: DetallePedido?
    var usuarioResponse: UsuarioResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            self.usuarioResponse = await UsuarioService.usuarioLogueado()
            print("Usuario cargado: \(self.usuarioResponse?.nombre ?? "Sin nombre")")
            
            // imprimir luego de obtener al usuario
            await MainActor.run {
                self.imprimirDatos()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func obtenerDireccionDeEntrega() -> String {
            return txtDireccionEntrega.text ?? ""
        }
        
        func obtenerFechaDeEntrega() -> String {
            return txtFechaEntrega.text ?? ""
        }
        
        func imprimirDatos() {
            // ✅ Manejo seguro de valores opcionales
            lblRaza.text = detallePedido?.mascota?.raza ?? "Sin mascota"
            lblCorreo.text = usuarioResponse?.correo ?? "Sin correo"
            lblCantidadPedida.text = String(detallePedido?.cantidad ?? 0)
            lblNombre.text = usuarioResponse?.nombre ?? "Sin nombre"
        }
    

    @IBAction func btnFinalizarPedido(_ sender: UIButton) {
        guard let detallePedido = detallePedido else {
                    print("⚠️ No hay detallePedido disponible")
                    return
                }
                
                let finalizarPedido = FinalizarPedido(
                    usuarioUuid: usuarioResponse?.uuid,
                    nombreUsuario: usuarioResponse?.nombre ?? "Desconocido",
                    correoUsuario: leerCorreo(),
                    fechaEntrega: obtenerFechaDeEntrega(),
                    direccion: obtenerDireccionDeEntrega()
                )
                
                // ✅ Evitamos crash si codigo es nil
                guard let codigo = detallePedido.codigo else {
                    print("⚠️ detallePedido no tiene código")
                    return
                }
                
                let detallePedidoEntity = DetallePedidoService()
                    .obtenerDetallePedidoEntity(codigo: codigo)
                
                if FinalizarPedidoService().addFinalizarPedido(pedido: finalizarPedido, detallePedido: detallePedidoEntity) {
                    print("✅ FinalizarPedido creado con éxito")
                    Routes.navigate(to: .finalizarPedidoAHome, from: self)
                } else {
                    print("❌ Error al crear FinalizarPedido")
                }
            }
    
    func leerCorreo()-> String {
        return lblCorreo.text!
    }

}
