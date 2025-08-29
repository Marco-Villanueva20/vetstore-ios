//
//  Pedido.swift
//  vet store
//
//  Created by Jacktter on 22/08/25.
//

import UIKit

struct DetallePedido {
    var codigo: Int16?
    var cantidad: Int16
    var precioTotal: Double
    var genero: String
    var estado: String?
    
    var usuarioUuid: String
    var mascota: Mascota?
}


