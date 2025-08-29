import UIKit

class LoginViewController: UIViewController {
    
    let usuarioService = UsuarioService()

    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    
    override func viewDidLoad() {
        // campo de contraseña
        txtContrasena.isSecureTextEntry = true

        // para mejor autocompletado por iOS
        txtContrasena.textContentType = .password
        txtCorreo.textContentType = .username
        super.viewDidLoad()
    }
    
    
    @IBAction func btnIniciarSesion(_ sender: UIButton) {
        // 1) Validaciones locales ...
            let correo = leerCorreo().trimmingCharacters(in: .whitespacesAndNewlines)
            let contrasena = leerContrasena()
            guard !correo.isEmpty else { AlertHelper.showAlert(on: self, title: "Atención", message: "Por favor ingresa tu correo."); return }
            guard isValidEmail(correo) else { AlertHelper.showAlert(on: self, title: "Atención", message: "Ingresa un correo válido."); return }
            guard !contrasena.isEmpty else { AlertHelper.showAlert(on: self, title: "Atención", message: "Por favor ingresa tu contraseña."); return }
            guard contrasena.count >= 6 else { AlertHelper.showAlert(on: self, title: "Atención", message: "La contraseña debe tener al menos 6 caracteres."); return }

            // 2) Intentar iniciar sesión (async)
            Task { [weak self] in
                guard let self = self else { return }
                let usuarioRequest = UsuarioRequest(correo: correo, contrasena: contrasena)
                do {
                    let session = try await usuarioService.login(usuarioRequest)
                    print("Inicio de sesión exitoso: \(session)")

                    // Mostrar alerta y en el handler cambiar root (ejecutado en MainActor)
                    await MainActor.run {
                        let alert = UIAlertController(title: "Bienvenido", message: "Has iniciado sesión correctamente.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let sceneDelegate = scene.delegate as? SceneDelegate {
                                sceneDelegate.showMainTabBar()
                            }
                        }))
                        self.present(alert, animated: true)
                    }
                } catch {
                    let mensaje = (error as NSError).localizedDescription.isEmpty ? "Credenciales incorrectas o error de conexión." : (error as NSError).localizedDescription
                    await MainActor.run {
                        AlertHelper.showAlert(on: self, title: "Error", message: mensaje)
                    }
                }
            }
        }
    
    @IBAction func btnRegistro(_ sender: UIButton) {
        Routes.navigate(to: .loginARegistro, from: self)
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
       
       // MARK: - Utilidades
       
       private func isValidEmail(_ email: String) -> Bool {
           // Regex simple y suficiente para la mayoría de casos
           let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
           return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
       }
    
    
}
