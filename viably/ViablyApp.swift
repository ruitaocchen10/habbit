//
//  ViablyApp.swift
//  viably
//
//  Created by Ruitao Chen on 2/16/26.
//

import SwiftUI

@main
struct ViablyApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .onOpenURL { url in
                    authManager.handle(url: url)
                }
        }
    }
}
