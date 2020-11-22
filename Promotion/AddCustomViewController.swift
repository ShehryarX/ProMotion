//
//  AddCustomViewController.swift
//  Promotion
//
//  Created by Temp on 2020-11-22.
//

import UIKit

class AddCustomViewController: UIViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var uploadStuffButton: UIButton!
    var imagePicker = UIImagePickerController()



    @IBAction func btnZction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
            uploadStuffButton.setTitle("Selected 1 video", for: .normal)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
