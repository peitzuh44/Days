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
import WidgetKit
class EventViewModel: ObservableObject {
    let manager = CoreDataManager.instance
    @Published var events: [Event] = []
    @Published var selectedSegment: Int = 0 // 0 for upcoming, 1 for past
    
    init() {
        getUpcomingEvents()
    }
    // Fetching all events (used in init only for now)
    func getEvents() {
        let request = NSFetchRequest<Event>(entityName: "Event")
        do {
            events = try manager.context.fetch(request)
        } catch let error {
            print("Error getting events \(error.localizedDescription)")
        }
        saveNextEventToUserDefaults()
        WidgetCenter.shared.reloadTimelines(ofKind: "DaysWidget")

    }

    // Fetching upcoming events (those happening in the future or today)
    func getUpcomingEvents() {
        let request = NSFetchRequest<Event>(entityName: "Event")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let today = Calendar.current.startOfDay(for: Date()) // Start of today
        let predicate = NSPredicate(format: "date >= %@", today as NSDate)
        request.predicate = predicate
        
        do {
            events = try manager.context.fetch(request)
        } catch let error {
            print("Error getting upcoming events \(error.localizedDescription)")
        }
        saveNextEventToUserDefaults()
    }

    // Fetching past events (those that already happened before today)
    func getPastEvents() {
        let request = NSFetchRequest<Event>(entityName: "Event")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        let today = Calendar.current.startOfDay(for: Date()) // Start of today
        let predicate = NSPredicate(format: "date < %@", today as NSDate)
        request.predicate = predicate
        
        do {
            events = try manager.context.fetch(request)
        } catch let error {
            print("Error getting past events \(error.localizedDescription)")
        }
        saveNextEventToUserDefaults()
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
        saveNextEventToUserDefaults()

        // Trigger widget reload
        print("Widget reload triggered.")
        WidgetCenter.shared.reloadTimelines(ofKind: "DaysWidget")
    }


    // Deleting Event
    func deleteEvent(event: Event) {
        if let fileName = event.photoURL {
            PhotoFileManager.instance.deletePhoto(fileName: fileName)
        }
        manager.context.delete(event)
        save()
    }

    // Save function
    func save() {
        manager.save()
        
        // Fetch events based on the selected segment (upcoming or past)
        if selectedSegment == 0 {
            getUpcomingEvents()
        } else {
            getPastEvents()
        }
    }
    
    func saveNextEventToUserDefaults() {
        let userDefaults = UserDefaults(suiteName: "group.com.days.events")
        
        let request: NSFetchRequest<Event> = Event.fetchRequest()

        // Get the start and end of today
        let todayStart = Calendar.current.startOfDay(for: Date()) // Midnight today
        let tomorrowStart = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)! // Midnight tomorrow
        
        // First, fetch events happening today (from todayStart to just before tomorrowStart)
        let todayPredicate = NSPredicate(format: "date >= %@ AND date < %@", todayStart as NSDate, tomorrowStart as NSDate)
        request.predicate = todayPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.fetchLimit = 1
        
        do {
            let todayEvents = try manager.container.viewContext.fetch(request)
            
            if let todayEvent = todayEvents.first {
                // Save today's event to UserDefaults
                userDefaults?.set(todayEvent.title, forKey: "NextEventTitle")
                userDefaults?.set(todayEvent.date, forKey: "NextEventDate")
                userDefaults?.set(todayEvent.photoURL, forKey: "NextEventPhotoURL")
                print("Today's event saved: \(todayEvent.title ?? "No Title"), Date: \(todayEvent.date ?? Date()), PhotoURL: \(todayEvent.photoURL ?? "No Photo")")
            } else {
                // If no event is found today, fetch the upcoming events (starting tomorrow)
                let futurePredicate = NSPredicate(format: "date >= %@", tomorrowStart as NSDate)
                request.predicate = futurePredicate
                
                let futureEvents = try manager.container.viewContext.fetch(request)
                
                if let nextEvent = futureEvents.first {
                    // Save the next upcoming event to UserDefaults
                    userDefaults?.set(nextEvent.title, forKey: "NextEventTitle")
                    userDefaults?.set(nextEvent.date, forKey: "NextEventDate")
                    userDefaults?.set(nextEvent.photoURL, forKey: "NextEventPhotoURL")
                    print("Next event saved: \(nextEvent.title ?? "No Title"), Date: \(nextEvent.date ?? Date()), PhotoURL: \(nextEvent.photoURL ?? "No Photo")")
                } else {
                    // If there are no upcoming events, save "No Events" as the default
                    userDefaults?.set("No Events", forKey: "NextEventTitle")
                    userDefaults?.set(nil, forKey: "NextEventDate")
                    userDefaults?.set(nil, forKey: "NextEventPhotoURL")
                    print("No upcoming events found.")
                }
            }
        } catch {
            print("Failed to fetch event: \(error)")
        }
    }



}
