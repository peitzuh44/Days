//
//  EventViewModle.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/11.
//

import Foundation
import CoreData
import UIKit
import SwiftUI


class EventViewModel: ObservableObject {
    let manager = CoreDataManager.instance
    @Published var events: [Event] = []
    
    init(){
        getEvents()
    }
    // Fetching events
    func getEvents() {
        let request = NSFetchRequest<Event>(entityName: "Event")
        do {
            events = try manager.context.fetch(request)
            
        } catch let error {
            print("Error getting events \(error.localizedDescription)")
        }
    }

    // Adding Event
    func addEvent(title: String, date: Date, image: UIImage?) {
        let newEvent = Event(context: manager.context)
        newEvent.id = UUID() // Generate a unique ID for each new event
        newEvent.title = title
        newEvent.date = date
        // Handle saving photo if there is one
        if let image = image {
            if let photoURL = PhotoFileManager.instance.savePhoto(image: image, eventID: newEvent.id ?? UUID()) {
                newEvent.photoURL = photoURL
            }
        }
        save()
    }
    
    func deleteEvent(event: Event) {
        if let fileName = event.photoURL {
            PhotoFileManager.instance.deletePhoto(fileName: fileName)
        }
        manager.context.delete(event)
        save()
    }
    
    func save() {
        manager.save()
        getEvents()
    }
    
    
    
}
