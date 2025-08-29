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
        // 1️⃣ Validar que haya una imagen seleccionada
               guard let imagen = ivFoto.image else {
                   print("❌ Selecciona una foto antes de agregar.")
                   return
               }
               
               // 2️⃣ Validar comentario
               guard let comentario = txtComentario.text, !comentario.isEmpty else {
                   print("❌ Escribe un comentario.")
                   return
               }
               
               // 3️⃣ Obtener nombre de usuario desde la etiqueta
               let nombreUsuario = lblNombreUsuario.text ?? "Anónimo"
               
               // 4️⃣ Subir la foto a Supabase
               let fileName = "review_\(UUID().uuidString)"
               reviewService.uploadFotoReview(fileName: fileName, image: imagen) { result in
                   DispatchQueue.main.async {
                       switch result {
                       case .success(let urlFoto):
                           print("✅ Foto subida. URL: \(urlFoto)")
                           
                           // 5️⃣ Crear objeto Review con URL de la foto
                           let nuevaReview = Review(
                               codigo: 0, // CoreData generará el código automáticamente
                               nombre: nombreUsuario,
                               comentario: comentario,
                               foto: urlFoto
                           )
                           
                           // 6️⃣ Guardar en Core Data
                           let ok = self.reviewService.addReview(review: nuevaReview)
                           if ok {
                               print("✅ Review guardada en Core Data")
                               self.dismiss(animated: true)
                           } else {
                               print("❌ Error al guardar review en Core Data")
                           }
                           
                       case .failure(let error):
                           print("❌ Error al subir foto: \(error.localizedDescription)")
                       }
                   }
               }
    }
    
    
    @IBAction func btnCancelar(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
