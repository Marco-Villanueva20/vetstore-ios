//
//  PedidosViewController.swift
//  vet store
//
//  Created by Jacktter on 24/08/25.
//

import UIKit

class PedidosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PedidoTableViewCellDelegate {

    
    @IBOutlet weak var txtCodPedIngresado: UITextField!
    var usuarioResponse: UsuarioResponse?
    
    
    
    @IBOutlet weak var tvPedidos: UITableView!
    
    
    var listaFinalizarPedidos: [FinalizarPedido] = []
    var pedidoSeleccionado = -1
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           
           Task {
               // Siempre cargamos usuario y pedidos al entrar
               self.usuarioResponse = await UsuarioService.usuarioLogueado()
               print("Usuario cargado: \(self.usuarioResponse?.nombre ?? "Sin nombre")")
               
               await MainActor.run {
                   self.cargarPedidos()
                   self.tvPedidos.reloadData()
               }
           }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
          
          // Configuración inicial (solo una vez)
          tvPedidos.delegate = self
          tvPedidos.dataSource = self
          tvPedidos.rowHeight = 150
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaFinalizarPedidos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let celda = tvPedidos.dequeueReusableCell(withIdentifier: "cardPedido") as? PedidoTableViewCell else {
                   // devuelve una celda vacía segura si el reuseId está mal configurado
                   return UITableViewCell(style: .default, reuseIdentifier: "fallback")
               }
               
               let finalizar = listaFinalizarPedidos[indexPath.row]
               let mascota = finalizar.pedido?.mascota
               
               celda.lblRaza.text = mascota?.raza ?? "Sin raza"
               
               // Formatear precio para evitar Optional(...) y mostrar 2 decimales
               let precio = finalizar.pedido?.precioTotal ?? 0.0
               let nf = NumberFormatter()
               nf.numberStyle = .decimal
               nf.minimumFractionDigits = 2
               nf.maximumFractionDigits = 2
        celda.lblRaza.text = "Raza: " + (finalizar.pedido?.mascota?.raza ?? "Desconocida")

        celda.lblCodigo.text = "Código: \(finalizar.codigo ?? 0)"

               celda.lblPrecioTotal.text = "S/ \(nf.string(from: NSNumber(value: precio)) ?? "0.00")"
               
               if let fotoString = mascota?.foto, let url = URL(string: fotoString) {
                   celda.ivFoto.sd_setImage(with: url, placeholderImage: UIImage(named: "producto_icon"))
               } else {
                   celda.ivFoto.image = UIImage(named: "producto_icon")
               }
               
               celda.delegate = self
               return celda
    }

    
    @IBAction func btnBuscarPorCodPedIng(_ sender: UIButton) {
        guard let usuario = usuarioResponse else {
               AlertHelper.showAlert(on: self, title: "Error", message: "No hay usuario logueado.")
               return
           }
           
           guard let texto = txtCodPedIngresado.text,
                 let codigo = Int16(texto) else {
               AlertHelper.showAlert(on: self, title: "Error", message: "Ingrese un código válido.")
               return
           }
           
           let service = FinalizarPedidoService()
           var resultado: FinalizarPedido?
           
           if usuario.rol.lowercased() == "administrador" {
               // Admin → buscar solo por código
               resultado = service.getFinalizarPedido(byCodigo: codigo)
           } else {
               // Usuario → buscar por código y uuid
               resultado = service.getFinalizarPedido(byCodigo: codigo, usuarioUuid: usuario.uuid)
           }
           
           if let pedidoEncontrado = resultado {
               // Mostramos solo el pedido encontrado en la tabla
               listaFinalizarPedidos = [pedidoEncontrado]
               tvPedidos.reloadData()
           } else {
               AlertHelper.showAlert(on: self, title: "Sin resultados", message: "No se encontró un pedido con ese código.")
           }
    }
    
  
    
    

        func cargarPedidos() {
            guard let usuario = usuarioResponse else {
                print("⚠️ No hay usuario logueado")
                listaFinalizarPedidos = []
                return
            }
            
            let service = FinalizarPedidoService()
            
            if usuario.rol.lowercased() == "administrador" {
                // Admin ve todo
                listaFinalizarPedidos = service.getFinalizarPedidos()
            } else {
                // Usuario normal ve solo sus pedidos
                listaFinalizarPedidos = service.getFinalizarPedidos(byUsuarioUuid: usuario.uuid)
            }
        }
    
    
    func didTapComprar(in cell: PedidoTableViewCell) {
        // Ubicamos la celda para saber cuál pedido es
             guard let indexPath = tvPedidos.indexPath(for: cell) else {
                 AlertHelper.showAlert(on: self, title: "Atención", message: "No se pudo identificar el pedido seleccionado.")
                 return
             }
             
             // Comprobar índice seguro
             guard indexPath.row >= 0 && indexPath.row < listaFinalizarPedidos.count else {
                 AlertHelper.showAlert(on: self, title: "Atención", message: "Pedido inválido.")
                 return
             }
             
             let finalizarPedido = listaFinalizarPedidos[indexPath.row]
             
             // Validar que exista detalle y mascota antes de navegar
             if finalizarPedido.pedido == nil {
                 AlertHelper.showAlert(on: self, title: "Atención", message: "Este pedido no contiene detalles.")
                 return
             }
             if finalizarPedido.pedido?.mascota == nil {
                 AlertHelper.showAlert(on: self, title: "Atención", message: "Este pedido no tiene mascota asociada.")
                 return
             }
             
             // Guardamos selección y navegamos
             pedidoSeleccionado = indexPath.row
             Routes.navigate(to: .pedidosADetallePedido, from: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pedidosADetallePedido" {
                   guard pedidoSeleccionado >= 0 && pedidoSeleccionado < listaFinalizarPedidos.count else {
                       // defensivo: si por alguna razón no es válido, evitamos crash
                       return
                   }
                   if let detalleVC = segue.destination as? DetallePedidoViewController {
                       detalleVC.finalizarPedido = listaFinalizarPedidos[pedidoSeleccionado]
                   }
               }
        }


}
