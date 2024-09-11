//
//  FileManager.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/11.
//

import UIKit

class PhotoFileManager {
    static let instance = PhotoFileManager() // Singleton instance for easy access
    
    // MARK: Save Photo
    func savePhoto(image: UIImage, eventID: UUID) -> String? {
        
        // Setup document directory -> where to save the photos
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // set file name
        let fileName = "\(eventID).jpg"
        
        // combine document directory and filename as fileURL
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        
        // convert image to jpeg and store it in a variable called "data"
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: fileURL)
                return fileName

            } catch let error {
                print("Error saving images: \(error)")
                return nil
            }
        }
        return nil
    }
    // MARK: Load Photo
    func loadPhoto(fileName: String) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let photoURL = documentsDirectory.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: photoURL.path)
        
    }
    
    // MARK: Delete Photo
    func deletePhoto(fileName: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let photoURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: photoURL)
        } catch {
            print("Error deleting file: \(error)")
        }
        
    }
    
    
}
