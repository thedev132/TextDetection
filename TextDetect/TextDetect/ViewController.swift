//
//  ViewController.swift
//  TextDetect
//
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate {

    var scannedText = ""
    let documentCameraViewController = VNDocumentCameraViewController()
    var textRecognitionRequest = VNRecognizeTextRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.frame = view.frame
        view.addSubview(label)
        documentCameraViewController.delegate = self
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: detectedTextHandler)
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.revision = VNRecognizeTextRequestRevision1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.documentCameraViewController.modalPresentationStyle = .fullScreen
            self.present(UINavigationController(rootViewController: self.documentCameraViewController) , animated: true)
            
        }
        
    }
    
    private var label: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping          
        label.font = UIFont(name: "ArialMT", size: 25)
        return label
    }()
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true) {
            DispatchQueue.main.async {
                let image = scan.imageOfPage(at: 0)
                self.recognizeTextInImage(image)
            }
        }
    }

    private func recognizeTextInImage(_ image: UIImage?) {
        guard let cgImage = image?.cgImage else {return}
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([textRecognitionRequest])
        }
        catch {return}
    }
    
    private func detectedTextHandler(request: VNRequest?, error: Error?) {
        guard let results = request?.results, !results.isEmpty else {return}
        
        for result in results {
            guard let observation = result as? VNRecognizedTextObservation else { return }
            guard let candidiate = observation.topCandidates(1).first else { return }
            
            do {
                scannedText.append(contentsOf: "\(candidiate.string) \n")
            }
        }
        label.text = scannedText
    }
}


   
