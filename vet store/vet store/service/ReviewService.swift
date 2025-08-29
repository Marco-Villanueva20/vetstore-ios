import UIKit
import CoreData
import Supabase

class ReviewService: NSObject {
    private let contextoBD: NSManagedObjectContext
    private var supabase = SupabaseManager.shared.client
    private let bucketName = "reviews"
    
    override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.contextoBD = delegate.persistentContainer.viewContext
    }
    
    // ✅ SUBIR FOTO A SUPABASE Y OBTENER URL
    func uploadFotoReview(fileName: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.pngData() else {
            completion(.failure(NSError(domain: "ReviewService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen a PNG."])))
            return
        }
        
        let path = fileName.hasSuffix(".png") ? fileName : "\(fileName).png"
        let storagePath = "private/\(path)"
        
        Task {
            do {
                try await supabase.storage.from(bucketName).upload(
                    storagePath,
                    data: imageData,
                    options: FileOptions(contentType: "image/png", upsert: false)
                )
                
                let publicURL = try supabase.storage.from(bucketName).getPublicURL(path: storagePath)
                completion(.success(publicURL.absoluteString))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // ✅ CREATE
    func addReview(review: Review) -> Bool {
        let entity = ReviewEntity(context: contextoBD)
        do {
            entity.codigo = try CoreDataHelper.generarNuevoCodigo(entidad: "ReviewEntity", context: contextoBD)
            entity.nombre = review.nombre
            entity.comentario = review.comentario
            entity.foto = review.foto
            
            try contextoBD.save()
            return true
        } catch {
            print("Error al guardar review: \(error.localizedDescription)")
            return false
        }
    }
    
    // ✅ READ ALL
    func getReviews() -> [Review] {
        var reviews: [Review] = []
        do {
            let request = ReviewEntity.fetchRequest()
            let entities = try contextoBD.fetch(request)
            reviews = entities.map { entity in
                Review(
                    codigo: entity.codigo,
                    nombre: entity.nombre ?? "",
                    comentario: entity.comentario ?? "",
                    foto: entity.foto ?? ""
                )
            }
        } catch {
            print("Error al obtener reviews: \(error.localizedDescription)")
        }
        return reviews
    }
    
    // ✅ READ by codigo
    func getReview(byCodigo codigo: Int16) -> Review? {
        let request = ReviewEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                return Review(
                    codigo: entity.codigo,
                    nombre: entity.nombre ?? "",
                    comentario: entity.comentario ?? "",
                    foto: entity.foto ?? ""
                )
            }
        } catch {
            print("Error al buscar review: \(error.localizedDescription)")
        }
        return nil
    }
    
    // ✅ UPDATE
    func updateReview(review: Review) -> Bool {
        let request = ReviewEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", review.codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                entity.nombre = review.nombre
                entity.comentario = review.comentario
                entity.foto = review.foto
                try contextoBD.save()
                return true
            }
        } catch {
            print("Error al actualizar review: \(error.localizedDescription)")
        }
        return false
    }
    
    // ✅ DELETE
    func deleteReview(byCodigo codigo: Int16) -> Bool {
        let request = ReviewEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %d", codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                contextoBD.delete(entity)
                try contextoBD.save()
                return true
            }
        } catch {
            print("Error al eliminar review: \(error.localizedDescription)")
        }
        return false
    }
}
