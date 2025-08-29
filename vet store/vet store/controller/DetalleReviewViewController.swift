//
//  DetalleReviewViewController.swift
//  vet store
//
//  Created by Jacktter on 28/08/25.
//

import UIKit

class DetalleReviewViewController: UIViewController {

    var review : Review!
    
    @IBOutlet weak var lblNombreUsuario: UILabel!
    @IBOutlet weak var ivFoto: UIImageView!
    
    @IBOutlet weak var lblComentario: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imprimirDatos()
        // Do any additional setup after loading the view.
    }
    

    func imprimirDatos(){
        lblNombreUsuario.text = review.nombre
        lblComentario.text = review.comentario
        if let url = URL(string: review.foto) {
            ivFoto.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "producto_icon") // opcional
            )
            
        }
    }
}
