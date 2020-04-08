//  Modified from VisionNative.swift
//  Originally created by Adam Hegedus on 2018.05.23.
//

import Foundation
import AVFoundation
import Vision
import CoreImage

@objc public class VisionNative: NSObject {
    
    // Shared instance
    @objc static let shared = VisionNative()
    
    // Used to cache vision requests to be performed
    private lazy var visionRequests = [VNRequest]()
    
    // Unique serial queue reserved for vision requests
    private let visionRequestQueue = DispatchQueue(label: "si659.unity.visionqueue")
    
    // Used to reatain the pixel buffer when it is passed in as a target to evaulate
    private var retainedBuffer: CVPixelBuffer?
    
    // Id of the managed Unity game object to forward messages to
    private var callbackTarget: String = "Vision"
    
    // Exposed buffer for caching the results of an image classification request
    @objc public var classificationBuffer: [VisionClassification] = []
    private var maxClassificationResults: Int = 1
    
    // Exposed buffer for caching the results of a rectangle recognition request
    @objc public var pointBuffer: [CGPoint] = []
    
    @objc func allocateVisionRequests(requestType: Int, maxObservations: Int)
    {
        // Empty request buffer
        visionRequests.removeAll()
        
        if (requestType == 0) {
            print("[VisionNative] No requests specified.")
            return
        }
        
        // Set up CoreML model
        guard let inception = Inceptionv3()?.model else {
        // guard let inception = Resnet50()?.model else {
            fatalError("[VisionNative] Failed to generate CoreML model.")
        }
        
        guard let mlModel = try? VNCoreMLModel(for: inception) else {
            fatalError("[VisionNative] Unable to load CoreML model.")
        }
        
        // Set up Vision-CoreML request
        let classificationRequest = VNCoreMLRequest(model: mlModel, completionHandler: classificationCompleteHandler)
        
        // Crop from centre of images and scale to appropriate size
        // classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        
        // Set the number of maximum image classifications results specified in Unity
        self.maxClassificationResults = maxObservations
        
        // Register request
        visionRequests.append(classificationRequest)
        print("[VisionNative] Classification request allocated.")
    }
    
    @objc func evaluate(texture: MTLTexture) -> Bool {
        
        // Create an image from the current state of the buffer
        guard let image = CIImage(mtlTexture: texture, options: nil) else { return false }
        
        // Prepare image request
        let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])
        
        visionRequestQueue.async {
            // Run image request
            do {
                try imageRequestHandler.perform(self.visionRequests)
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
        return true
    }
    
    @objc func evaluate(buffer: CVPixelBuffer) -> Bool {
        
        // Retain the buffer
        self.retainedBuffer = buffer;
        
        // Prepare image request
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: self.retainedBuffer!, options: [:])
        
        visionRequestQueue.async {
            // Run image request
            do {
                usleep(500)
                defer { self.retainedBuffer = nil }
                try imageRequestHandler.perform(self.visionRequests)
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
        
        return true
    }
    
    @objc func setCallbackTarget(target: String) {
        // Set the target for unity messaging
        self.callbackTarget = target
    }
    
    private func classificationCompleteHandler(request: VNRequest, error: Error?) {
        
        // Fall back to main thread
        DispatchQueue.main.async {
            
            // Catch errors
            if error != nil {
                let error = "[VisionNative] Error: " + (error?.localizedDescription)!
                UnitySendMessage(self.callbackTarget, "OnClassificationComplete", error)
                return
            }
            
            guard let observations = request.results as? [VNClassificationObservation],
                let _ = observations.first else {
                    UnitySendMessage(self.callbackTarget, "OnClassificationComplete", "No results")
                    return
            }
            
            // Cache classifications
            self.classificationBuffer.removeAll()
            for o in observations.prefix(self.maxClassificationResults) {
                if (o.confidence >= 0.2) {
                    self.classificationBuffer.append(
                    VisionClassification(identifier: o.identifier, confidence:o.confidence))
                } else {
                    self.classificationBuffer.append(
                        VisionClassification(identifier: "Move around to detect an object", confidence: 0.0))
                }
            }
            
            // Call unity object with no errors
            UnitySendMessage(self.callbackTarget, "OnClassificationComplete", "")
        }
    }
    
}
