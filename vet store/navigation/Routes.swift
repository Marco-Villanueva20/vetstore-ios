import UIKit

enum Route {
    case registroALogin
    case homeADetalle
    case loginARegistro
    case loginAHome
    // agrega más rutas aquí
}

struct Routes {
    static func navigate(to route: Route, from viewController: UIViewController) {
        switch route {
        case .registroALogin:
            viewController.performSegue(withIdentifier: "navegarRegistroALogin", sender: nil)
        case .homeADetalle:
            viewController.performSegue(withIdentifier: "navegarHomeADetalle", sender: nil)
        case .loginARegistro:
            viewController.performSegue(withIdentifier: "navegarLoginARegistro", sender: nil)
            
        case .loginAHome:
            viewController.performSegue(withIdentifier: "navegarLoginAHome", sender: nil)
            
        }
    }
}


