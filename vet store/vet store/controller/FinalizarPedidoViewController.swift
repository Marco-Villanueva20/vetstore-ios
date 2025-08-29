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
    @IBOutlet weak var txtDiaEntrega: UITextField!
    
    
    @IBOutlet weak var txtMesEntrega: UITextField!
    
    @IBOutlet weak var txtAnioEntrega: UITextField!
    
    
    @IBOutlet weak var txtDireccionEntrega: UITextField!
    
    @IBOutlet weak var lblRaza: UILabel!
    @IBOutlet weak var lblCantidadPedida: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    
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
    
    // MARK: - Lectura / Formateo
      func obtenerDireccionDeEntrega() -> String {
          return txtDireccionEntrega.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
      }

      func obtenerFechaDeEntrega() -> String {
          let d = txtDiaEntrega.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
          let m = txtMesEntrega.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
          let y = txtAnioEntrega.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
          return "\(d)/\(m)/\(y)"
      }

      // Pone valores iniciales en UI (si existen). NO limpiamos labels que vienen de la vista anterior.
      func imprimirDatos() {
          lblRaza.text = detallePedido?.mascota?.raza ?? "Sin mascota"
          lblCorreo.text = usuarioResponse?.correo ?? "Sin correo"
          lblCantidadPedida.text = String(detallePedido?.cantidad ?? 0)
          lblNombre.text = usuarioResponse?.nombre ?? "Sin nombre"
          
          // Campos que sí deben quedar vacíos para que el usuario ingrese
          txtDireccionEntrega.text = ""
          txtDiaEntrega.text = ""
          txtMesEntrega.text = ""
          txtAnioEntrega.text = ""
          
          lblTotal.text = String(format: "%.2f", detallePedido?.precioTotal ?? 0.0)
      }
    
    @IBAction func btnFinalizarPedido(_ sender: UIButton) {
        // 0) Asegurar detallePedido existe
        guard let detalle = detallePedido else {
            AlertHelper.showAlert(on: self, title: "Atención", message: "No hay pedido seleccionado.")
            return
        }
        
        // 1) Dirección
        let direccion = obtenerDireccionDeEntrega()
        guard !direccion.isEmpty else {
            AlertHelper.showAlert(on: self, title: "Atención", message: "Por favor ingresa una dirección de entrega.")
            return
        }
        
        // 2) Fecha: validar componentes numéricos y que formen una fecha válida (dd/mm/yyyy)
        switch ValidationHelper.parseInt(txtDiaEntrega.text, nombreCampo: "Día") {
        case .failure(let err):
            AlertHelper.showAlert(on: self, title: "Atención", message: err.mensaje); return
        case .success(let dia):
            if !(1...31).contains(dia) {
                AlertHelper.showAlert(on: self, title: "Atención", message: "Día inválido."); return
            }
        }
        
        switch ValidationHelper.parseInt(txtMesEntrega.text, nombreCampo: "Mes") {
        case .failure(let err):
            AlertHelper.showAlert(on: self, title: "Atención", message: err.mensaje); return
        case .success(let mes):
            if !(1...12).contains(mes) {
                AlertHelper.showAlert(on: self, title: "Atención", message: "Mes inválido."); return
            }
        }
        
        switch ValidationHelper.parseInt(txtAnioEntrega.text, nombreCampo: "Año") {
        case .failure(let err):
            AlertHelper.showAlert(on: self, title: "Atención", message: err.mensaje); return
        case .success(let anio):
            if anio < 1900 || anio > 3000 {
                AlertHelper.showAlert(on: self, title: "Atención", message: "Año inválido."); return
            }
        }
        
        // Validación extra: fecha válida (ej. no 31/02) y no en el pasado
        guard let fechaValida = validarFecha(diaTxt: txtDiaEntrega.text, mesTxt: txtMesEntrega.text, anioTxt: txtAnioEntrega.text) else {
            AlertHelper.showAlert(on: self, title: "Atención", message: "La fecha de entrega no es válida.")
            return
        }
        
        // Opcional: evitar fechas en el pasado
        let hoy = Calendar.current.startOfDay(for: Date())
        if fechaValida < hoy {
            AlertHelper.showAlert(on: self, title: "Atención", message: "La fecha de entrega no puede ser anterior a hoy.")
            return
        }
        
        // 3) Correo: usar el correo que viene del usuario logueado (dato confiable)
        let correoAsignado = usuarioResponse?.correo ?? lblCorreo.text ?? ""
        guard !correoAsignado.isEmpty else {
            // Aunque dijiste que es seguro, nos defendemos por si hay inconsistencia en runtime.
            AlertHelper.showAlert(on: self, title: "Atención", message: "El usuario no tiene correo asociado.")
            return
        }
        
        // 4) Confirmación con el usuario antes de guardar
        let mensajeConfirm = """
             Confirma los datos:
             Usuario: \(usuarioResponse?.nombre ?? "Desconocido")
             Correo: \(correoAsignado)
             Fecha: \(obtenerFechaDeEntrega())
             Dirección: \(direccion)
             """
        AlertHelper.showConfirmation(on: self, title: "Confirmar pedido", message: mensajeConfirm, confirmTitle: "Finalizar", cancelTitle: "Cancelar") {
            // Guardar en Core Data (obtener entidad detallePedido antes)
            guard let codigoPedido = detalle.codigo else {
                AlertHelper.showAlert(on: self, title: "Atención", message: "El pedido no tiene código.")
                return
            }
            
            let detallePedidoEntity = DetallePedidoService().obtenerDetallePedidoEntity(codigo: codigoPedido)
            let finalizarPedido = FinalizarPedido(
                usuarioUuid: self.usuarioResponse?.uuid,
                nombreUsuario: self.usuarioResponse?.nombre ?? "Desconocido",
                correoUsuario: correoAsignado,
                fechaEntrega: self.obtenerFechaDeEntrega(),
                direccion: direccion,
                pedido: detalle
            )
            
            let ok = FinalizarPedidoService().addFinalizarPedido(pedido: finalizarPedido, detallePedido: detallePedidoEntity)
            if ok {
                let alert = UIAlertController(title: "Éxito", message: "Pedido finalizado con éxito.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
                    // Cierra flow y vuelve al Home
                    self.view.window?.rootViewController?.dismiss(animated: true)

                }))
                self.present(alert, animated: true)
            } else {
                AlertHelper.showAlert(on: self, title: "Error", message: "No se pudo finalizar el pedido. Intenta de nuevo.")
            }
        }
    }
    
    
    // MARK: - Utilidades privadas
    
    // Valida que dd/mm/yyyy forme una fecha válida y devuelve Date si ok
    private func validarFecha(diaTxt: String?, mesTxt: String?, anioTxt: String?) -> Date? {
        guard let d = Int(diaTxt ?? ""),
              let m = Int(mesTxt ?? ""),
              let y = Int(anioTxt ?? "") else { return nil }
        
        var comps = DateComponents()
        comps.year = y
        comps.month = m
        comps.day = d
        comps.hour = 0
        comps.minute = 0
        
        return Calendar.current.date(from: comps)
    }
    
    
    @IBAction func btnFinalizarMasTarde(_ sender: UIButton) {
        AlertHelper.showConfirmation(
               on: self,
               title: "Finalizar más tarde",
               message: "¿Estás seguro de que deseas finalizar más tarde?",
               confirmTitle: "Sí, más tarde",
               cancelTitle: "No"
           ) {
               self.view.window?.rootViewController?.dismiss(animated: true)
           }
        
        
    }
    
    
    
}
