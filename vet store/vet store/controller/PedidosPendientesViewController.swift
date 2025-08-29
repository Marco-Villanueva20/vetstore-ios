//
//  PedidosPendientesViewController.swift
//  vet store
//
//  Created by Jacktter on 29/08/25.
//

import UIKit

class PedidosPendientesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var listaDetallePedidos: [DetallePedido] = []
    var yaMostroMensaje = false
    var pedidoPendienteSeleccionado = -1
    
    @IBOutlet weak var tvPedidosPendientes: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tvPedidosPendientes.delegate = self
               tvPedidosPendientes.dataSource = self
               tvPedidosPendientes.rowHeight = 150
        cargarPendientes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
        }
    
    private func cargarPendientes() {
           Task {
               let usuario = await UsuarioService.usuarioLogueado()
               let servicio = DetallePedidoService()

               if usuario.rol.lowercased() == "administrador" {
                   self.listaDetallePedidos = servicio.getPedidosPendientes()
               } else {
                   self.listaDetallePedidos = servicio.getPedidosPendientes(forUsuarioUuid: usuario.uuid)
               }

               await MainActor.run {
                   self.tvPedidosPendientes.reloadData()
                   self.mostrarEstadoVacioSiCorresponde()
               }
           }
       }
    /// Muestra un mensaje en la tabla cuando no hay pedidos
       private func mostrarEstadoVacioSiCorresponde() {
           if listaDetallePedidos.isEmpty {
               let emptyLabel = UILabel()
               emptyLabel.text = "No hay pedidos pendientes para mostrar."
               emptyLabel.textAlignment = .center
               emptyLabel.textColor = .gray
               emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
               tvPedidosPendientes.backgroundView = emptyLabel
           } else {
               tvPedidosPendientes.backgroundView = nil
           }
       }
       
    
    
    // MARK: - Table

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return listaDetallePedidos.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let celda = tvPedidosPendientes.dequeueReusableCell(withIdentifier: "cardPedidoPendiente") as? PedidoPendienteTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "fallback")
            }

            let pedido = listaDetallePedidos[indexPath.row]
            celda.lblRaza.text = "Raza: \(pedido.mascota?.raza ?? "Sin Mascota")"
            celda.lblPrecioTotal.text = String(format: "Precio: S/ %.2f", pedido.precioTotal)
            celda.lblEstado.text = "Estado: \(pedido.estado ?? "")"
            celda.lblCodigo.text = "Codigo: \(pedido.codigo ?? 0)"

            if let urlString = pedido.mascota?.foto, let url = URL(string: urlString) {
                celda.ivFoto.sd_setImage(with: url, placeholderImage: UIImage(named: "producto_icon"))
            } else {
                celda.ivFoto.image = UIImage(named: "producto_icon")
            }

            return celda
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            pedidoPendienteSeleccionado = indexPath.row
            performSegue(withIdentifier: "pedidosPendientesAFinalizarPedido", sender: nil)
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pedidosPendientesAFinalizarPedido" {
            guard pedidoPendienteSeleccionado >= 0 && pedidoPendienteSeleccionado < listaDetallePedidos.count else { return }
            if let finalizarVC = segue.destination as? FinalizarPedidoViewController {
                finalizarVC.detallePedido = listaDetallePedidos[pedidoPendienteSeleccionado]
            }
        }
    }
    
    @IBAction func btnVolver(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
}
