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
    @State var archiveSource = "/Users/\(NSUserName())/Library/Containers/bensova.Archived/Data/Archived"
    
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
                                            indexFile = try Folder(path: archiveSource).createFileIfNeeded(at: "Index.json")
                                            try indexFile!.write(try groups.jsonData())
                                        } catch {
                                            presentAlert(m: "Failed to Update Archive", i: "\(error.localizedDescription)")
                                        }
                                    }), onDelete: {
                                        do {
                                            indexFile = try Folder(path: archiveSource).createFileIfNeeded(at: "Index.json")
                                            groups.remove(at: groupID)
                                            try indexFile!.write(try groups.jsonData())
                                            activeGroup = ""
                                            processGroups()
                                        } catch {
                                            presentAlert(m: "Failed to Remove Archive Group", i: "\(error.localizedDescription)")
                                            creatingGroup = false
                                        }
                                    }, processGroups: { processGroups() }, archiveSource: $archiveSource), isActive: .init(get: {
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
                List {
                    NavigationLink(destination: ARPreferences(archiveSource: $archiveSource, processGroups: processGroups)) {
                        Text("Preferences")
                    }
                }.listStyle(SidebarListStyle())
                    .frame(height: 35)
//                    .fixedSize()
                Button("Create Group") {
                    creatingGroup = true
                }.padding([.horizontal, .bottom], 10)
                .sheet(isPresented: $creatingGroup) {
                    ARShimCreateGroup(groups: $groups, creatingGroup: $creatingGroup, processedGroups: $processedGroups, archiveSource: $archiveSource, onDone: { processGroups() })
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
                .sheet(isPresented: $needsSetup) {
                    ARSetupController(groups: $groups, needsSetup: $needsSetup, processedGroups: $processedGroups, onDone: { processGroups() })
                }
                .onAppear {
                    if processedGroups.isEmpty {
                        print("Hello World")
                        if let archivedSource = UserDefaults.standard.string(forKey: "Source"), (try? Folder(path: archiveSource).file(named: "Index.json").readAsString()) != nil {
                            print("\(archivedSource)")
                            self.archiveSource = archivedSource
                        } else {
                            UserDefaults.standard.set(archiveSource, forKey: "Source")
                        }
                        print("Attempting to read from \(archiveSource)/Index.json")
                        do {
                            let rawJSON = try Folder(path: archiveSource).file(named: "Index.json").readAsString()
                            print("Found data!")
                            groups = try ARGroups(rawJSON)
                            print("Decoded data!")
                        } catch {
                            print("Failed to find/read Index.json.")
                            print("Creating Archived folder")
                            _ = try? call("rm -f ~/Archived/Index.json")
                            _ = try? call("mkdir ~/Archived/")
                            print("Starting Setup!")
                            needsSetup = true
                        }
                        processGroups()
                    }
                }
        }
    }
    
    func processGroups() {
        do {
            print("Call")
            let rawJSON = try Folder(path: archiveSource).file(named: "Index.json").readAsString()
            print("Found data!")
            groups = try ARGroups(rawJSON)
            print("Decoded data!")
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
        } catch {
            print("Failed to process")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
