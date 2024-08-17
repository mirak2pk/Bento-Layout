//
// ContentView.swift
// BentoLayout
//
// Created by syclonefx on 8/10/24
// https://syclonefx.com
// https://github.com/syclonefx
//

import SwiftUI
import SwiftData

protocol JournalView: View {
    associatedtype Content: View
    var body: ComponentView<Content> { get }
}

struct ComponentView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
    }
}

struct ContainerView: JournalView {
    let media: Media
    
    var body: ComponentView<some View> {
        ComponentView {
            switch media {
            case .video:
                Rectangle().fill(Color.blue) // Placeholder for video view
            case .image(let data):
                RoundedRectangle(cornerRadius: 15)
                    .fill(.clear)
                    .overlay {
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        }
                    }.clipped()
                    .cornerRadius(15)
            case .audio:
                Rectangle().fill(Color.red) // Placeholder for audio view
            case .location:
                Rectangle().fill(Color.yellow) // Placeholder for location view
            }
        }
    }
}

struct BentoStyleView: View {
    @Query var journals: [JournalModel]
    @State private var addItem: Bool = false
    
    var body: some View {
        NavigationStack{
            ScrollView {
                LazyVStack{
                    ForEach(journals){ journal in
                        BentoRow(journal: journal)
                    }
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        addItem.toggle()
                    }label:{
                        Image(systemName: "plus.circle")
                    }
                }
            }.sheet(isPresented: $addItem, content: {
                AddJournalView()
            }).navigationTitle("Journal App \(journals.count)")
        }
    }  
}

#Preview {
    BentoStyleView()
}


struct BentoRow: View {
    var journal: JournalModel
    @State private var views: [ContainerView] = []
    
    var body: some View {
        VStack{
            buildView()
            
            VStack(alignment: .leading){
                Text(journal.title)
                    .font(.headline)
                Text(journal.journal)
                    .font(.subheadline)

            }.frame(maxWidth: .infinity, alignment: .leading)
            
            HStack{
                Text(dateFormatter.string(from: journal.dateCreated))
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Button{
                } label:{
                    Image(systemName: "ellipsis")
                        .tint(.white)
                }

            }.onAppear {
                updateViews()
            }
            .onChange(of: journal) {
                updateViews()
            }
        }.padding()
            .background(RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .fill(.ultraThinMaterial))
    }
    
    // Date formatter for date
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM"
        return formatter
    }()
    
    private func updateViews() {
        let mediaItems: [Media] = journal.mediaItems ?? []
        views = mediaItems.map { ContainerView(media: $0) }
    }
    
    @ViewBuilder func buildView() -> some View {
        switch views.count {
        case 1:
            views[0]
                .frame(height: 180)
        case 2:
            Grid(horizontalSpacing: 5) {
                GridRow {
                    views[0]
                        .frame(height: 180)
                    views[1]
                        .frame(height: 180)
                }
            }
        case 3:
            Grid(horizontalSpacing: 5) {
                GridRow {
                    views[0]
                        .frame(height: 180)
                    Grid(horizontalSpacing: 5) {
                        GridRow {
                            views[1]
                                .frame(height: 90)
                        }
                        GridRow {
                            views[2]
                                .frame(height: 90)
                        }
                    }
                }
            }
        case 4:
            Grid(horizontalSpacing: 5) {
                GridRow {
                    views[0]
                        .frame(height: 180)
                    Grid(horizontalSpacing: 5) {
                        GridRow {
                            views[1]
                                .frame(height: 90)
                                .gridCellColumns(2)
                        }
                        GridRow {
                            views[2]
                                .frame(height: 90)
                            views[3]
                                .frame(height: 90)
                        }
                    }
                }
            }
        case 5:
            Grid(horizontalSpacing: 5) {
                GridRow {
                    views[0]
                        .frame(width: 180,height: 180)
                    Grid(horizontalSpacing: 5) {
                        GridRow {
                            views[1]
                                .frame(height: 90)
                            views[2]
                                .frame(height: 90)
                        }
                        GridRow {
                            views[3]
                                .frame(height: 90)
                            views[4]
                                .frame(height: 90)
                        }
                    }
                }
            }
        default:
            ContentUnavailableView("Add a view", systemImage: "photo")
        }
    }
}
