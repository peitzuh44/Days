//
//  AddEventView.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/11.
//
import SwiftUI
import PhotosUI

struct AddEventView: View {
    @StateObject private var photoPicker = PhotoPicker() 
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var date: Date = Date()

    @ObservedObject var viewModel: EventViewModel // Injected EventViewModel

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
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Check if there is a selected image and pass it to addEvent function
                        viewModel.addEvent(title: title, date: date, image: photoPicker.selectedImage)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Create")
                    }
                }
            }
        }
    }
}
