//
//  PedidosViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class PedidosViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var tvPedidos: UITableView!
    
    
    var listaPedidos: [Pedido] = []
    var pedidoSeleccionado = -1
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //cargarPedidos()
        tvPedidos.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvPedidos.delegate = self
        tvPedidos.dataSource = self
        tvPedidos.rowHeight = 150
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaPedidos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tvPedidos.dequeueReusableCell(withIdentifier: "cardPedido") as! PedidoTableViewCell
    
      /*  celda.lblRaza.text = "\(listaPedidos[indexPath.row].)"
        celda.lblComentario.text = "\(listaReviews[indexPath.row].comentario)"
        
        if let url = URL(string: listaReviews[indexPath.row].foto) {
            celda.ivFoto.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "producto_icon") // opcional
            )
        }
        
        */
        return celda
        
    }

    

}
