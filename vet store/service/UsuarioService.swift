//
//  AuthController.swift
//  vet store
//
//  Created by Jacktter on 22/08/25.
//

import UIKit
import Supabase

class UsuarioService {
    
    let supabase = SupabaseClient(supabaseURL: URL(string: "https://drorkeekaqgdkttzdtxb.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRyb3JrZWVrYXFnZGt0dHpkdHhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3Nzg5OTEsImV4cCI6MjA3MDM1NDk5MX0.9XwZANOLJh49gNIaBL9XKfKmJfbHCShg-xiKohUcGJA")
    
    
    func create(_ usuario: Usuario) async throws -> UsuarioResponse? {
        let rol = asignarRol(correo: usuario.correo) // 👈 se calcula aquí
        
        let response = try await supabase.auth.signUp(
            email: usuario.correo,
            password: usuario.contrasena,
            data: [
                "nombre_completo": .string(usuario.nombre),
                "rol": .string(rol) // 👈 se guarda en metadatos
            ]
        )
        
        let user = response.user
        
        let nombre = user.userMetadata["nombre_completo"]?.stringValue ?? "Sin nombre"
        let correo = user.email ?? "Correo no disponible"
        let rolObtenido = user.userMetadata["rol"]?.stringValue ?? "cliente"
        
        return UsuarioResponse(nombre: nombre, correo: correo, rol: rolObtenido, status: 200)
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
}
