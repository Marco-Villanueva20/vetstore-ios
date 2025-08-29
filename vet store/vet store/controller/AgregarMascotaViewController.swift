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
               print("❌ Selecciona una foto antes de agregar.")
               return
           }
           
           // 2. Validar los demás campos
           guard let raza = txtRaza.text, !raza.isEmpty,
                 let precioTexto = txtPrecio.text, let precio = Double(precioTexto),
                 let cantMachosTexto = txtCantMachos.text, let cantMachos = Int16(cantMachosTexto),
                 let cantHembrasTexto = txtCantHembras.text, let cantHembras = Int16(cantHembrasTexto) else {
               print("❌ Rellena todos los campos.")
               return
           }
           
           // 3. Subir la foto a Supabase
           let fileName = "mascota_\(UUID().uuidString)" // nombre único
           mascotaService.uploadFotoMascota(fileName: fileName, image: imagen) { result in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let urlFoto):
                       print("✅ Foto subida. URL: \(urlFoto)")
                       
                       // 4. Crear objeto Mascota con la URL de la foto
                       let nuevaMascota = Mascota(
                           codigo: 0, // CoreData generará el código automáticamente
                           raza: raza,
                           precio: precio,
                           cantidadMachos: cantMachos,
                           cantidadHembras: cantHembras,
                           foto: urlFoto
                       )
                       
                       // 5. Guardar en Core Data
                       let ok = self.mascotaService.addMascota(mascota: nuevaMascota)
                       if ok {
                           print("✅ Mascota guardada en Core Data")
                           self.dismiss(animated: true) // Cerrar la pantalla
                       } else {
                           print("❌ Error al guardar mascota en Core Data")
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
