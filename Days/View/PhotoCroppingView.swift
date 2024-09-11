//
//  PhotoCroppingView.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/11.
//

import SwiftUI
import PhotosUI
import SwiftUI

struct ImageCropperView: View {
    let image: UIImage
    @Binding var croppedImage: UIImage? // Bind the cropped image to be returned

    @State private var isCroppingDone = false // Track if cropping is done
    
    var body: some View {
        VStack {
            // Display the image to crop
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    Rectangle() // A simple cropping overlay
                        .strokeBorder(Color.white, lineWidth: 2)
                        .padding()
                )
            
            // Save the cropped image
            Button("Save Cropped Image") {
                croppedImage = cropImage(image: image)
                isCroppingDone = true
            }
            .padding()
        }
        .onChange(of: isCroppingDone) { done in
            if done {
                // Dismiss the view when done
                isCroppingDone = false
            }
        }
    }
    
    // Cropping logic (example: simple square crop from center)
    private func cropImage(image: UIImage) -> UIImage? {
        let sideLength = min(image.size.width, image.size.height)
        let size = CGSize(width: sideLength, height: sideLength)
        let origin = CGPoint(x: (image.size.width - sideLength) / 2, y: (image.size.height - sideLength) / 2)
        let cropRect = CGRect(origin: origin, size: size)
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
