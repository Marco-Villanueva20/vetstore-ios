//
//  HomeViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {
    @IBOutlet weak var lblBienvenida: UILabel!
    @IBOutlet weak var tvMascotas: UITableView!
    @IBOutlet weak var btnAgregarMascota: UIButton!
    
    var usuarioResponse: UsuarioResponse?
    var listaMascotas: [Mascota] = []
    var mascotaSeleccionada = -1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarMascotas()
        tvMascotas.reloadData()
    }
    
    
    @IBAction func btnCerrarSesion(_ sender: UIButton) {
        Task{
            await UsuarioService.cerrarSesion()
            Routes.navigate(to: .homeALogin, from: self)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            self.usuarioResponse = await UsuarioService.usuarioLogueado()
            print("Usuario cargado: \(self.usuarioResponse?.nombre ?? "Sin nombre")")
            
            // 👇 Ya tengo el usuario, ahora sí imprimo la bienvenida
            await MainActor.run {
                self.imprimirBienvenida()
            }
        }
        
        tvMascotas.delegate = self
        tvMascotas.dataSource = self
        tvMascotas.rowHeight = 150
    }

    
    
    
    @IBAction func btnAgregarMascota(_ sender: UIButton) {
        Routes.navigate(to: .homeAAgregarMascota, from: self)
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
               cantidadMachos: 12,
               cantidadHembras: 14,
               foto: "https://www.zooplus.pt/magazine/wp-content/uploads/2019/06/Chihuahua.jpg"            )
           
        listaMascotas.append(reseñaFake)
    }
    
    
    func imprimirBienvenida() {
        Task {
            let nombre = usuarioResponse?.nombre ?? "Sin nombre"
            
            DispatchQueue.main.async {
                let titulo = "Bienvenid@, "
                let texto = NSMutableAttributedString(
                    string: titulo,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                        .foregroundColor: UIColor.white
                    ]
                )
                
                let nombreAttr = NSAttributedString(
                    string: nombre,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                        .foregroundColor: UIColor.systemBlue
                    ]
                )
                
                texto.append(nombreAttr)
                self.lblBienvenida.attributedText = texto
                
                self.lblBienvenida.textAlignment = .center
                self.lblBienvenida.layer.cornerRadius = 8
                self.lblBienvenida.layer.masksToBounds = true
                self.lblBienvenida.layer.borderColor = UIColor.black.cgColor
                self.lblBienvenida.layer.borderWidth = 1
            }
        }
    }


    

}
