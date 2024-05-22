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
        unsharpMaskFilter.setValue(5.0, forKey: kCIInputRadiusKey) // 얼마나 넓게 선명도를 적용할지를 결정합니다. 값이 클수록 더 넓은 영역에 선명도가 적용됩니다. 일반적으로 0.5 ~ 5.0 사이의 값을 사용합니다. 값이 작을수록 더 선명해지고, 값이 클수록 더 흐릿해집니다.
        unsharpMaskFilter.setValue(0.1, forKey: kCIInputIntensityKey) // 얼마나 강하게 선명도를 적용할지를 결정합니다. 값이 클수록 더 강한 선명도가 적용됩니다. 일반적으로 0.0 ~ 1.0 사이의 값을 사용합니다. 값이 0에 가까울수록 더 흐릿해지고, 값이 1에 가까울수록 더 선명해집니다.
        
        guard let outputCIImage = unsharpMaskFilter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func Image_ReduceNoise(image: UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        guard let noiseReductionFilter = CIFilter(name: "CINoiseReduction") else { return nil }
        let ciImage = CIImage(image: image)
        
        noiseReductionFilter.setValue(ciImage, forKey: kCIInputImageKey)
        noiseReductionFilter.setValue(0.02, forKey: "inputNoiseLevel") // 노이즈를 얼마나 강하게 줄일지를 결정합니다. 값이 클수록 노이즈가 더 강하게 제거됩니다. 일반적으로 0.0 ~ 0.1 사이의 값을 사용합니다. 값이 작을수록 노이즈가 적게 제거되고, 값이 클수록 더 많은 노이즈가 제거됩니다.
        noiseReductionFilter.setValue(0.02, forKey: "inputSharpness") // 이미지의 선명도를 조절합니다. 값이 클수록 더 선명한 이미지가 됩니다. 일반적으로 0.0 ~ 0.1 사이의 값을 사용합니다. 값이 작을수록 이미지가 더 흐릿해지고, 값이 클수록 더 선명해집니다.
        
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

