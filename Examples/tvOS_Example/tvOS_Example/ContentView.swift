//
//  ContentView.swift
//  tvOS_Example
//
//  Created by Marcus Arnett on 1/23/25.
//

import SwiftUI
import SuiKit

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
