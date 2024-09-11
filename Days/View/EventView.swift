//
//  EventView.swift
//  Days
//
//  Created by Pei-Tzu Huang on 2024/9/10.
//

import SwiftUI

struct EventView: View {
    @StateObject var viewModel = EventViewModel()
    @Namespace var namespace // Shared namespace
    @State var showDetail: Bool = false
    @State private var selectedEvent: Event? = nil // Track the selected event
    @State private var pastOrUpcoming: String = "upcoming"
    @State private var showAddEventView = false
    @State private var showActionSheet = false
    
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    
    var body: some View {
        ZStack (alignment: .top){
            // Collapsed state
            if !showDetail {
                ZStack (alignment: .bottom){
                    ScrollView {
                        VStack (spacing: 16){
                            ForEach(viewModel.events) { event in
                                EventItem(namespace: namespace, event: event) // Pass the shared namespace
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            selectedEvent = event // Set the selected event
                                            showDetail = true
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    // Picker
                    CustomSegmentedPicker(segments: ["past", "upcoming"], selectedSegment: $pastOrUpcoming)
                        .padding()
                }
            } else if let selectedEvent = selectedEvent {
                EventDetailView(namespace: namespace, event: selectedEvent)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showDetail = false
                        }
                    }
            }
            
            CustomNavBar(showAddEventView: $showAddEventView, showDetail: $showDetail, showActionSheet: $showActionSheet)

        }
        // sheet
        .sheet(isPresented: $showAddEventView, content: {
            AddEventView(viewModel: viewModel)
        }
        )
    }
}

#Preview {
    EventView()
}




struct CustomSegmentedPicker: View {
    let segments: [String]
    @Binding var selectedSegment: String
    @Namespace private var namespace

    var body: some View {
        HStack (spacing: 0){
            ForEach(segments, id: \.self) { segment in
                HStack {
                    Text(segment)
                        .padding(.vertical, 12)
                }
                .foregroundColor(selectedSegment == segment ? .white : .black)
                .frame(width: 120)
                .background(
                    ZStack {
                        if selectedSegment == segment {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(Color.blue)
                                .matchedGeometryEffect(id: "picker", in: namespace)
                        }
                    }
                )
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.3)) {
                        self.selectedSegment = segment
                    }
                }
                
                
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 30.0)
                .fill(.thinMaterial)
        )
    }
}


struct CustomNavBar: View {
    
    @Binding var showAddEventView: Bool
    @Binding var showDetail: Bool
    @Binding var showActionSheet: Bool
    var body: some View {
        HStack {
            Button {
                if !showDetail {
                    // expand side bar
                } else {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showDetail = false
                    }
                }
            } label: {
                ZStack {
                    Circle().fill(.thinMaterial)
                        .frame(width: 44)
                    Image(systemName: showDetail ? "xmark" : "line.3.horizontal")
                        .contentTransition(.symbolEffect)
                        .font(.title2)
                        .foregroundStyle(Color.black)

                }
            }
            Spacer()
            Text("Filter")
                .padding()
                .background(RoundedRectangle(cornerRadius: 30.0)
                    .fill(.thinMaterial)
                )
            
            
            Spacer()
            Button {
                if !showDetail {
                    // edit event
                    showAddEventView = true
                } else {
                    showActionSheet = true
                }
            } label: {
                ZStack {
                    Circle().fill(.thinMaterial)
                        .frame(width: 44)
                    Image(systemName: showDetail ? "ellipsis" : "plus")
                        .contentTransition(.symbolEffect)
                        .font(.title2)
                        .foregroundStyle(Color.black)

                }
            }

        }
        .padding()
    }
}



