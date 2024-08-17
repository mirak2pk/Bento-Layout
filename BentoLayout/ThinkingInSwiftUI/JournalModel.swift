//
//  JournalModel.swift
//  ThinkingInSwiftUI
//
//  Created by MacBook on 15/8/2024.
//

import Foundation
import SwiftData

protocol Noteable {
    var title: String { get set }
    var journal: String { get set }
    var dateCreated: Date { get }
}

enum Media: Codable {
    case video
    case image(Data)
    case audio
    case location
    
    enum CodingKeys: String, CodingKey {
        case type
        case data
    }
    
    enum MediaType: String, Codable {
        case video
        case image
        case audio
        case location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MediaType.self, forKey: .type)
        
        switch type {
        case .video:
            self = .video
        case .image:
            let data = try container.decode(Data.self, forKey: .data)
            self = .image(data)
        case .audio:
            self = .audio
        case .location:
            self = .location
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .video:
            try container.encode(MediaType.video, forKey: .type)
        case .image(let data):
            try container.encode(MediaType.image, forKey: .type)
            try container.encode(data, forKey: .data)
        case .audio:
            try container.encode(MediaType.audio, forKey: .type)
        case .location:
            try container.encode(MediaType.location, forKey: .type)
        }
    }
}

@Model
class JournalModel {
    var title: String
    var journal: String
    var dateCreated: Date
    @Attribute(.externalStorage) var mediaItems: [Media]?

    init(title: String, journal: String, dateCreated: Date = .now) {
        self.title = title
        self.journal = journal
        self.dateCreated = dateCreated
    }
}
