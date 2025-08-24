//
//  HomeViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class HomeViewController: UIViewController {

    let supabase = SupabaseManager.shared.client
    
    @IBOutlet weak var lblBienvenida: UILabel!



    override func viewDidLoad() {
        
        super.viewDidLoad()
        imprimirBienvenida()
    }
    
    func imprimirBienvenida() {
        Task{
            do {
                let session = try await supabase.auth.session
                let user = session.user
                let nombre = user.userMetadata["nombre_completo"]?.stringValue ?? "Sin nombre"
                    
                    // Actualiza la etiqueta en el hilo principal
                    DispatchQueue.main.async {
                        self.lblBienvenida.text = "Bienvenido, \(nombre)"
                    }
            } catch {
                print("Error al obtener usuario: \(error)")
                DispatchQueue.main.async {
                    self.lblBienvenida.text = "Bienvenido"
                }
            }
        }
        
    }

    

}
