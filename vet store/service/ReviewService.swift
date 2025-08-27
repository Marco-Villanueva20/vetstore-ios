import UIKit
import CoreData

class ReviewService: NSObject {
    private let contextoBD: NSManagedObjectContext
    
    override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.contextoBD = delegate.persistentContainer.viewContext
    }
    
    // CREATE
    func addReview(review: Review) -> Bool {
        let entity = ReviewEntity(context: contextoBD)
       
        do {
            entity.codigo = try CoreDataHelper.generarNuevoCodigo(
                entidad: "ReviewEntity",
                context: contextoBD
            )
            entity.nombre = review.nombre
            entity.foto = review.foto
            entity.comentario = review.comentario
            
            try contextoBD.save()
            return true
        } catch {
            print("Error al guardar review: \(error.localizedDescription)")
            return false
        }
    }
    
    // READ ALL
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
    
    // READ by codigo
    func getReview(byCodigo codigo: String) -> Review? {
        let request = ReviewEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %@", codigo)
        
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
    
    // UPDATE
    func updateReview(review: Review) -> Bool {
        let request = ReviewEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %@", review.codigo)
        
        do {
            if let entity = try contextoBD.fetch(request).first {
                entity.nombre = review.nombre
                entity.foto = review.foto
                entity.comentario = review.comentario
                try contextoBD.save()
                return true
            }
        } catch {
            print("Error al actualizar review: \(error.localizedDescription)")
        }
        return false
    }
    
    // DELETE
    func deleteReview(byCodigo codigo: String) -> Bool {
        let request = ReviewEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %@", codigo)
        
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
