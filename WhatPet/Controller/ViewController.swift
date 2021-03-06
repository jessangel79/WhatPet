//
//  ViewController.swift
//  WhatPet
//
//  Created by Angelique Babin on 12/04/2021.
//

import UIKit
import CoreML
import Vision
import SDWebImage

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private let wikiService = WikiService()
    private var imageDefault: UIImage?

    // MARK: - Actions
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setImagePicker()
    }
    
    // MARK: - Methods
    
    private func getPetDescription(petName: String) {
        wikiService.getPetDescription(petName: petName) { [self] (_, result) in
            guard let result = result else { return }
            if result.isEmpty {
                descriptionTextView.text = "Sorry no description available !"
            } else {
                descriptionTextView.text = result.first
                guard let imageResult = result.last else { return }
                imageView.sd_setImage(with: URL(string: imageResult), placeholderImage: imageDefault)
                print(result)
            }
        }
    }
}

// MARK: - Extension UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            imageView.image = userPickedImage
            imageDefault = userPickedImage
            guard let convertedCIImage = CIImage(image: userPickedImage) else { return }
            detect(petImage: convertedCIImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    private func setImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    private func detect(petImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: PetImageClassifier(configuration: .init()).model) else { return }

        let request = VNCoreMLRequest(model: model) { [self] (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("Could not classify image.")
            }
            navigationItem.title = classification.identifier.capitalized
            getPetDescription(petName: classification.identifier)
            print(classification.identifier.capitalized)

//            guard let results = request.results as? [VNClassificationObservation] else { return }
//            if let firstResult = results.first {
//                self.navigationItem.title = firstResult.identifier.capitalized
//            }

            print(request.results?[0] ?? "Error 0", request.results?[1] ?? "Error 1", request.results?[2] ?? "Error 2")
        }

        let handler = VNImageRequestHandler(ciImage: petImage)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}
