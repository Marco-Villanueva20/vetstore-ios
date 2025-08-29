import UIKit
import Storage
import CoreData

class MascotaService: NSObject {
    private let contextoBD: NSManagedObjectContext
    
    private var supabase = SupabaseManager.shared.client
    
    override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.contextoBD = delegate.persistentContainer.viewContext
    }
    
    private let bucketName = "mascotas"
    
    // SUBIR FOTO A SUPABASE Y OBTENER URL
        func uploadFotoMascota(fileName: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
            guard let imageData = image.pngData() else {
                completion(.failure(NSError(domain: "MascotaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen a PNG."])))
                return
            }
            
            // ✅ aseguramos que tenga ".png"
                let path = fileName.hasSuffix(".png") ? fileName : "\(fileName).png"
                
                // ✅ importante: subir dentro de "private/"
                let storagePath = "private/\(path)"
            
            
            Task {
                do {
                    // 1. Subir al bucket
                    try await supabase.storage.from(bucketName).upload(
                        storagePath,
                        data: imageData,
                        options: FileOptions(
                            contentType: "image/png",
                            upsert: false)
                    )
                    
                    // 2. Obtener URL pública
                    let publicURL = try supabase.storage.from(bucketName).getPublicURL(path: storagePath)
                    completion(.success(publicURL.absoluteString))
                } catch {
                    completion(.failure(error))
                }
            }
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
                entity.cantidad_machos = mascota.cantidadMachos
                entity.cantidad_hembras = mascota.cantidadHembras
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
                    cantidadMachos: entity.cantidad_machos,
                    cantidadHembras: entity.cantidad_hembras,
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
                    cantidadMachos: entity.cantidad_machos,
                    cantidadHembras: entity.cantidad_hembras,
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
                entity.cantidad_machos = mascota.cantidadMachos
                entity.cantidad_hembras = mascota.cantidadHembras
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
