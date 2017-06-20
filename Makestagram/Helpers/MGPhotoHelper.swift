//
//  MGPhotoHelper.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/20/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

class MGPhotoHelper: NSObject {
    
    // MARK: - Properties
    var completionHandler: ((UIImage) -> Void)?
    
    // MARK: - Helper Methods
    func presentActionSheet(from viewController: UIViewController) {
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your photo from?", preferredStyle: .actionSheet)
        
        // option for user to take photo, if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {action in
                // handler will execute when this action is selected
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            
            alertController.addAction(capturePhotoAction)
        }
        
        // option for user to use photo from library, if photo library is available
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Upload from library", style: .default, handler: { action in
                // handler will execute when this action is selected
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            
            alertController.addAction(uploadAction)
        }
        
        // cancel, if user doesn't want to upload photo
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // show photo picker alert
        viewController.present(alertController, animated: true)
    }
    
    func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
        // create instance of ImagePickerController and set the source type to get UI we want (camera overlay or photo library)
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        viewController.present(imagePickerController, animated: true)
    }

}

// MARK: - Extension(s)
extension MGPhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // if there is an image, pass it to the completion handler
            completionHandler?(selectedImage)
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
