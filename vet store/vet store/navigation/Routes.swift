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
    case modificarDatosAPedidos
    
    //home
    case homeADetallePedidoCar
    case detallePedidoCarAFinalizarPedido
    case homeALogin
    case homeAAgregarMascota
    case finalizarPedidoAHome
    
    //Review
    case reviewAAgregarReview
    case reviewADetalleReview
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
            viewController.performSegue(withIdentifier: "detallePedidoCarAFinalizarPedido", sender: nil)
        case .homeALogin:
            viewController.performSegue(withIdentifier: "homeALogin", sender: nil)
        case .homeAAgregarMascota:
            viewController.performSegue(withIdentifier: "homeAAgregarMascota", sender: nil)
        case .finalizarPedidoAHome:
            viewController.performSegue(withIdentifier: "finalizarPedidoAHome", sender: nil)
        case .modificarDatosAPedidos:
            viewController.performSegue(withIdentifier: "modificarDatosAPedidos", sender: nil)
        case .reviewAAgregarReview:
            viewController.performSegue(withIdentifier: "reviewAAgregarReview", sender: self)
        case .reviewADetalleReview:
            viewController.performSegue(withIdentifier: "reviewADetalleReview", sender: self)
        }
    }
}


