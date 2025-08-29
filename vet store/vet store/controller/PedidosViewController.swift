//
//  PedidosViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class PedidosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PedidoTableViewCellDelegate {

    
    @IBOutlet weak var tvPedidos: UITableView!
    
    
    var listaFinalizarPedidos: [FinalizarPedido] = []
    var pedidoSeleccionado = -1
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarPedidos()
        print(listaFinalizarPedidos)
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
        return listaFinalizarPedidos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tvPedidos.dequeueReusableCell(withIdentifier: "cardPedido") as! PedidoTableViewCell
        
        celda.lblRaza.text = "\(listaFinalizarPedidos[indexPath.row].pedido?.mascota?.raza ?? "")"
        celda.lblPrecioTotal.text = "\(listaFinalizarPedidos[indexPath.row].pedido?.precioTotal ?? 0)"
        
        if let url = URL(string: listaFinalizarPedidos[indexPath.row].pedido?.mascota?.foto ?? "") {
            celda.ivFoto.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "producto_icon")
            )
        }
        
        // Asignamos el delegate
        celda.delegate = self
        
        return celda
    }


    
    
    func cargarPedidos(){
        listaFinalizarPedidos = FinalizarPedidoService().getFinalizarPedidos()
    }
    
    
    func didTapComprar(in cell: PedidoTableViewCell) {
        // Ubicamos la celda para saber cuál pedido es
        if let indexPath = tvPedidos.indexPath(for: cell) {
            let finalizarPedido = listaFinalizarPedidos[indexPath.row]
            
            // Aquí decides qué hacer: navegar, mostrar alerta, etc.
            print("Se tocó el botón en el pedido de: \(finalizarPedido.pedido?.mascota?.raza ?? "")")
            
            // Ejemplo: navegar a un detalle
            pedidoSeleccionado = indexPath.row
            
            Routes.navigate(to: .pedidosADetallePedido, from: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "pedidosADetallePedido" {
                let detallePedido = segue.destination as! DetallePedidoViewController
                detallePedido.finalizarPedido = listaFinalizarPedidos[pedidoSeleccionado]
            }
        }


}
