//
//  ImageDrawing.swift
//  SwiftFortuneWheel-iOS
//
//  Created by Sherzod Khashimov on 7/3/20.
//  Copyright © 2020 SwiftFortuneWheel. All rights reserved.
//

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Image drawing protocol
protocol ImageDrawing {}

extension ImageDrawing {
    func drawMultipleImages(in context: CGContext, images: [SFWImage], preferences: ImagePreferences, rotations: CGFloat, index: Int, topOffset: CGFloat, radius: CGFloat, margins: SFWConfiguration.Margins) {
        let flipAngle: CGFloat = 0
        let step: CGFloat = 10
        var images = images
        //There are maximum 4 images.
        
        // 1 image  -> shift 0
        // 2 images -> shif 5
        // 3 images -> shift 10
        // 4 images -> shift 15
        var shift:CGFloat = 0
        if images.count == 1 {
            shift = 0
        }else if images.count == 2 {
            shift = 5
        }else if images.count == 3 {
            shift = 10
        }else if images.count == 4 {
            shift = 15
        }
        var rotation = rotations - shift
        
        //This reversation make the badge image at the end.
        if preferences.flipUpsideDown {
            images = images.reversed()
        }
        
        for (idx, item) in images.enumerated() {
            context.saveGState()
            context.rotate(by: (flipAngle + rotation) * CGFloat.pi/180)
            
            var image = item
            if let tintColor = preferences.tintColor {
                image = image.withTintColor(tintColor)
            }
            
            let aspectRatioRect = preferences.preferredSize.aspectFit(sizeImage: image.size)
            let yPositionWithoutOffset = radius - preferences.verticalOffset - topOffset - margins.top // This value determine image pos in range ( center - outside). Bigger => Center it's
            
            let flipYOffset: CGFloat = 0
            let yPosition = yPositionWithoutOffset + flipYOffset
            
            let rectangle = CGRect(x: -(aspectRatioRect.size.width / 2), y: -yPosition, width: aspectRatioRect.size.width, height: aspectRatioRect.size.height)
            
            if let backgroundColor = preferences.backgroundColor {
                backgroundColor.setFill()
                context.fill(rectangle)
            }
            
            //Rotation is around the origin. To rotate around another point, translate that point to the origin, rotate, and translate back.
            if preferences.flipUpsideDown {
                let centerX = rectangle.midX
                let centerY = rectangle.midY
                
                context.translateBy(x: centerX, y: centerY)
                context.rotate(by: 180 * CGFloat.pi/180)
                context.translateBy(x: -centerX, y: -centerY)
            }
            
            #if os(macOS)
            image.draw(in: rectangle)
            #else
            image.draw(in: rectangle, blendMode: .normal, alpha: 1)
            #endif
            
            context.restoreGState()
            
            rotation += step
        }
        
        
        
    }
    /// Draws image
    /// - Parameters:
    ///   - context: context where to draw
    ///   - image: UIImage object which needs to be drawn in the context
    ///   - preferences: image preferences
    ///   - rotation: rotation degree
    ///   - index: index
    ///   - topOffset: top offset
    ///   - radius: radius
    ///   - margins: content margins   
    func drawImage(in context: CGContext, image: SFWImage, preferences: ImagePreferences, rotation: CGFloat, index: Int, topOffset: CGFloat, radius: CGFloat, margins: SFWConfiguration.Margins) {
        
        var image = image
        if let tintColor = preferences.tintColor {
            image = image.withTintColor(tintColor)
        }
        
        let flipAngle: CGFloat = 0
        
        context.saveGState()
        context.rotate(by: (flipAngle + rotation) * CGFloat.pi/180)
        
        let aspectRatioRect = preferences.preferredSize.aspectFit(sizeImage: image.size)
        let yPositionWithoutOffset = radius - preferences.verticalOffset - topOffset - margins.top
        let flipYOffset: CGFloat = 0
        let yPosition = yPositionWithoutOffset + flipYOffset
        
        let rectangle = CGRect(x: -(aspectRatioRect.size.width / 2), y: -yPosition, width: aspectRatioRect.size.width, height: aspectRatioRect.size.height)
        
        if let backgroundColor = preferences.backgroundColor {
            backgroundColor.setFill()
            context.fill(rectangle)
        }
        
        //        Rotation is around the origin. To rotate around another point, translate that point to the origin, rotate, and translate back.
        if preferences.flipUpsideDown {
            let centerX = rectangle.midX
            let centerY = rectangle.midY
            
            context.translateBy(x: centerX, y: centerY)
            context.rotate(by: 180 * CGFloat.pi/180)
            context.translateBy(x: -centerX, y: -centerY)
        }
        
        #if os(macOS)
        image.draw(in: rectangle)
        #else
        image.draw(in: rectangle, blendMode: .normal, alpha: 1)
        #endif
        
        context.restoreGState()
        
    }
    
    
    /// Draws anchor image
    /// - Parameters:
    ///   - context: context where to draw
    ///   - imageAnchor: anchor image
    ///   - rotation: rotation degree
    ///   - index: index
    ///   - radius: radius
    ///   - sliceDegree: Slice degree
    ///   - rotationOffset: Rotation offset
    func drawAnchorImage(in context: CGContext, imageAnchor: SFWConfiguration.AnchorImage, isCentered: Bool, rotation: CGFloat, index: Int, radius: CGFloat, sliceDegree: CGFloat, rotationOffset: CGFloat) {
        
        //// Context setup
        context.saveGState()
        // Coordinate now start from center
        context.translateBy(x: rotationOffset, y: rotationOffset)
        
        guard var image = SFWImage(named: imageAnchor.imageName) else {
            context.restoreGState()
            return
        }
        
        if let tintColor = imageAnchor.tintColor {
            image = image.withTintColor(tintColor)
        }
        
        let centeredOffset: CGFloat = isCentered ? sliceDegree / 2 : 0
        let contextPositionCorrectionOffsetDegree: CGFloat = -sliceDegree / 2 + imageAnchor.rotationDegreeOffset + centeredOffset
        
        context.saveGState()
        context.rotate(by: (rotation + contextPositionCorrectionOffsetDegree) * CGFloat.pi/180)
        
        let yPosition: CGFloat = radius - imageAnchor.verticalOffset
        let xPosition: CGFloat = imageAnchor.size.width / 2
        
        let rectangle = CGRect(x: -xPosition, y: -yPosition, width: imageAnchor.size.width, height: imageAnchor.size.height)
        
        #if os(macOS)
        image.draw(in: rectangle)
        #else
        image.draw(in: rectangle, blendMode: .normal, alpha: 1)
        #endif
        
        context.restoreGState()
        context.restoreGState()
    }
    
}
