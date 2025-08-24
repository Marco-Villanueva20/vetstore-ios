import UIKit

enum Route {
    //login
    case loginARegistro
    case loginAHome
    
    //registro
    case registroALogin

    //pedidos
    case pedidosADetallePedido
    case detallePedidoAModificarDatos
    //home
    case homeADetallePedidoCar
    case detallePedidoCarAFinalizarPedido

}

struct Routes {
    static func navigate(to route: Route, from viewController: UIViewController) {
        switch route {
        case .loginARegistro:
            viewController.performSegue(withIdentifier: "loginARegistro", sender: nil)
        case .loginAHome:
            viewController.performSegue(withIdentifier: "loginAHome", sender: nil)
        case .registroALogin:
            viewController.performSegue(withIdentifier: "registroALogin", sender: nil)
        case .pedidosADetallePedido:
            viewController.performSegue(withIdentifier: "pedidosADetallePedido", sender: nil)
        case .detallePedidoAModificarDatos:
            viewController.performSegue(withIdentifier: "detallePedidoAModificarDatos", sender: nil)
        case .homeADetallePedidoCar:
            viewController.performSegue(withIdentifier: "homeADetallePedidoCar", sender: nil)
        case .detallePedidoCarAFinalizarPedido:
        }
    }
}


