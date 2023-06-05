//
//  ReadingViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/05/27.
//

import UIKit
import OHCubeView

class ReadingViewController: UIViewController {
    
    var tapCount : Int = 0
    let loadedVideoSearchArray = DataStore.shared.loadedVideoSearchArray // 데이터 읽어오기

    @IBOutlet weak var cubeView: OHCubeView!
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: view.bounds)
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 1. Create subviews for our cube view (in this case, five image views)
                
        let iv1 = UIImageView(image: UIImage(named: "Image"))
        let iv2 = UIImageView(image: UIImage(named: "Ellipse Black"))
        let iv3 = UIImageView(image: UIImage(named: "Ellipse Red"))
        let iv4 = UIImageView(image: UIImage(named: "Ellipse Orange"))
        let iv5 = UIImageView(image: UIImage(named: "Ellipse Black"))
        
        // 2. Add all subviews to the cube view
        
        cubeView.addChildViews([iv1, iv2, iv3, iv4, iv5])

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let firstArray = loadedVideoSearchArray[0]
        imageViewSet(firstArray: firstArray)
        
    }
    
    @IBAction func tapGesture(_ sender: UIGestureRecognizer) {
        print("tap!")
        
        let tapLocation = sender.location(in: self.view)
            let centerX = self.view.bounds.midX
            if tapLocation.x < centerX {
                tapCount -= 1
            } else {
                tapCount += 1
            }

        let firstArray = loadedVideoSearchArray[tapCount]
        var imageUrl = firstArray[0].thumbnailUrl
        
        imageViewSet(firstArray: firstArray)
        
        self.view.endEditing(true)
    }
    
    
}

extension ReadingViewController {
    func imageViewSet(firstArray : [APIData.webVideoSearch]){
        var imageUrl = firstArray[0].thumbnailUrl
        var imageWidth = firstArray[0].width
        var imageHeight = firstArray[0].height
        var inputDate = firstArray[0].datePublished
        var context = firstArray[0].name
        
        let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Error: No image data.")
                return
            }
            // 다운로드한 데이터를 UIImage로 변환
            guard let image = UIImage(data: data) else {
                print("Error: Cannot convert data to image.")
                return
            }
            
            let noiseReducedImage = self.Image_ReduceNoise(image: image)
            let sharpnessEnhancedImage = self.Image_EnhanceSharpness(image: noiseReducedImage!)
                        
            // UI 업데이트는 메인 스레드에서 처리
            DispatchQueue.main.async {

                let backgroundImageView = UIImageView(image: sharpnessEnhancedImage!)
                backgroundImageView.contentMode = .scaleAspectFill
                //backgroundImageView.clipsToBounds = true

                let blurEffect = UIBlurEffect(style: .dark)
                let viewBlurEffect = UIVisualEffectView(effect: blurEffect)

                backgroundImageView.frame = self.view.bounds
                viewBlurEffect.frame = backgroundImageView.frame

                for subview in backgroundImageView.subviews {
                    subview.removeFromSuperview()
                }

                self.containerView.addSubview(backgroundImageView)
                self.containerView.addSubview(viewBlurEffect)
                
                self.view.addSubview(self.containerView)
                self.view.sendSubviewToBack(self.containerView)
                
                self.imageView.image = image
                
                //self.cubeView.addSubview(self.imageView) // 다음 키워드로 넘기기
                
                //cell.contentTextView.contentOffset = .zero
                
                // 이미지 축소 및 적절한 contentMode 설정
//                if imageWidth == 0 || imageHeight == 0 {
//                    imageWidth = Int(cell.superview!.frame.width)
//                    imageHeight = Int(cell.superview!.frame.height)
//                    let imageSize = CGSize(width: imageWidth, height: imageHeight)
//                    let imageViewSize = cell.thumbnailImageView.frame.size
//                    let scaledImageSize = imageSize.aspectFit(to: imageViewSize)
//                    cell.thumbnailImageView.frame.size = scaledImageSize
//                }
                
            }
        }
        task.resume()
    }
}



