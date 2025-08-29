//
//  DetallePedidoCarViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class DetallePedidoCarViewController: UIViewController {
    
    var detallePedido: DetallePedido!
    
    @IBOutlet weak var lblRaza: UILabel!
    
    @IBOutlet weak var lblPrecioUnitario: UILabel!
    
    @IBOutlet weak var txtCantidadPedido: UITextField!

    @IBOutlet weak var lblCantMachos: UILabel!
    
    @IBOutlet weak var lblCantHembras: UILabel!
    
    @IBOutlet weak var txtGeneroPedido: UITextField!
    
    var usuarioResponse: UsuarioResponse!
    
    
    @IBOutlet weak var ivFoto: UIImageView!
    
    
    var mascota:Mascota!

    override func viewDidLoad() {
        super.viewDidLoad()
        mostrarDatosMascota()
        cargarUsuarioResponse() // <- asegura el usuario antes de pedir
    }

       
    func mostrarDatosMascota() {
        lblRaza.text = mascota.raza
        lblCantMachos.text = "Machos: \(mascota.cantidadMachos)"
        lblCantHembras.text = "Hembras: \(mascota.cantidadHembras)"
        lblPrecioUnitario.text = "S/ \(mascota.precio)" // ejemplo con formato de precio
        
        // Convertir el string en URL y asignar imagen
        if let url = URL(string: mascota.foto) {
            ivFoto.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "producto_icon") // se muestra mientras carga
            )
        } else {
            // Si el string no era URL válido
            ivFoto.image = UIImage(named: "producto_icon")
        }
    }

       
    @IBAction func btnRealizarPedido(_ sender: UIButton) {
        // 1️⃣ Validar cantidad (int > 0)
        switch ValidationHelper.parseInt(txtCantidadPedido.text, nombreCampo: "Cantidad") {
        case .failure(let error):
            AlertHelper.showAlert(on: self, title: "Atención", message: error.mensaje)
            return
        case .success(let cantidadInt) where cantidadInt > 0:
            break
        default:
            AlertHelper.showAlert(on: self, title: "Atención", message: "La cantidad debe ser mayor a 0.")
            return
        }
        
        // 2️⃣ Validar género (Macho/Hembra)
        switch ValidationHelper.parseString(txtGeneroPedido.text, nombreCampo: "Género", valoresPermitidos: ["Macho", "Hembra"]) {
        case .failure(let error):
            AlertHelper.showAlert(on: self, title: "Atención", message: error.mensaje)
            return
        case .success(let generoValidado):
            // 3️⃣ Construir DetallePedido provisional (con mascota actual)
            let cantidadInt = Int(txtCantidadPedido.text ?? "0") ?? 0
            let detalle = DetallePedido(
                cantidad: Int16(cantidadInt),
                precioTotal: obtenerPrecioTotal(),
                genero: generoValidado,
                usuarioUuid: usuarioResponse.uuid,
                mascota: mascota
            )
            
            // 4️⃣ Llamar al service (throws)
            do {
                let pedidoCreado = try DetallePedidoService().addPedido(pedido: detalle)
                // éxito: actualizar referencia y navegar
                self.detallePedido = pedidoCreado
                Routes.navigate(to: .detallePedidoCarAFinalizarPedido, from: self)
                
            } catch let error as PedidoError {
                // error conocido con mensaje amigable
                AlertHelper.showAlert(on: self, title: "Atención", message: error.mensaje)
            } catch {
                // error inesperado
                AlertHelper.showAlert(on: self, title: "Atención", message: "Ocurrió un error inesperado.")
                print("Error inesperado addPedido: \(error)")
            }
        }
    }
    
    
    
    @IBAction func btnCancelar(_ sender: UIButton) {
        AlertHelper.showConfirmation(
                on: self,
                title: "Cancelar pedido",
                message: "¿Estás seguro de que deseas cancelar este pedido?",
                confirmTitle: "Sí, cancelar",
                cancelTitle: "No"
            ) {
                // Acción cuando confirma cancelar
                self.dismiss(animated: true)
            }
    }
    
    

        /// Función para mostrar alertas
        func mostrarAlerta(mensaje: String) {
            let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detallePedidoCarAFinalizarPedido" {
            let destino = segue.destination as! FinalizarPedidoViewController
            destino.detallePedido = self.detallePedido
        }
    }

    
        
        /// Lee el precio mostrado en el label `lblPrecio` y lo devuelve como Double
        func leerPrecio() -> Double {
            guard let texto = lblPrecioUnitario.text else { return 0.0 }
            // Quitar "S/ " si existe y convertir a Double
            let limpio = texto.replacingOccurrences(of: "S/ ", with: "")
            return Double(limpio) ?? 0.0
        }
        
        /// Lee la raza de la mascota desde el label `lblRaza`
        func leerRaza() -> String {
            return lblRaza.text ?? ""
        }
        
    func leerGenero() -> String {
        return txtGeneroPedido.text ?? ""
    }
    func leerCantidadPedido() -> Int16 {
        return Int16(txtCantidadPedido.text ?? "0") ?? 0
    }

    
    func obtenerPrecioTotal() -> Double {
        return Double(leerCantidadPedido()) * leerPrecio()
    }
    
    
    func cargarUsuarioResponse(){
        Task {
            usuarioResponse = await UsuarioService.usuarioLogueado()
            await MainActor.run {
                
            }
        }
    }
}
