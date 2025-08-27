//
//  CoreDataHelper.swift
//  vet store
//
//  Created by Jacktter on 26/08/25.
//

import UIKit
import CoreData

class CoreDataHelper {
    // Método estático (se llama sin crear objetos) que genera el próximo "código" para cualquier entidad
    static func generarNuevoCodigo(
           entidad: String,                  // Nombre de la entidad en Core Data (ej: "MascotaEntity")
           campo: String = "codigo",         // Nombre del atributo que funciona como ID (por defecto "codigo")
           context: NSManagedObjectContext   // El contexto de Core Data (la "conexión" a la BD)
       ) throws -> Int16 {
           
           // 1. Creamos un fetchRequest, pero en lugar de traer objetos completos,
           //    le decimos que traiga solo diccionarios con propiedades calculadas.
           let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: entidad)
           fetchRequest.resultType = .dictionaryResultType
           
           // 2. Definimos una "expresión" que apunta al campo que queremos (ej: "codigo").
           let keypathExpression = NSExpression(forKeyPath: campo)
           
           // 3. Creamos una expresión que calcule el máximo valor de ese campo.
           //    Esto es equivalente a hacer en SQL: SELECT MAX(codigo) FROM entidad
           let maxExpression = NSExpression(forFunction: "max:", arguments: [keypathExpression])
           
           // 4. Preparamos un objeto que describe cómo se llamará y qué tipo tendrá ese resultado.
           let expressionDescription = NSExpressionDescription()
           expressionDescription.name = "maxCodigo"                      // nombre del resultado
           expressionDescription.expression = maxExpression              // la operación que queremos (MAX)
           expressionDescription.expressionResultType = .integer64AttributeType // tipo de dato que regresa
           
           // 5. Le decimos al fetchRequest que solo queremos esta propiedad calculada (no toda la entidad).
           fetchRequest.propertiesToFetch = [expressionDescription]
           
           // 6. Ejecutamos el fetchRequest (esto va a la BD).
           let results = try context.fetch(fetchRequest)
           
           // 7. Si encontramos resultados y existe "maxCodigo", devolvemos max + 1
           if let dict = results.first, let maxCodigo = dict["maxCodigo"] as? Int64 {
               return Int16(maxCodigo + 1)  // siguiente número
           } else {
               return 1  // si no hay registros aún, empezamos en 1
           }
       }
}
