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
    }
    

    
    
    @IBAction func btnRegistrarse(_ sender: UIButton) {
        Task {
               do {
                   let correo = leerCorreo()
                   let contrasena = leerContrasena()
                   let nombre = leerNombre()
                   
                   let usuario = Usuario(nombre: nombre, correo: correo, contrasena: contrasena)
                   
                   // Llamamos a tu servicio
                   let response = try await usuarioService.create(usuario)!
                   
                   Routes.navigate(to: .loginAHome, from: self)
                   
               } catch {
                   print("❌ Error al registrar: \(error.localizedDescription)")
                  // mostrarAlertaError(mensaje: "No se pudo crear el usuario, revisa los datos.")
               }
           }
        
    }
    
    
    
    @IBAction func btnVolver(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

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
    
    
    
}
