//
//  CoreDataManager.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/11.
//

import Foundation
import CoreData


class CoreDataManager: ObservableObject {
    
    static let instance = CoreDataManager()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading persistent container \(error)")
            }
        }
        
        context = container.viewContext
    }
    
    // MARK: Save function
    func save() {
        
        do {
            try context.save()
        } catch let error {
            print("Error saving to core data \(error.localizedDescription)")
        }
        
    }
    


    
}
