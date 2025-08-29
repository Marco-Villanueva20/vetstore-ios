import UIKit
import CoreData

class FinalizarPedidoService: NSObject {
    private let contextoBD: NSManagedObjectContext
    
    override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.contextoBD = delegate.persistentContainer.viewContext
    }
    
    // READ by codigo y opcional usuario_uuid
    func getFinalizarPedido(byCodigo codigo: Int16, usuarioUuid: String? = nil) -> FinalizarPedido? {
        let request = FinalizarPedidoEntity.fetchRequest()
        
        if let uuid = usuarioUuid {
            // Usuario normal → codigo + uuid
            request.predicate = NSPredicate(format: "codigo == %d AND usuario_uuid == %@", codigo, uuid)
        } else {
            // Administrador → solo por codigo
            request.predicate = NSPredicate(format: "codigo == %d", codigo)
        }
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                return mapEntityToFinalizarPedido(entity)
            }
        } catch {
            print("Error al buscar finalizar pedido: \(error.localizedDescription)")
        }
        return nil
    }

    
    // READ by usuario_uuid
    func getFinalizarPedidos(byUsuarioUuid uuid: String) -> [FinalizarPedido] {
        let request = FinalizarPedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "usuario_uuid == %@", uuid)
        
        do {
            let entities = try contextoBD.fetch(request)
            return entities.map { mapEntityToFinalizarPedido($0) }
        } catch {
            print("Error al obtener pedidos del usuario: \(error.localizedDescription)")
            return []
        }
    }

    
    // CREATE
    func addFinalizarPedido(pedido: FinalizarPedido, detallePedido: DetallePedidoEntity?) -> Bool {
        let entity = FinalizarPedidoEntity(context: contextoBD)
        
        do {
            // Generar código autoincremental
            entity.codigo = try CoreDataHelper.generarNuevoCodigo(
                entidad: "FinalizarPedidoEntity",
                context: contextoBD
            )
            entity.usuario_uuid = pedido.usuarioUuid
            entity.nombre_usuario = pedido.nombreUsuario
            entity.correo_usuario = pedido.correoUsuario
            entity.fecha_entrega = pedido.fechaEntrega
            entity.direccion = pedido.direccion
            
            // Relación con DetallePedido
            if let detalle = detallePedido {
                entity.detalle_pedido = detalle
                detalle.estado = "finalizado"
            } else {
                print("⚠️ Advertencia: No se asignó detalle_pedido")
            }
            
            try contextoBD.save()
            return true
        } catch {
            print("Error al guardar finalizar pedido: \(error.localizedDescription)")
            return false
        }
    }
    
    // READ ALL
    func getFinalizarPedidos() -> [FinalizarPedido] {
        do {
            let request = FinalizarPedidoEntity.fetchRequest()
            let entities = try contextoBD.fetch(request)
            return entities.map { mapEntityToFinalizarPedido($0) }
        } catch {
            print("Error al obtener finalizar pedidos: \(error.localizedDescription)")
            return []
        }
    }
    
    // READ by codigo
    func getFinalizarPedido(byCodigo codigo: Int16) -> FinalizarPedido? {
        let request = FinalizarPedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                return mapEntityToFinalizarPedido(entity)
            }
        } catch {
            print("Error al buscar finalizar pedido: \(error.localizedDescription)")
        }
        return nil
    }
    
    // UPDATE
    func updateFinalizarPedido(pedido: FinalizarPedido) -> Bool {
        let request = FinalizarPedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", pedido.codigo!)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                entity.nombre_usuario = pedido.nombreUsuario
                entity.correo_usuario = pedido.correoUsuario
                entity.direccion = pedido.direccion
                entity.fecha_entrega = pedido.fechaEntrega
                try contextoBD.save()
                return true
            }
        } catch {
            print("Error al actualizar finalizar pedido: \(error.localizedDescription)")
        }
        return false
    }
    
    // DELETE
    func deleteFinalizarPedido(byCodigo codigo: Int16) -> Bool {
        let request = FinalizarPedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                contextoBD.delete(entity)
                try contextoBD.save()
                return true
            }
        } catch {
            print("Error al eliminar finalizar pedido: \(error.localizedDescription)")
        }
        return false
    }
    
    
    private func mapEntityToFinalizarPedido(_ entity: FinalizarPedidoEntity) -> FinalizarPedido {
        var detalleMapped: DetallePedido? = nil
        
        if let detalleEntity = entity.detalle_pedido {
            // 👇 Usa mapEntityToPedido en vez de mapEntityToDetallePedido
            detalleMapped = DetallePedidoService().getPedido(byCodigo: detalleEntity.codigo)
            // o directo, si quieres evitar ir a BD otra vez:
            // detalleMapped = DetallePedidoService().mapEntityToPedido(detalleEntity)
        }
        
        return FinalizarPedido(
            codigo: entity.codigo,
            usuarioUuid: entity.usuario_uuid ?? "",
            nombreUsuario: entity.nombre_usuario ?? "",
            correoUsuario: entity.correo_usuario ?? "",
            fechaEntrega: entity.fecha_entrega ?? "",
            direccion: entity.direccion ?? "",
            pedido: detalleMapped
        )
    }

}
