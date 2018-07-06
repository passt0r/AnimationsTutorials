/*
* Copyright (c) 2014-2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import QuartzCore

class ViewController: UIViewController {
  
  let images = [
    ImageViewCard(imageNamed: "Hurricane_Katia.jpg", title: "Hurricane Katia"),
    ImageViewCard(imageNamed: "Hurricane_Douglas.jpg", title: "Hurricane Douglas"),
    ImageViewCard(imageNamed: "Hurricane_Norbert.jpg", title: "Hurricane Norbert"),
    ImageViewCard(imageNamed: "Hurricane_Irene.jpg", title: "Hurricane Irene")
  ]
    
    var isGalleryOpen: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.black
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "info", style: .done, target: self, action: #selector(info))
  }
  
  func info() {
    let alertController = UIAlertController(title: "Info", message: "Public Domain images by NASA", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    present(alertController, animated: true, completion: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    for image in images {
        image.layer.anchorPoint.y = 0.0
        image.frame = view.bounds
        image.didSelect = selectImage(_:)
        view.addSubview(image)
    }
    navigationItem.title = images.last?.title
    
    var perspective = CATransform3DIdentity
    perspective.m34 = -1.0 / 250
    view.layer.sublayerTransform = perspective
  }
    
    private func selectImage(_ selectedImage: ImageViewCard) {
        for subview in view.subviews {
            guard let image = subview as? ImageViewCard else {
                continue
            }
            if image == selectedImage {
                UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseIn, animations: {
                    image.layer.transform = CATransform3DIdentity
                }) { (_) in
                    self.view.bringSubview(toFront: image)
                }
            } else {
                UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseIn, animations: {
                    image.alpha = 0.0
                }) { (_) in
                    image.alpha = 1.0
                    image.layer.transform = CATransform3DIdentity
                }
            }
            self.navigationItem.title = selectedImage.title
            self.isGalleryOpen = false
        }
    }
  
  @IBAction func toggleGallery(_ sender: AnyObject) {
    
    var imageYOffset: CGFloat = 50.0
    
    for subview in view.subviews {
        guard let image = subview as? ImageViewCard else {
            continue
        }
        
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0.0, imageYOffset, 0.0)
        transform = CATransform3DScale(transform, 0.95, 0.6, 1.0)
        transform = CATransform3DRotate(transform, CGFloat(M_PI_4/2), -1.0, 0.0, 0.0)
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: image.layer.transform)
        animation.toValue = NSValue(caTransform3D: isGalleryOpen ?
                                                CATransform3DIdentity :
                                                transform)
        
        animation.duration = 0.33
        image.layer.add(animation, forKey: nil)
        
        image.layer.transform = isGalleryOpen ?
                                CATransform3DIdentity :
                                transform
        
        imageYOffset += view.frame.height / CGFloat(images.count)
    }
    isGalleryOpen = !isGalleryOpen
    
  }
  
}
