//
//  ThinkingInSwiftUIApp.swift
//  ThinkingInSwiftUI
//
//  Created by MacBook on 20/7/2024.
//

import SwiftUI
import SwiftData

@main
struct ThinkingInSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            BentoStyleView()
                .modelContainer(for: JournalModel.self)
        }
    }
}
