import UIKit
import Foundation

/// Posibles errores de validación
enum ValidationError: Error {
    case campoVacio(String)
    case numeroInvalido(String)
    
    /// Mensaje legible para mostrar al usuario
    var mensaje: String {
        switch self {
        case .campoVacio(let nombreCampo):
            return "El campo \(nombreCampo) no puede estar vacío."
        case .numeroInvalido(let nombreCampo):
            return "El campo \(nombreCampo) debe ser un número válido."
        }
    }
}

/// Clase con métodos reutilizables para validar datos
class ValidationHelper {
    
    /// Valida que el texto pueda convertirse en un `Int`
    static func parseInt(_ texto: String?, nombreCampo: String) -> Result<Int, ValidationError> {
        
        guard let valor = texto, !valor.isEmpty else {
            return .failure(.campoVacio(nombreCampo))
        }
        guard let numero = Int(valor) else {
            return .failure(.numeroInvalido(nombreCampo))
        }
        return .success(numero)
    }
    
    /// Valida que el texto pueda convertirse en un `Double`
    static func parseDouble(_ texto: String?, nombreCampo: String) -> Result<Double, ValidationError> {
        guard let valor = texto, !valor.isEmpty else {
            return .failure(.campoVacio(nombreCampo))
        }
        guard let numero = Double(valor) else {
            return .failure(.numeroInvalido(nombreCampo))
        }
        return .success(numero)
    }
    
    /// Valida que un texto no esté vacío y sea uno de los permitidos
    static func parseString(_ texto: String?, nombreCampo: String, valoresPermitidos: [String]? = nil) -> Result<String, ValidationError> {
        guard let valor = texto, !valor.isEmpty else {
            return .failure(.campoVacio(nombreCampo))
        }
        if let permitidos = valoresPermitidos, !permitidos.contains(valor.capitalized) {
            return .failure(.numeroInvalido("\(nombreCampo) debe ser uno de: \(permitidos.joined(separator: ", "))"))
        }
        return .success(valor.capitalized)
    }
    
    
    static func validarGenero(_ genero: String?) -> String? {
           guard let genero = genero, !genero.isEmpty else {
               return "Debes ingresar el género (Macho o Hembra)."
           }
           
           let generoValido = ["Macho", "Hembra"]
           if !generoValido.contains(genero.capitalized) {
               return "El género debe ser 'Macho' o 'Hembra'."
           }
           return nil
       }
       
       static func validarStock(genero: String, cantidadPedido: Int, mascota: Mascota) -> String? {
           if genero.capitalized == "Macho" {
               if cantidadPedido > mascota.cantidadMachos {
                   return "No puedes pedir más machos de los que hay en stock (\(mascota.cantidadMachos))."
               }
           } else {
               if cantidadPedido > mascota.cantidadHembras {
                   return "No puedes pedir más hembras de las que hay en stock (\(mascota.cantidadHembras))."
               }
           }
           return nil
       }

}
