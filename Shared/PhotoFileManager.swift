//
//  FileManager.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/11.
//

import UIKit

class PhotoFileManager {
    static let instance = PhotoFileManager() // Singleton instance for easy access
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Determine the scale factor to maintain the aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        // Create a new context with the new size and draw the resized image into it
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image // Fallback to original image if resizing fails
    }

    func savePhoto(image: UIImage, eventID: UUID) -> String? {
        guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.days.events") else {
            print("Error: App Group container not found")
            return nil
        }

        // Resize the image to a target size (e.g., 1024x768 or any other suitable size)
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 1024, height: 768))

        let fileName = "\(eventID).jpg"
        let fileURL = appGroupURL.appendingPathComponent(fileName)

        if let data = resizedImage.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: fileURL)
                print("Successfully saved resized photo at: \(fileURL.path)")
                return fileName
            } catch let error {
                print("Error saving resized image: \(error)")
                return nil
            }
        }
        return nil
    }

    // MARK: Load Photo
    func loadPhoto(fileName: String) -> UIImage? {
        // Use App Group's shared directory
        guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.days.events") else {
            print("Error: App Group container not found")
            return nil
        }
        
        let fileURL = appGroupURL.appendingPathComponent(fileName)
        print("Trying to load photo from path: \(fileURL.path)")
        
        let image = UIImage(contentsOfFile: fileURL.path)
        if image == nil {
            print("Error: Image not found at \(fileURL.path)")
        }
        return image
    }

    // MARK: Delete Photo
    func deletePhoto(fileName: String) {
        guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.days.events") else {
            print("Error: App Group container not found")
            return
        }
        let fileURL = appGroupURL.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Deleted photo from \(fileURL.path)")
        } catch {
            print("Error deleting file: \(error)")
        }
    }
}
