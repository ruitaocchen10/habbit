//
//  habbitApp.swift
//  habbit
//
//  Created by Ruitao Chen on 2/16/26.
//

import SwiftUI

@main
struct habbitApp: App {
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
