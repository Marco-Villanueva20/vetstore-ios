import UIKit
import CoreData

class DetallePedidoService: NSObject {
    private let contextoBD: NSManagedObjectContext
    
    override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.contextoBD = delegate.persistentContainer.viewContext
    }
    
    // CREATE
    func addPedido(pedido: DetallePedido) -> DetallePedido? {
        let entity = DetallePedidoEntity(context: contextoBD)

        do {
            // Asignar código y campos básicos
            entity.codigo = try CoreDataHelper.generarNuevoCodigo(
                entidad: "DetallePedidoEntity",
                context: contextoBD
            )
            entity.cantidad = pedido.cantidad
            entity.precio_total = pedido.precioTotal
            entity.genero = pedido.genero
            
            // Relación con Mascota
            if let mascotaData = pedido.mascota {
                let request = MascotaEntity.fetchRequest()
                request.predicate = NSPredicate(format: "codigo == %d", mascotaData.codigo)
                
                if let mascotaExistente = try contextoBD.fetch(request).first {
                    entity.mascota = mascotaExistente
                } else {
                    print("Error: No se encontró la mascota con código \(mascotaData.codigo)")
                    return nil
                }
            }
            
            try contextoBD.save()
            
            // Retornar el objeto mapeado
            return mapEntityToPedido(entity)
            
        } catch {
            print("Error al guardar pedido: \(error.localizedDescription)")
            return nil
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
            return entities.map { mapEntityToPedido($0) }  // Usar función de mapeo
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
                return mapEntityToPedido(entity)   // Usar función de mapeo
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
                
                try contextoBD.save()
                
                // Retornar el objeto actualizado como modelo
                return mapEntityToPedido(entity)
            }
        } catch {
            print("Error al actualizar pedido: \(error.localizedDescription)")
        }
        
        return nil
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
            mascota: mascotaData
        )
    }

}
