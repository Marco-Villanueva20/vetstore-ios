//
//  HomeViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {
    

    let supabase = SupabaseManager.shared.client
    
    @IBOutlet weak var lblBienvenida: UILabel!

    @IBOutlet weak var tvMascotas: UITableView!
    
    
    var listaMascotas: [Mascota] = []
    var mascotaSeleccionada = -1
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarMascotas()
        tvMascotas.reloadData()
    }
    
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        imprimirBienvenida()
        
        tvMascotas.delegate = self
        tvMascotas.dataSource = self
        tvMascotas.rowHeight = 150
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaMascotas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tvMascotas.dequeueReusableCell(withIdentifier: "cardMascota") as! MascotaTableViewCell
    
        celda.lblRaza.text = "\(listaMascotas[indexPath.row].raza)"
        celda.lblPrecio.text = "\(listaMascotas[indexPath.row].precio)"
        
        if let url = URL(string: listaMascotas[indexPath.row].foto) {
            celda.ivFoto.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "producto_icon") // opcional
            )
        }
        
        
        return celda
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mascotaSeleccionada = indexPath.row
            performSegue(withIdentifier: "homeADetallePedidoCar", sender: nil)
        }
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             if segue.identifier == "homeADetallePedidoCar" {
                 let detallePedidoCar = segue.destination as! DetallePedidoCarViewController
                 detallePedidoCar.mascota = listaMascotas[mascotaSeleccionada]
             }
         }
     
     
    
    
    
    func cargarMascotas(){
        listaMascotas = MascotaService().getMascotas()
        
        let reseñaFake = Mascota(
               codigo: 12,
               raza: "Chihuahua",
               precio: 12.0,
               foto: "https://www.zooplus.pt/magazine/wp-content/uploads/2019/06/Chihuahua.jpg"            )
           
        listaMascotas.append(reseñaFake)
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
