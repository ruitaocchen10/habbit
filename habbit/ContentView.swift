//
//  ContentView.swift
//  habbit
//
//  Created by Ruitao Chen on 2/16/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        if authManager.isLoading {
            ProgressView()
        } else if authManager.isAuthenticated {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
}
