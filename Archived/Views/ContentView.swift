//
//  ContentView.swift
//  Archived
//
//  Created by Ben Sova on 4/25/21.
//

import SwiftUI
import Files

struct ContentView: View {
    @State var groups = [] as ARGroups
    @State var needsSetup = false
    var body: some View {
        NavigationView {
            List {
//                NavigationLink(destination: Text("Not a Bug!")) {
//                    Label {
//                        Text("Patched Sur")
//                    } icon: {
//                        Image(systemName: "circle")
//                    }
//                }
            }.listStyle(SidebarListStyle())
            Text("Welcome to Archived!")
                .padding()
                .navigationTitle("Archived")
                .toolbar {
                    ToolbarItem {
                        Label {
                            Text("Patched Sur")
                        } icon: {
                            Image(systemName: "circle")
                        }
                    }
                }
                .sheet(isPresented: $needsSetup) {
                    ARSetupController(groups: $groups, needsSetup: $needsSetup)
                }
                .onAppear {
                    print("Hello World")
                    print("Attempting to read from ~/Archived/Index.json")
                    do {
                        let rawJSON = try call("cat ~/Archived/Index.json")
                        print("Found data!")
                        groups = try ARGroups(rawJSON)
                        print("Decoded data!")
                    } catch _ as ShellOutError {
                        print("Failed to find/read Index.json.")
                        print("Creating Archived folder")
                        _ = try? call("mkdir ~/Archived")
                        print("Starting Setup!")
                        needsSetup = true
                    } catch {
                        print("Failed to decode Index.json.")
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
