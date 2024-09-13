//
//  EventItem.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/10.
//

import SwiftUI

struct EventItem: View {
    var namespace: Namespace.ID // Accept shared namespace as a parameter
    var event: Event
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0),Color.black.opacity(0.1),  Color.black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, maxHeight: 350)
            VStack {
                Spacer()
                VStack{
                    Text((event.date?.daysFromNow() ?? ""))
                        .font(.title3)
                        .matchedGeometryEffect(id: "CalculatedDays-\(String(describing: event.id))", in: namespace)
                    Text(event.title ?? "")
                        .font(.largeTitle)
                        .bold()
                        .matchedGeometryEffect(id: "title-\(String(describing: event.id))", in: namespace)
                    
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical)
            }
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .background(
            loadImageFromEvent(event) // Load image as background
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 350)
        )
        .matchedGeometryEffect(id: "background-\(event.id)", in: namespace)
        .mask {
            RoundedRectangle(cornerRadius: 25.0)
        }
    }
    
    // Function to load image from the event's photoURL
    func loadImageFromEvent(_ event: Event) -> Image {
        if let fileName = event.photoURL {
            if let uiImage = PhotoFileManager.instance.loadPhoto(fileName: fileName) {
                return Image(uiImage: uiImage) // Load image from file
            }
        }
        return Image("defaultImage") // Fallback to a default image if no photoURL or loading fails
    }
}
