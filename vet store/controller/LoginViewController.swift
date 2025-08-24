//
//  LoginViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    let usuarioService = UsuarioService()

    @IBOutlet weak var txtCorreo: UITextField!
    
    @IBOutlet weak var txtContrasena: UITextField!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func btnIniciarSesion(_ sender: UIButton) {
        Task {
                let correo = leerCorreo()
                let contrasena = leerContrasena()
                let usuarioRequest = UsuarioRequest(correo: correo, contrasena: contrasena)
                
                do {
                    let session = try await usuarioService.login(usuarioRequest)
                    print("Inicio de sesión exitoso: \(session)")
                    Routes.navigate(to: .loginAHome, from: self)
                    
                } catch {
                    print("Error al iniciar sesión: \(error.localizedDescription)")
                    //self.mostrarAlerta(mensaje: "Credenciales incorrectas o error de conexión")
                }
            }
        }
    
    @IBAction func btnRegistro(_ sender: UIButton) {
        performSegue(withIdentifier: "navegarDeLoginARegistro", sender: nil)
    }
    
    
    
    

    func leerCorreo() -> String {
        return txtCorreo.text ?? ""
    }
    
    func leerContrasena() -> String {
        return txtContrasena.text ?? ""
    }

    private func configurarTextField(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        
        // Padding interno
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    
}
