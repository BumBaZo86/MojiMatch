//
//  ContentView.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-05-14.
//

import SwiftUI
import Firebase
let db = Firestore.firestore()

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }.onAppear() {
            db.collection("test").addDocument(data: ["name": "Test"])
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
