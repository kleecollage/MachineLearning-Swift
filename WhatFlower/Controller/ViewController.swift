//
//  ViewController.swift
//  WhatFlower
//
//  Created by Antonio Hernández Santander on 25/01/26.
//

import UIKit
import CoreImage
import Vision
import AlamoFire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let wikipediaUrl = "https://en.wikipedia.org/w/api.php"
    
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
            guard let classification = request.results.first as? [VNClassificationObservation] else {
                fatalError("Model failed to precess image.")
            }
            print(classification)
            self.navigationItem.title = classification.identifier.capitalized
            self.requestInfo(flowerName: classification.identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func requestInfo(flowerName: String) {
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            “indexpageids” : "",
            "redirects" : "1",
            ]

        Alamofire.request(url: wikipediaUrl, method: .get, parameters: parameters).resposeJSON { response in
            if response.result.isSuccess {
                print("Got the wikipedia info.")
                print(response)
                
                let flowerJSON: JSON = JSON(response.result.value)
                let pageId = flowerJSON["query"]["pageid"][0].stringValue
                let extract = flowerJSON["query"]["pages"][pageId]["extract"].stringValue
                
                
            }
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

