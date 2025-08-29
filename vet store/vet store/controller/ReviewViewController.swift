//
//  ClientesViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit
import SDWebImage

class ReviewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var listaReviews: [Review] = []
    var reviewSeleccionada = -1
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarReviews()
        tvPreview.reloadData()
    }
    
    
    @IBOutlet weak var tvPreview: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvPreview.delegate = self
        tvPreview.dataSource = self
        tvPreview.rowHeight = 150
        // Do any additional setup after loading the view.
    }
    
    func cargarReviews(){
        listaReviews = ReviewService().getReviews()
        
        let reseñaFake = Review(
               codigo: 12,
               nombre: "Carlos Mendoza",
               comentario: "Fue una gran experiencia, el perrito llegó en buen estado 🐶✨",
               foto: "https://i.imgur.com/BoN9kdC.png" // URL de imagen pública
           )
           
           listaReviews.append(reseñaFake)
    }
    
    
    @IBAction func btnAgregarReview(_ sender: UIButton) {
        Routes.navigate(to: .reviewAAgregarReview, from: self)
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tvPreview.dequeueReusableCell(withIdentifier: "cardReview") as! ReviewTableViewCell
    
        celda.lblNombre.text = "\(listaReviews[indexPath.row].nombre)"
        celda.lblComentario.text = "\(listaReviews[indexPath.row].comentario)"
        
        if let url = URL(string: listaReviews[indexPath.row].foto) {
            celda.ivFoto.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "producto_icon") // opcional
            )
        }
        
        
        return celda
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reviewSeleccionada = indexPath.row
        Routes.navigate(to: .reviewADetalleReview, from: self)
        }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             if segue.identifier == "reviewADetalleReview" {
                 let detalleReview = segue.destination as! DetalleReviewViewController
                 detalleReview.review = listaReviews[reviewSeleccionada]
             }
         }
     
    
}
