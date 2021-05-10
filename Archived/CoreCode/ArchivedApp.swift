//
//  ArchivedApp.swift
//  Archived
//
//  Created by Ben Sova on 4/25/21.
//

import SwiftUI

@main
struct ArchivedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: .infinity, alignment: .center)
        }
    }
}

extension AnyTransition {
    static var moveAway: AnyTransition {
        return .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))

    }
}

extension Color {
    static let background = Self(NSColor.textBackgroundColor)
}
