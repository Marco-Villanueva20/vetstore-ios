//
//  RegistroViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class RegistroViewController: UIViewController {

    let usuarioService = UsuarioService()
    
    
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    @IBOutlet weak var txtConfirmarContrasena: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // campo de contraseña
        txtContrasena.isSecureTextEntry = true
        txtConfirmarContrasena?.isSecureTextEntry = true // si tienes confirmación

        // para mejor autocompletado por iOS
        txtContrasena.textContentType = .password
        txtConfirmarContrasena?.textContentType = .password
        txtCorreo.textContentType = .username
    }
    

    
    
    @IBAction func btnRegistrarse(_ sender: UIButton) {
        // Validaciones antes de llamar al servicio
                // 1) Nombre
                switch ValidationHelper.parseString(txtNombre.text, nombreCampo: "Nombre") {
                case .failure(let err):
                    AlertHelper.showAlert(on: self, title: "Error", message: err.mensaje)
                    return
                case .success(_):
                    break
                }
                
                // 2) Correo (no vacío + formato)
                let correo = txtCorreo.text ?? ""
                if correo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    AlertHelper.showAlert(on: self, title: "Error", message: "El correo no puede estar vacío.")
                    return
                }
                if !isValidEmail(correo) {
                    AlertHelper.showAlert(on: self, title: "Error", message: "Ingresa un correo electrónico válido.")
                    return
                }
                
                // 3) Contraseña y confirmación
                let contrasena = txtContrasena.text ?? ""
                let confirmar = txtConfirmarContrasena.text ?? ""
                
                if contrasena.isEmpty || confirmar.isEmpty {
                    AlertHelper.showAlert(on: self, title: "Error", message: "La contraseña y su confirmación no pueden estar vacías.")
                    return
                }
                if contrasena.count < 6 {
                    AlertHelper.showAlert(on: self, title: "Error", message: "La contraseña debe tener al menos 6 caracteres.")
                    return
                }
                if contrasena != confirmar {
                    AlertHelper.showAlert(on: self, title: "Error", message: "Las contraseñas no coinciden.")
                    return
                }
                
                // 4) Si todo ok, llamamos al servicio (async)
                let nombre = txtNombre.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let usuario = Usuario(nombre: nombre, correo: correo, contrasena: contrasena)
                
                // Opcional: deshabilitar botón / mostrar spinner (no implementado aquí)
                Task {
                    do {
                        // Asumo que create puede devolver Usuario? y lanzar -> si es diferente adapta la desestructuración
                        if let nuevoUsuario = try await usuarioService.create(usuario) {
                            print("✅ Usuario creado con nombre: \(nuevoUsuario.nombre)")
                            // Usar tu helper para mostrar éxito y navegar
                            AlertHelper.showSuccessAndNavigate(on: self, message: "Usuario registrado correctamente.", segueIdentifier: "registroALogin")
                        } else {
                            // Si el servicio devuelve nil en vez de lanzar error
                            AlertHelper.showAlert(on: self, title: "Error", message: "No se pudo crear el usuario. Intenta nuevamente.")
                        }
                    } catch {
                        // Mostrar mensaje de error proveniente del servicio
                        AlertHelper.showAlert(on: self, title: "Error", message: error.localizedDescription)
                    }
                }
        
    }
    
    
    
    @IBAction func btnVolver(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

    // MARK: - Lectura campos
      func leerNombre() -> String {
          return txtNombre.text ?? ""
      }
      
      func leerCorreo() -> String {
          return txtCorreo.text ?? ""
      }
      
      func leerContrasena() -> String {
          return txtContrasena.text ?? ""
      }
      
      func leerConfirmarContrasena() -> String {
          return txtConfirmarContrasena.text ?? ""
      }
      
      // MARK: - Util
      /// Validación simple de email con regex (suficiente para la mayoría de campos de formulario)
      private func isValidEmail(_ email: String) -> Bool {
          // regex sencillo y razonable
          let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
          let predicate = NSPredicate(format:"SELF MATCHES[c] %@", pattern)
          return predicate.evaluate(with: email)
      }
    
    
}
