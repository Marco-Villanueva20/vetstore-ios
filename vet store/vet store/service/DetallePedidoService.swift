import UIKit
import CoreData

class DetallePedidoService: NSObject {
    private let contextoBD: NSManagedObjectContext
    
    override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.contextoBD = delegate.persistentContainer.viewContext
    }
    
    // CREATE -> lanza PedidoError si algo falla
    func addPedido(pedido: DetallePedido) throws -> DetallePedido {
        // 1) Validación mínima: debe tener mascota asociada
        guard let mascotaData = pedido.mascota else {
            throw PedidoError.sinMascota
        }

        // 2) Buscar MascotaEntity en Core Data por código
        let requestMascota: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
        requestMascota.predicate = NSPredicate(format: "codigo == %d", mascotaData.codigo)

        do {
            guard let mascotaExistente = try contextoBD.fetch(requestMascota).first else {
                throw PedidoError.mascotaNoEncontrada(mascotaData.codigo)
            }

            // 3) Validar stock según género
            let genero = pedido.genero.capitalized
            let cantidadPedidoInt = Int(pedido.cantidad)

            if genero == "Macho" {
                let stockMachos = Int(mascotaExistente.cantidad_machos)
                if cantidadPedidoInt > stockMachos {
                    throw PedidoError.stockInsuficiente("No puedes pedir más machos de los que hay en stock (\(stockMachos)).")
                }
            } else if genero == "Hembra" {
                let stockHembras = Int(mascotaExistente.cantidad_hembras)
                if cantidadPedidoInt > stockHembras {
                    throw PedidoError.stockInsuficiente("No puedes pedir más hembras de las que hay en stock (\(stockHembras)).")
                }
            } else {
                throw PedidoError.generoInvalido
            }

            // 4) Crear DetallePedidoEntity y asignar relación
            let entity = DetallePedidoEntity(context: contextoBD)
            entity.codigo = try CoreDataHelper.generarNuevoCodigo(entidad: "DetallePedidoEntity", context: contextoBD)
            entity.cantidad = pedido.cantidad
            entity.precio_total = pedido.precioTotal
            entity.genero = pedido.genero
            entity.mascota = mascotaExistente
            entity.estado = "pendiente"
            entity.usuario_uuid = pedido.usuarioUuid
            

            // 5) Restar stock en la mascota (en el mismo contexto)
            if genero == "Macho" {
                let nuevaCantidad = Int(mascotaExistente.cantidad_machos) - cantidadPedidoInt
                mascotaExistente.cantidad_machos = Int16(max(0, nuevaCantidad))
            } else {
                let nuevaCantidad = Int(mascotaExistente.cantidad_hembras) - cantidadPedidoInt
                mascotaExistente.cantidad_hembras = Int16(max(0, nuevaCantidad))
            }

            // 6) Guardar todo en Core Data (transacción atómica)
            try contextoBD.save()

            // 7) Retornar el DetallePedido mapeado
            return mapEntityToPedido(entity)

        } catch let pedidoError as PedidoError {
            // Re-lanzamos errores específicos
            throw pedidoError
        } catch {
            // Otros errores (Core Data, etc.)
            throw PedidoError.persistencia(error.localizedDescription)
        }
    }

    func obtenerDetallePedidoEntity(codigo: Int16) -> DetallePedidoEntity? {
        let request = DetallePedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            return try contextoBD.fetch(request).first
        } catch {
            print("Error al buscar DetallePedidoEntity: \(error.localizedDescription)")
            return nil
        }
    }

    // READ ALL
    func getPedidos() -> [DetallePedido] {
        do {
            let request = DetallePedidoEntity.fetchRequest()
            let entities = try contextoBD.fetch(request)
            return entities.map { mapEntityToPedido($0) }
        } catch {
            print("Error al obtener pedidos: \(error.localizedDescription)")
            return []
        }
    }

    // READ by codigo
    func getPedido(byCodigo codigo: Int16) -> DetallePedido? {
        let request = DetallePedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                return mapEntityToPedido(entity)
            }
        } catch {
            print("Error al buscar pedido: \(error.localizedDescription)")
        }
        return nil
    }

    // UPDATE
    func updatePedido(pedido: DetallePedido) -> DetallePedido? {
        let request = DetallePedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", pedido.codigo!)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                // Actualizar campos
                entity.cantidad = pedido.cantidad
                entity.genero = pedido.genero
                entity.precio_total = pedido.precioTotal
                entity.estado = pedido.estado
                entity.usuario_uuid = pedido.usuarioUuid
                
                try contextoBD.save()
                
                // Retornar el objeto actualizado como modelo
                return mapEntityToPedido(entity)
            }
        } catch {
            print("Error al actualizar pedido: \(error.localizedDescription)")
        }
        
        return nil
    }

    // GET pendientes (filtrables por usuario)
    func getPedidosPendientes(forUsuarioUuid uuid: String? = nil) -> [DetallePedido] {
        let request: NSFetchRequest<DetallePedidoEntity> = DetallePedidoEntity.fetchRequest()
        var predicates: [NSPredicate] = []
        // estado pendiente
        predicates.append(NSPredicate(format: "estado == %@", "pendiente"))
        // si se pasa uuid, agregar filtro
        if let u = uuid, !u.isEmpty {
            predicates.append(NSPredicate(format: "usuario_uuid == %@", u))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            let entities = try contextoBD.fetch(request)
            return entities.map { mapEntityToPedido($0) }
        } catch {
            print("Error al obtener pedidos pendientes: \(error.localizedDescription)")
            return []
        }
    }

    // DELETE
    func deletePedido(byCodigo codigo: Int16) -> Bool {
        let request = DetallePedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                contextoBD.delete(entity)
                try contextoBD.save()
                return true
            }
        } catch {
            print("Error al eliminar pedido: \(error.localizedDescription)")
        }
        return false
    }
    
    private func mapEntityToPedido(_ entity: DetallePedidoEntity) -> DetallePedido {
        let mascotaData: Mascota? = {
            if let m = entity.mascota {
                return Mascota(
                    codigo: m.codigo,
                    raza: m.raza ?? "",
                    precio: m.precio,
                    cantidadMachos: m.cantidad_machos,
                    cantidadHembras: m.cantidad_hembras,
                    foto: m.foto ?? ""
                )
            }
            return nil
        }()
        
        return DetallePedido(
            codigo: entity.codigo,
            cantidad: entity.cantidad,
            precioTotal: entity.precio_total,
            genero: entity.genero ?? "",
            estado: entity.estado ?? "pendiente",
            usuarioUuid: entity.usuario_uuid ?? "",
            mascota: mascotaData
        )
    }
}


/// Errores específicos para pedidos
enum PedidoError: Error {
    case sinMascota
    case mascotaNoEncontrada(Int16)
    case stockInsuficiente(String) // detalle ya formateado
    case generoInvalido
    case persistencia(String) // detalle del error interno

    var mensaje: String {
        switch self {
        case .sinMascota:
            return "No hay mascota asociada al pedido."
        case .mascotaNoEncontrada(let codigo):
            return "No se encontró la mascota con código \(codigo)."
        case .stockInsuficiente(let detalle):
            return detalle
        case .generoInvalido:
            return "Género inválido. Debe ser 'Macho' o 'Hembra'."
        case .persistencia(let detalle):
            return "Error interno al guardar el pedido: \(detalle)"
        }
    }
}
