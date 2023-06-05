//
//  ImageExtension.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/25.
//

import UIKit
import CoreImage

extension UIViewController {
    func Image_ResizeImage(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func Image_ApplyFilterToImage(image: UIImage, filterName: String) -> UIImage? {
        guard let filter = CIFilter(name: filterName) else { return nil }
        let ciImage = CIImage(image: image)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        let context = CIContext(options: nil)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }

    func Image_EnhanceSharpness(image: UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        guard let unsharpMaskFilter = CIFilter(name: "CIUnsharpMask") else { return nil }
        let ciImage = CIImage(image: image)
        
        unsharpMaskFilter.setValue(ciImage, forKey: kCIInputImageKey)
        unsharpMaskFilter.setValue(2.5, forKey: kCIInputRadiusKey)
        unsharpMaskFilter.setValue(0.5, forKey: kCIInputIntensityKey)
        
        guard let outputCIImage = unsharpMaskFilter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func Image_ReduceNoise(image: UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        guard let noiseReductionFilter = CIFilter(name: "CINoiseReduction") else { return nil }
        let ciImage = CIImage(image: image)
        
        noiseReductionFilter.setValue(ciImage, forKey: kCIInputImageKey)
        noiseReductionFilter.setValue(0.02, forKey: "inputNoiseLevel")
        noiseReductionFilter.setValue(0.02, forKey: "inputSharpness")
        
        guard let outputCIImage = noiseReductionFilter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }

}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

