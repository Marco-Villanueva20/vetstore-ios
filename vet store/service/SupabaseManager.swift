//
//  SupabaseManager.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()
        
        let client: SupabaseClient
        
        private init() {
            client = SupabaseClient(
                supabaseURL: URL(string: "https://drorkeekaqgdkttzdtxb.supabase.co")!,
                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRyb3JrZWVrYXFnZGt0dHpkdHhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3Nzg5OTEsImV4cCI6MjA3MDM1NDk5MX0.9XwZANOLJh49gNIaBL9XKfKmJfbHCShg-xiKohUcGJA")
        }
}
