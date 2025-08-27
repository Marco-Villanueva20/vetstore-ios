import UIKit
import CoreData

class PedidoService: NSObject {
    private let contextoBD: NSManagedObjectContext
    
    override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.contextoBD = delegate.persistentContainer.viewContext
    }
    
    // CREATE
    func addPedido(pedido: Pedido) -> Bool {
        let entity = PedidoEntity(context: contextoBD)
    
        do {
            entity.codigo = try CoreDataHelper.generarNuevoCodigo(
                entidad: "PedidoEntity",
                context: contextoBD
            )
            entity.cantidad = pedido.cantidad
            entity.precio_total = pedido.precioTotal
            
            try contextoBD.save()
            return true
        } catch {
            print("Error al guardar pedido: \(error.localizedDescription)")
            return false
        }
    }
    
    // READ ALL
    func getPedidos() -> [Pedido] {
        var pedidos: [Pedido] = []
        do {
            let request = PedidoEntity.fetchRequest()
            let entities = try contextoBD.fetch(request)
            
            pedidos = entities.map { entity in
                Pedido(
                    codigo: entity.codigo,
                    cantidad: entity.cantidad,
                    precioTotal: entity.precio_total
                )
            }
        } catch {
            print("Error al obtener pedidos: \(error.localizedDescription)")
        }
        return pedidos
    }
    
    // READ by codigo
    func getPedido(byCodigo codigo: Int16) -> Pedido? {
        let request = PedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                return Pedido(
                    codigo: entity.codigo,
                    cantidad: entity.cantidad,
                    precioTotal: entity.precio_total
                )
            }
        } catch {
            print("Error al buscar pedido: \(error.localizedDescription)")
        }
        return nil
    }
    
    // UPDATE
    func updatePedido(pedido: Pedido) -> Bool {
        let request = PedidoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", pedido.codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                entity.cantidad = pedido.cantidad
                entity.precio_total = pedido.precioTotal
                try contextoBD.save()
                return true
            }
        } catch {
            print("Error al actualizar pedido: \(error.localizedDescription)")
        }
        return false
    }
    
    // DELETE
    func deletePedido(byCodigo codigo: Int16) -> Bool {
        let request = PedidoEntity.fetchRequest()
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
}
