//
//  MapViewCell.swift
//  WatsonDemo
//
//  Created by RAHUL on 11/21/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import Foundation
import UIKit
import WebImage

class MapViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var mapImageView: UIImageView!
    var imageSizeScale : CGFloat = 1.0

    override func prepareForReuse() {
        mapImageView.image = nil
    }

    func configure(withMessage message: Message) {
        if let imageUrl = message.imageUrl {
            if let sizeScale = Float(message.text!){
                self.imageSizeScale = CGFloat(sizeScale)
            }else{
                self.imageSizeScale = 1.0
            }
            
            mapImageView.setShowActivityIndicator(true)
            mapImageView.sd_setImage(with: imageUrl) { (image, error, imageCacheType, imageUrl) in
                if image != nil {
                    self.mapImageView.image = self.resizeImageWithAspect(image: image!, scaledToMaxWidth: (image?.size.width)!*self.imageSizeScale, maxHeight: (image?.size.height)!*self.imageSizeScale)
                    self.mapImageView.sizeToFit()
                }else
                {
                    print("image not found")
                }
            }            
        }
    }
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async() { () -> Void in
                
                self.mapImageView.image = self.resizeImageWithAspect(image: image, scaledToMaxWidth: (image.size.width)*self.imageSizeScale, maxHeight: (image.size.height)*self.imageSizeScale)
            }
            }.resume()
    }
    
    
    func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage
    {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width:newWidth, height:newHeight);
        
        return resizeImage(image: image, targetSize: newSize)//(image, size: newSize);
    }
    
    
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width:size.width * heightRatio, height:size.height * heightRatio)
        } else {
            newSize = CGSize(width:size.width * widthRatio,  height:size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width:newSize.width, height:newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
        
    
}


extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CellDidLoadImageDidLoadNotification"), object: MapViewCell.self)
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
