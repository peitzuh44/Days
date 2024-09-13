//
//  DaysWidget.swift
//  DaysWidget
//
//  Created by Pei-Tzu Huang on 2024/9/13.
//

import WidgetKit
import SwiftUI
import CoreData
import UIKit

struct Provider: TimelineProvider {
    
    // Placeholder function
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(title: "Event Title", date: Date(), photo: nil)
    }
    
    // Fetch the next event from UserDefaults
    func fetchNextEvent() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.days.events")
        let title = userDefaults?.string(forKey: "NextEventTitle") ?? "No Upcoming Event"
        let date = userDefaults?.object(forKey: "NextEventDate") as? Date ?? Date()
        let photoFileName = userDefaults?.string(forKey: "NextEventPhotoURL")
        
        print("Retrieved title: \(title)")
        print("Retrieved date: \(date)")
        print("Retrieved photo filename from UserDefaults: \(photoFileName ?? "No Photo Filename")")
        
        var photo: UIImage? = nil
        if let fileName = photoFileName {
            photo = PhotoFileManager.instance.loadPhoto(fileName: fileName)
            if photo == nil {
                print("Failed to load photo from file: \(fileName)")
            }
        }

        return SimpleEntry(title: title, date: date, photo: photo)
    }


    // Snapshot for quick preview
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = fetchNextEvent()
        completion(entry)
    }
    
    // Provide a timeline of entries
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = fetchNextEvent()

        // Set the next update time, but the most important part is ensuring it updates the current event
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let title: String
    let date: Date
    let photo: UIImage?
}

struct DaysWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack (alignment: .bottom){
            if let photo = entry.photo {
                         Image(uiImage: photo)
                             .resizable()
                             .aspectRatio(contentMode: .fill)
                             .padding(-20) // Adjust as needed to fit the widget
                     } else {
                         // Fallback background if no photo is available
                         Color.gray
                     }
            ContainerRelativeShape()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0),Color.black.opacity(0.1),  Color.black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                    )
                .padding(-20)
                
            VStack {
                Spacer()
                VStack (alignment: .leading, spacing: 2){
                    Text(entry.title)
                    Text(entry.date.daysFromNow())
                 
                }
                .foregroundStyle(Color.white)
            }
            .padding(.vertical)
        
        }
    }
}

struct DaysWidget: Widget {
    let kind: String = "DaysWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DaysWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DaysWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

// MARK: Save next event to user default


#Preview(as: .systemSmall) {
    DaysWidget()
} timeline: {
    SimpleEntry(title: "Event Title", date: .now, photo: nil)
    SimpleEntry(title: "Event Title", date: .now, photo: nil)
}

extension Date {
    func daysFromNow() -> String {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        let eventDate = calendar.startOfDay(for: self) // Start of the event day
        let components = calendar.dateComponents([.day], from: currentDate, to: eventDate)
        
        guard let dayDifference = components.day else { return "" }
        
        if dayDifference == 0 {
            return "Today".uppercased()
        } else if dayDifference == 1 {
            return "In 1 day".uppercased()
        } else if dayDifference > 1 {
            return "In \(dayDifference) days".uppercased()
        } else if dayDifference == -1 {
            return "\(-dayDifference) day ago".uppercased()
        } else {
            return "\(-dayDifference) days ago".uppercased()
        }
    }
}
