//
//  Date.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/11.
//

import Foundation
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
extension Date {
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self).uppercased()
    }
}
