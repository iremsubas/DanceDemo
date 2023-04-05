//
//  Predictor.swift
//  DanceDemo
//
//  Created by İremsu  Baş  on 11.04.2023.
//

import Foundation
import Vision

protocol PredictorDelegate: AnyObject {
    func predictor(_ predictor: Predictor, didFindNewRecognizedPoints points: [CGPoint])
}

class Predictor {
    
    weak var delegate: PredictorDelegate?
    
    func estimation(sampleBuffer: CMSampleBuffer) {
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform request, with error: \(error)")
        }
    }
    
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        observations.forEach {
            processObservation($0)
        }
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        do {
            let recognizedPoints = try observation.recognizedPoints(forGroupKey: .all)
            
            let filteredPoints = recognizedPoints.filter { recognizedPoint in
                recognizedPoint.value.score > 0.3 // adjust threshold as needed
            }

            let displayedPoints = filteredPoints.map { recognizedPoint in
                let point = recognizedPoint.value.location
                return CGPoint(x: point.x, y: 1 - point.y)
            }
            
            delegate?.predictor(self, didFindNewRecognizedPoints: displayedPoints)
        } catch {
            print("Error finding recognized points")
        }
    }
}
