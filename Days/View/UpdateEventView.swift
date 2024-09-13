//
//  UpdateEventView.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/13.
//

import SwiftUI
import PhotosUI

struct UpdateEventView: View {
    
    // Pass in the selected event
    var selectedEvent: Event
    @Binding var showDetail: Bool
    @StateObject private var photoPicker = PhotoPicker()
    @ObservedObject var viewModel: EventViewModel // Injected EventViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var date: Date = Date()
    
    init(selectedEvent: Event, viewModel: EventViewModel, showDetail: Binding<Bool>) {
        self.selectedEvent = selectedEvent
        self.viewModel = viewModel
        self._showDetail = showDetail
        _title = State(initialValue: selectedEvent.title ?? "")
        _date = State(initialValue: selectedEvent.date ?? Date())
        
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Event title", text: $title)
                DatePicker("Event date", selection: $date, displayedComponents: .date)
                
                // PhotosPicker to select an image
                PhotosPicker(selection: $photoPicker.imageSelection, matching: .images) {
                    Text("Select a photo")
                }

                // Display selected image
                if let image = photoPicker.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                }
            }
            .navigationTitle("Edit Event")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Check if there is a selected image and pass it to addEvent function
                        viewModel.updateEvent(event: selectedEvent, title: title, date: date, image: photoPicker.selectedImage)
                        presentationMode.wrappedValue.dismiss()
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showDetail = false
                        }
                    } label: {
                        Text("Save")
                    }
                }
            }
        }
    }
}

