
import UIKit
import Supabase

class UsuarioService {
    
    let supabase = SupabaseManager.shared.client
    
    
    func create(_ usuario: Usuario) async throws -> UsuarioResponse? {
        let rol = asignarRol(correo: usuario.correo) // 👈 se calcula aquí
        
        let response = try await supabase.auth.signUp(
            email: usuario.correo,
            password: usuario.contrasena,
            data: [
                "nombre_completo": .string(usuario.nombre),
                "rol": .string(rol) 
            ]
        )
        
        let user = response.user
        
        let nombre = user.userMetadata["nombre_completo"]?.stringValue ?? "Sin nombre"
        let correo = user.email ?? "Correo no disponible"
        let rolObtenido = user.userMetadata["rol"]?.stringValue ?? "cliente"
        let uuid = user.id.uuidString
        return UsuarioResponse(uuid: uuid ,nombre: nombre, correo: correo, rol: rolObtenido, status: 200)
    }


    
    func login(_ usuarioRequest: UsuarioRequest) async throws -> Session {
           let session = try await supabase.auth.signIn(
               email: usuarioRequest.correo,
               password: usuarioRequest.contrasena
           )
           return session
       }
    
    private func asignarRol(correo: String) -> String {
        if correo.lowercased().hasSuffix("@admin.com") {
            return "administrador"
        } else {
            return "cliente"
        }
    }
    
    
    static func usuarioIsLogin() async -> Bool {
        if let session = try? await SupabaseManager.shared.client.auth.session {
            let user = session.user
            print("Usuario logueado: \(user.email ?? "sin email")")
            return true
        } else {
            print("No hay usuario logueado")
            return false
        }
    }
    
    static func cerrarSesion() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
            print("Sesión cerrada correctamente")
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }

    
    static func usuarioLogueado() async -> UsuarioResponse {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let user = session.user
            // user.id viene como String
            let uuid = user.id.uuidString
            
            let nombre = user.userMetadata["nombre_completo"]?.stringValue ?? "Sin nombre"
            let correo = user.email ?? "Correo no disponible"
            let rolObtenido = user.userMetadata["rol"]?.stringValue ?? "cliente"
            
            return UsuarioResponse(
                uuid: uuid,
                nombre: nombre,
                correo: correo,
                rol: rolObtenido,
                status: 200
            )
        } catch {
            print("❌ Error obteniendo usuario logueado: \(error.localizedDescription)")
            return UsuarioResponse(
                uuid: "",
                nombre: "Desconocido",
                correo: "",
                rol: "ninguno",
                status: 400
            )
        }
    }

}
