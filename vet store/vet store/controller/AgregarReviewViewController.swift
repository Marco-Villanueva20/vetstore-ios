//
//  AgregarReviewViewController.swift
//  vet store
//
//  Created by Jacktter on 28/08/25.
//

import UIKit

class AgregarReviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var usuarioResponse: UsuarioResponse?
    let reviewService = ReviewService()
    @IBOutlet weak var lblNombreUsuario: UILabel!
    
    @IBOutlet weak var txtComentario: UITextField!
    
    @IBOutlet weak var ivFoto: UIImageView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            self.usuarioResponse = await UsuarioService.usuarioLogueado()
            print("Usuario cargado: \(self.usuarioResponse?.nombre ?? "Sin nombre")")
            
            // 👇 Ya tengo el usuario, ahora sí imprimo la bienvenida
            await MainActor.run {
                self.imprimirUsuario()
            }
        }
        
        
        ivFoto.isUserInteractionEnabled = true
               ivFoto.layer.cornerRadius = 8
               ivFoto.layer.borderWidth = 1
               ivFoto.layer.borderColor = UIColor.gray.cgColor
               
               let tap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
               ivFoto.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func imprimirUsuario(){
        lblNombreUsuario.text = usuarioResponse?.nombre
    }
    
    // Seleccionar imagen desde la galería
      @objc func selectImage() {
          let picker = UIImagePickerController()
          picker.delegate = self
          picker.sourceType = .photoLibrary
          present(picker, animated: true)
      }
      
      // Método del UIImagePickerControllerDelegate
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          if let imagen = info[.originalImage] as? UIImage {
              ivFoto.image = imagen
          }
          picker.dismiss(animated: true)
      }
      
    
    
    @IBAction func btnAgregarReview(_ sender: UIButton) {
        // 1️⃣ Validar comentario obligatorio
          guard let comentario = txtComentario.text, !comentario.isEmpty else {
              AlertHelper.showAlert(on: self, title: "Error", message: "Por favor escribe un comentario.")
              return
          }
          
          // 2️⃣ Nombre del usuario
          let nombreUsuario = lblNombreUsuario.text ?? "Anónimo"
          
          // 3️⃣ Verificar si hay foto seleccionada
          if let imagen = ivFoto.image {
              // Si hay foto → subirla primero
              let fileName = "review_\(UUID().uuidString)"
              reviewService.uploadFotoReview(fileName: fileName, image: imagen) { result in
                  DispatchQueue.main.async {
                      switch result {
                      case .success(let urlFoto):
                          print("✅ Foto subida. URL: \(urlFoto)")
                          
                          // Crear review con foto
                          let nuevaReview = Review(
                              codigo: 0,
                              nombre: nombreUsuario,
                              comentario: comentario,
                              foto: urlFoto
                          )
                          
                          self.guardarReview(nuevaReview)
                          
                      case .failure(let error):
                          AlertHelper.showAlert(on: self, title: "Error", message: "Error al subir foto: \(error.localizedDescription)")
                      }
                  }
              }
          } else {
              // Si NO hay foto → crear review sin URL de foto
              let nuevaReview = Review(
                  codigo: 0,
                  nombre: nombreUsuario,
                  comentario: comentario,
                  foto: ""
              )
              
              guardarReview(nuevaReview)
          }
    }
    
    
    @IBAction func btnCancelar(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    private func guardarReview(_ review: Review) {
        let ok = reviewService.addReview(review: review)
        if ok {
            AlertHelper.showSuccessAndDismiss(on: self, message: "Reseña agregada con éxito")
        } else {
            AlertHelper.showAlert(on: self, title: "Error", message: "No se pudo guardar la review.")
        }
    }

}
