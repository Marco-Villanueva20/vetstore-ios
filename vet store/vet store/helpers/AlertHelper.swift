import UIKit

class AlertHelper {
    
    // Alerta simple
    static func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        viewController.present(alert, animated: true)
    }
    
    // Alerta de confirmación (Sí/No)
    static func showConfirmation(
        on viewController: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = "Aceptar",
        cancelTitle: String = "Cancelar",
        onConfirm: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { _ in
            onConfirm()
        }))
        viewController.present(alert, animated: true)
    }
    
    // Alerta de éxito con acción (navegar con segue)
    static func showSuccessAndNavigate(
        on viewController: UIViewController,
        message: String,
        segueIdentifier: String
    ) {
        let alert = UIAlertController(title: "Éxito", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Aceptar", style: .default) { _ in
            viewController.performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
        alert.addAction(action)
        viewController.present(alert, animated: true)
    }

    // Alerta de éxito con dismiss
    static func showSuccessAndDismiss(
        on viewController: UIViewController,
        message: String
    ) {
        let alert = UIAlertController(title: "Éxito", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Aceptar", style: .default) { _ in
            viewController.dismiss(animated: true)
        }
        alert.addAction(action)
        viewController.present(alert, animated: true)
    }

    
}
