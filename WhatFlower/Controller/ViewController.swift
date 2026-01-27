//
//  ViewController.swift
//  WhatFlower
//
//  Created by Antonio Hernández Santander on 25/01/26.
//

import UIKit
import CoreImage
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage")
            }
            
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: flower_classifier().model) else {
            fatalError("Loading CoreML model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let classifications = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to precess image.")
            }
            print(classifications)
            self.navigationItem.title = classifications.first?.identifier
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    
    
    //MARK: - FlowerManager Delegate
    extend class ViewController: FlowerManagerDelegate {
        func didUpdateFlowers(_ flowerManager: FlowerManager, flowerModel: FlowerModel) {
            print(flowerModel.title)
            print(flowerModel.extract)
        }
        
        func didFailWithError(error: any Error) {
            print("ERROR: \(error)")
        }
    }
}

