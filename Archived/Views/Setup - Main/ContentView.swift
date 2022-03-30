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
    @State var processedGroups = [] as [ARCategory]
    @State var needsSetup = false
    @State var creatingGroup = false
    @State var activeGroup = ""
    @State var activeGroupBackup = nil as String?
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(processedGroups, id: \.title) { group in
    //                    Text(group.title)
    //                        .font(.system(size: 12, weight: .semibold, design: .default))
                        Section {
                            ForEach(group.groups, id: \.self) { groupID in
                                if groups.count > groupID {
                                    NavigationLink(destination: ARGroupView(group: .init(get: { groups[groupID] }, set: {
                                        groups[groupID] = $0
                                        do {
                                            indexFile = try Folder(path: "~/Archived").createFileIfNeeded(at: "Index.json")
                                            try indexFile!.write(try groups.jsonData())
                                        } catch {
                                            presentAlert(m: "Failed to Update Archive", i: "\(error.localizedDescription)")
                                        }
                                    }), onDelete: {
                                        do {
                                            indexFile = try Folder(path: "~/Archived").createFileIfNeeded(at: "Index.json")
                                            groups.remove(at: groupID)
                                            try indexFile!.write(try groups.jsonData())
                                            activeGroup = ""
                                            processGroups()
                                        } catch {
                                            presentAlert(m: "Failed to Remove Archive Group", i: "\(error.localizedDescription)")
                                            creatingGroup = false
                                        }
                                    }, processGroups: { processGroups() }), isActive: .init(get: {
                                        activeGroup == "\(groupID)"
                                    }, set: { newValue in
                                        if newValue {
                                            activeGroup = "\(groupID)"
                                        } else if activeGroup == "\(groupID)" {
                                            activeGroup = ""
                                        }
                                    })) {
                                        Text(self.groups[groupID].title)
                                    }
                                }
                            }
                        } header: {
                            Text(group.title)
                        }
                    }
                }.listStyle(SidebarListStyle())
                Button("Create Group") {
                    creatingGroup = true
                }.padding(10)
                .sheet(isPresented: $creatingGroup) {
                    ARShimCreateGroup(groups: $groups, creatingGroup: $creatingGroup, onDone: { processGroups() })
                }
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: toggleSidebar, label: {
                            Label {
                                Text("Toggle Sidebar")
                            } icon: {
                                Image(systemName: "sidebar.left")
                            }
                        })
                    }
                    
                }
            }
            Text("Welcome to Archived!")
                .padding()
                .navigationTitle("Archived")
                .onAppear {
                    if let activeGroupBackup = activeGroupBackup {
                        activeGroup = activeGroupBackup
                        self.activeGroupBackup = nil
                    }
                }
                .sheet(isPresented: $needsSetup) {
                    ARSetupController(groups: $groups, needsSetup: $needsSetup, onDone: { processGroups() })
                }
                .onAppear {
                    if processedGroups.isEmpty {
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
                        processGroups()
                    }
                }
        }
    }
    
    func processGroups() {
        activeGroupBackup = activeGroup
        var preprocess = [:] as [String: ARCategory]
        var onValue = -1
        groups.forEach { group in
            onValue += 1
            if preprocess[group.category] != nil {
                preprocess[group.category]?.groups.append(onValue)
            } else {
                preprocess[group.category] = .init(title: group.category, groups: [onValue])
            }
        }
        self.processedGroups = []
        let preproccess2 = preprocess.keys.sorted()
        preproccess2.forEach { key in
            var cat = preprocess[key]!
            cat.groups = cat.groups.sorted { first, second in
                return [groups[first].title, groups[second].title].sorted()[0] == groups[first].title
            }
            self.processedGroups.append(cat)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
