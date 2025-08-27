import UIKit
import CoreData

class MascotaService: NSObject {
    private let contextoBD: NSManagedObjectContext
    
    override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.contextoBD = delegate.persistentContainer.viewContext
    }
    
    // CREATE
    func addMascota(mascota: Mascota) -> Bool {
        let entity = MascotaEntity(context: contextoBD)
        do {
                entity.codigo = try CoreDataHelper.generarNuevoCodigo(
                    entidad: "MascotaEntity",
                    context: contextoBD
                )
                entity.raza = mascota.raza
                entity.precio = mascota.precio
                entity.foto = mascota.foto
                
                try contextoBD.save()
                return true
            } catch {
                print("Error al guardar mascota: \(error.localizedDescription)")
                return false
            }
    }
    
    // READ ALL
    func getMascotas() -> [Mascota] {
        var mascotas: [Mascota] = []
        do {
            let request = MascotaEntity.fetchRequest()
            let entities = try contextoBD.fetch(request)
            
            mascotas = entities.map { entity in
                Mascota(
                    codigo: entity.codigo,
                    raza: entity.raza ?? "",
                    precio: entity.precio,
                    foto: entity.foto ?? ""
                )
            }
        } catch {
            print("Error al obtener mascotas: \(error.localizedDescription)")
        }
        return mascotas
    }
    
    // READ by codigo
    func getMascota(byCodigo codigo: Int16) -> Mascota? {
        let request = MascotaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                return Mascota(
                    codigo: entity.codigo,
                    raza: entity.raza ?? "",
                    precio: entity.precio,
                    foto: entity.foto ?? ""
                )
            }
        } catch {
            print("Error al buscar mascota: \(error.localizedDescription)")
        }
        return nil
    }
    
    // UPDATE
    func updateMascota(mascota: Mascota) -> Bool {
        let request = MascotaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", mascota.codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                entity.raza = mascota.raza
                entity.precio = mascota.precio
                entity.foto = mascota.foto
                try contextoBD.save()
                return true
            }
        } catch {
            print("Error al actualizar mascota: \(error.localizedDescription)")
        }
        return false
    }
    
    // DELETE
    func deleteMascota(byCodigo codigo: Int16) -> Bool {
        let request = MascotaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                contextoBD.delete(entity)
                try contextoBD.save()
                return true
            }
        } catch {
            print("Error al eliminar mascota: \(error.localizedDescription)")
        }
        return false
    }
}
