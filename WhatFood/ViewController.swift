//
//  ViewController.swift
//  WhatFood
//
//  Created by Ebubechukwu Dimobi on 25.07.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        responseLabel.isHidden = true
        answerLabel.text = nil
        answerLabel.isHidden = true
        
        imagePicker.delegate = self
        //imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
    }
    
    
    
    @IBAction func camerTapped(_ sender: UIBarButtonItem) {
        
        let actionsheet = UIAlertController(title: "Photo Source", message: "Choose A Source", preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }else
            {
                print("Camera is Not Available")
            }
        }))
        actionsheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction)in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionsheet,animated: true, completion: nil)
        
        present(imagePicker, animated: true)
    }
    
    @IBAction func refreshButtonClicked(_ sender: UIBarButtonItem) {
        
        imageView.image = nil
        responseLabel.isHidden = true
        answerLabel.text = nil
        answerLabel.isHidden = true
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
              imageView.image = userPickedimage
              
            guard let ciimage = CIImage(image: userPickedimage) else{
                fatalError("Could not convert to CIImage")
            }
            
            detect(with: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(with image: CIImage){
        
        do{
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            
            let request = VNCoreMLRequest(model: model) { (request, error) in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("Could not process request")
                }
                
                print(results[0].identifier)
                self.answerLabel.isHidden = false
                self.answerLabel.text = results[0].identifier
                self.responseLabel.isHidden = false
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            try handler.perform([request])
        }catch{
            print("error while processing image\(error)")
        }
        
        
        
        
    }
    
}
