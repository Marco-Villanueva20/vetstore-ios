//
//  AgregarMascotaViewController.swift
//  vet store
//
//  Created by Jacktter on 27/08/25.
//

import UIKit

class AgregarMascotaViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    let mascotaService = MascotaService()

    @IBOutlet weak var ivFotoMascota: UIImageView!
    @IBOutlet weak var txtRaza: UITextField!
    @IBOutlet weak var txtPrecio: UITextField!
    @IBOutlet weak var txtCantMachos: UITextField!
    @IBOutlet weak var txtCantHembras: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ivFotoMascota.isUserInteractionEnabled = true
        ivFotoMascota.layer.cornerRadius = 8
        ivFotoMascota.layer.borderWidth = 1
        ivFotoMascota.layer.borderColor = UIColor.gray.cgColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
                ivFotoMascota.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    
    @objc func selectImage() {
           let picker = UIImagePickerController()
           picker.delegate = self
           picker.sourceType = .photoLibrary // también podrías usar .camera
           present(picker, animated: true)
       }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
           if let imagen = info[.originalImage] as? UIImage {
               ivFotoMascota.image = imagen
           }
           picker.dismiss(animated: true)
       }

   
    @IBAction func btnAgregar(_ sender: UIButton) {
        // 1. Validar que haya una imagen seleccionada
          guard let imagen = ivFotoMascota.image else {
              AlertHelper.showAlert(on: self, title: "Error", message: "Selecciona una foto antes de agregar.")
              return
          }
          
          // 2. Validar los campos
          guard let raza = txtRaza.text, !raza.isEmpty else {
              AlertHelper.showAlert(on: self, title: "Error", message: "El campo Raza no puede estar vacío.")
              return
          }
          
          // 👉 Usamos ValidationHelper para cada campo
          let precioResult = ValidationHelper.parseDouble(txtPrecio.text, nombreCampo: "Precio")
          let machosResult = ValidationHelper.parseInt(txtCantMachos.text, nombreCampo: "Cantidad de Machos")
          let hembrasResult = ValidationHelper.parseInt(txtCantHembras.text, nombreCampo: "Cantidad de Hembras")
          
          // 3. Evaluar resultados
          switch (precioResult, machosResult, hembrasResult) {
          case (.success(let precio), .success(let cantMachos), .success(let cantHembras)):
              
              // 4. Subir la foto a Supabase
              let fileName = "mascota_\(UUID().uuidString)" // nombre único
              mascotaService.uploadFotoMascota(fileName: fileName, image: imagen) { result in
                  DispatchQueue.main.async {
                      switch result {
                      case .success(let urlFoto):
                          print("✅ Foto subida. URL: \(urlFoto)")
                          
                          // 5. Crear objeto Mascota con la URL de la foto
                          let nuevaMascota = Mascota(
                              codigo: 0,
                              raza: raza,
                              precio: precio,
                              cantidadMachos: Int16(cantMachos),
                              cantidadHembras: Int16(cantHembras),
                              foto: urlFoto
                          )
                          
                          // 6. Guardar en Core Data
                          let ok = self.mascotaService.addMascota(mascota: nuevaMascota)
                          if ok {
                              AlertHelper.showAlert(on: self, title: "Éxito", message: "Mascota guardada correctamente.")
                              self.dismiss(animated: true)
                          } else {
                              AlertHelper.showAlert(on: self, title: "Error", message: "Hubo un problema al guardar la mascota.")
                          }
                          
                      case .failure(let error):
                          AlertHelper.showAlert(on: self, title: "Error", message: "Error al subir foto: \(error.localizedDescription)")
                      }
                  }
              }
              
          // 7. Manejo de errores de validación
          case (.failure(let error), _, _),
               (_, .failure(let error), _),
               (_, _, .failure(let error)):
              AlertHelper.showAlert(on: self, title: "Error", message: error.mensaje)
          }
    }
    
    @IBAction func btnCancelar(_ sender: UIButton) {
        AlertHelper.showConfirmation(
                on: self,
                title: "Cancelar Agregar Mascota",
                message: "¿Estás seguro de que deseas cancelar?",
                confirmTitle: "Sí, cancelar",
                cancelTitle: "No"
            ) {
                // Acción cuando confirma cancelar
                self.dismiss(animated: true)
            }
        }

}
