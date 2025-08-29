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
    
    
    
    @IBOutlet weak var ivFoto: UIImageView!
    
    
    var mascota:Mascota!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mostrarDatosMascota()
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
        // Validar datos antes de continuar
            guard let cantidad = Int16(txtCantidadPedido.text ?? ""), cantidad > 0 else {
                mostrarAlerta(mensaje: "Por favor ingresa una cantidad válida mayor a 0.")
                return
            }
            
            guard let genero = txtGeneroPedido.text, !genero.isEmpty else {
                mostrarAlerta(mensaje: "Debes ingresar el género del pedido (Macho o Hembra).")
                return
            }
            
            // Validación opcional: solo permitir "Macho" o "Hembra"
            let generoValido = ["Macho", "Hembra"]
            guard generoValido.contains(genero.capitalized) else {
                mostrarAlerta(mensaje: "El género debe ser 'Macho' o 'Hembra'.")
                return
            }
            
            detallePedido = DetallePedido(
                cantidad: cantidad,
                precioTotal: obtenerPrecioTotal(),
                genero: genero.capitalized,
                mascota: mascota
            )
        

            if let pedidoCreado = DetallePedidoService().addPedido(pedido: detallePedido) {
                print("Pedido creado con éxito: \(pedidoCreado)")
                detallePedido = pedidoCreado
                
                // Navegar al siguiente paso: Finalizar Pedido
                Routes.navigate(to: .detallePedidoCarAFinalizarPedido, from: self)
            } else {
                print("Error al crear pedido")
                mostrarAlerta(mensaje: "Hubo un error al registrar tu pedido. Inténtalo nuevamente.")
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
}
