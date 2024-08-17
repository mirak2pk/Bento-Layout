//
//  AddJournalView.swift
//  ThinkingInSwiftUI
//
//  Created by MacBook on 15/8/2024.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddJournalView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var selectPhotos: [PhotosPickerItem] = []
    @State private var photosData: [Data] = []
    @State var journalName: String = ""
    @State var description: String = ""

    var body: some View {
        VStack{
            ScrollView(.horizontal) {
                HStack {
                    ForEach(photosData, id: \.self) { data in
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        }
                    }
                }
            }.onChange(of: selectPhotos) {
                Task {
                    // Retrieve selected images
                    var newPhotoData: [Data] = []
                    for item in selectPhotos {
                        // Retrieve selected image data
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            newPhotoData.append(data)
                        }
                    }
                    // Update photoData state
                    photosData.append(contentsOf: newPhotoData)
                }
            }

            PhotosPicker(selection: $selectPhotos, matching: .images) {
                HStack{
                    Image(systemName: "photo")
                    Text("AppIcon")
                }.foregroundStyle(.black)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.ultraThinMaterial))
            }
            
            TextField("Journal Name ", text: $journalName)
                .recBackground(radius: 10, style: .circular, padding: 15, color: .ultraThick)
            
            TextField("Description ", text: $description)
                .recBackground(radius: 10, style: .circular, padding: 15, color: .ultraThick)
            
            Button{
                addJournal()
            }label: {
                Text("Add Journal")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
            }
        }
    }
    
    private func addJournal() {
        // Create a new JournalModel instance with title and description
        let journal = JournalModel(title: journalName, journal: description)

        // Assign photosData to the journal's mediaItems property
        journal.mediaItems = photosData.map { Media.image($0) }
        modelContext.insert(journal)
        // Save changes to the context
        do {
            try modelContext.save()
            print("Journal note saved successfully.")
        } catch {
            print("Failed to save journal note: \(error.localizedDescription)")
        }
        
        // Dismiss the view after adding the journal
        dismiss()
    }


    
}

#Preview {
    AddJournalView()
}


