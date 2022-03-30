//
//  ARGroupView.swift
//  Archived
//
//  Created by Ben Sova on 3/20/22.
//

import VeliaUI
import SwiftUI
import Files

struct ARGroupView: View {
    @Binding var group: ARGroup
    @State var newArchive = false
    @State var expandedAt = -1
    @State var hovered: String?
    @State var promptDelete = false
    @State var filterSelection = ""
    @State var promptGroupDelete = false
    @State var promptUpdateGroup = false
    var onDelete: () throws -> ()
    var processGroups: () -> ()
    @State var sortMode = "By Date"
    @State var searchTerm = ""
    var body: some View {
        ScrollView {
            HStack {
                VITextField(text: $searchTerm, s: Image(systemName: "magnifyingglass")) {
                    Text("Search Group")
                }
                Spacer()
                ZStack {
                    Rectangle()
                        .foregroundColor(.init("Accent"))
                        .cornerRadius(20)
                        .opacity(hovered == "SortButton" ? 1 : 0.1)
                    Menu {
                        Button("By Date") {
                            sortMode = "By Date"
                        }
                        Button("Alphabetically") {
                            sortMode = "Alphabetically"
                        }
                    } label: {
                        Text("Sort \(sortMode)")
                            .foregroundColor(hovered == "SortButton" ? .white : .init("Accent"))
                    }.menuStyle(BorderlessButtonMenuStyle())
                        .foregroundColor(hovered == "SortButton" ? .white : .init("Accent"))
                        .fixedSize()
                        .padding(.horizontal, 7.5)
                            .padding(7.5)
                }.fixedSize()
                    .onHover { nowHovered in
                        withAnimation { hovered = nowHovered ? "SortButton" : nil }
                    }
            }.padding([.top, .horizontal], 7.5)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(group.appArchives.indices.filter({ archiveIndice in
                    if !searchTerm.isEmpty && !group.appArchives[archiveIndice].title.lowercased().contains(searchTerm.lowercased()) {
                        return false
                    }
                    if filterSelection.hasPrefix("TYPE-") {
                        var filterBy = filterSelection
                        filterBy.removeFirst(5)
                        return group.appArchives[archiveIndice].releaseType == filterBy
                    }
                    return true
                }).sorted(by: { first, second in
                    if !searchTerm.isEmpty {
                        if group.appArchives[first].title.lowercased().hasPrefix(searchTerm.lowercased()) && !group.appArchives[second].title.lowercased().hasPrefix(searchTerm.lowercased()) {
                            return true
                        } else if !group.appArchives[first].title.lowercased().hasPrefix(searchTerm.lowercased()) && group.appArchives[second].title.lowercased().hasPrefix(searchTerm.lowercased()) {
                            return false
                        }
                    }
                    if sortMode == "Alphabetically" {
                        let map =  group.appArchives.map(\.title).sorted()
                        return map.firstIndex(of: group.appArchives[first].title)! < map.firstIndex(of: group.appArchives[second].title)!
                    }
                    return group.appArchives[first].date > group.appArchives[second].date
                }), id: \.self) { archiveIndice in
                    
                    if let archive = group.appArchives[archiveIndice] {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.init("Accent"))
                                .cornerRadius(20)
                                .opacity(0.1)
                            VStack(alignment: .leading) {
                                ARArchiveItemButton(expandedAt: $expandedAt, archiveIndice: archiveIndice, archive: archive, filterSelection: $filterSelection)
                                if expandedAt == archiveIndice {
                                    if !archive.notes.isEmpty {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("Notes")
                                                    .font(.body.bold())
                                                    .padding(.bottom, -3)
                                                Spacer()
                                            }
                                            ScrollView {
                                                Text(archive.notes)
                                            }
                                            .frame(maxHeight: 200).fixedSize(horizontal: false, vertical: true)
                                        }.padding(.horizontal, 7.5)
                                            .padding(7.5).background(Color("Accent").opacity(0.1))
                                            .cornerRadius(15)
                                    }
                                    ForEach(archive.files, id: \.self) { file in
                                        HStack {
                                            Text(file)
                                            Spacer()
                                            Button {
                                                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: "/Users/\(NSUserName())/Archived/\(group.title)/\(archive.title)/\(file)")])
                                            } label: {
                                                Image(systemName: "doc.text.magnifyingglass")
                                                    .font(.system(size: 15))
                                            }.buttonStyle(.borderless)
                                        }.padding(.horizontal, 7.5)
                                            .padding(7.5).background(Color("Accent").opacity(0.1))
                                            .cornerRadius(15)
                                    }
                                    HStack {
                                        VIButton(id: "REVEAL", h: $hovered) {
                                            Image(systemName: "doc.text.magnifyingglass")
                                                .font(.system(size: 15))
                                            Text("Reveal in Finder")
                                        } onClick: {
                                            print("~/Archived/\(group.title)/\(archive.title)")
                                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "/Users/\(NSUserName())/Archived/\(group.title)/\(archive.title)")
                                        }.inPad()
                                        VIButton(id: "DELETE", h: $hovered) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 15))
                                            Text("Delete Archive")
                                        } onClick: {
                                            promptDelete = true
                                        }.btColor(.red).inPad()
                                    }.alert(isPresented: $promptDelete) {
                                        Alert(title: Text("Delete Archive?"), message: Text("This archive (and all archived files) will be permanetly deleted and will not be recovable. (This archive group will not be deleted.)"), primaryButton: .destructive(Text("Delete"), action: {
                                            do {
                                                let archiveFolder = try Folder(path: "/Users/\(NSUserName())/Archived/\(group.title)/\(archive.title)")
                                                try archiveFolder.delete()
                                                group.appArchives.remove(at: archiveIndice)
                                                expandedAt = -1
                                            } catch {
                                                presentAlert(m: "Unable to Remove Archive", i: error.localizedDescription)
                                            }
                                        }), secondaryButton: .cancel())
                                    }
                                }
                            }.padding(.horizontal, 7.5)
                                .padding(7.5)
                                .padding(.bottom, expandedAt == archiveIndice ? 5 : 0)
                        }.fixedSize(horizontal: false, vertical: true)
                    }
                }
                HStack {
                    Spacer()
                    Text("\(group.appArchives.count) Archive\(group.appArchives.count == 1 ? "" : "s")")
                    Spacer()
                }
            }.padding([.bottom, .horizontal], 7.5)
            Rectangle()
                .frame(height: 0)
                .sheet(isPresented: $promptUpdateGroup) {
                    AREditGroupView(__group: $group, group: group, onBack: {
                        promptUpdateGroup = false
                    }, onDone: {
                        promptUpdateGroup = false
                        processGroups()
                    })
                }
                .alert(isPresented: $promptGroupDelete) {
                    Alert(title: Text("Delete Archive Group?"), message: Text("This archive group (including all archives and files in it) will be permanetly deleted and will not be recovable."), primaryButton: .destructive(Text("Delete"), action: {
                        do {
                            let archiveFolder = try? Folder(path: "/Users/\(NSUserName())/Archived/\(group.title)/")
                            _ = try? archiveFolder?.delete()
                            try onDelete()
                        } catch {
                            presentAlert(m: "Unable to Delete Archive Group", i: error.localizedDescription)
                        }
                    }), secondaryButton: .cancel())
                }
        }.toolbar() {
            ToolbarItemGroup {
                Button {
                    promptUpdateGroup = true
                } label: {
                    Label {
                        Text("Edit Group")
                    } icon: {
                        Image(systemName: "square.and.pencil")
                    }
                }
                Button {
                    promptGroupDelete = true
                } label: {
                    Label {
                        Text("Delete Group")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
                Rectangle()
                    .frame(width: 20, height: 1)
                    .opacity(0.00001)
                Button {
                    newArchive = true
                } label: {
                    Label {
                        Text("New Archive")
                    } icon: {
                        Image(systemName: "plus")
                    }
                }
                Button {
                    newArchive = true
                } label: {
                    Label {
                        Text("App Settings")
                    } icon: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }.navigationTitle(Text(group.title))
            .navigationSubtitle(Text(group.category))
            .sheet(isPresented: $newArchive) {
                ARNewArchiveView(newArchive: $newArchive, group: $group)
            }
    }
}

struct ARArchiveItemButton: View {
    @Binding var expandedAt: Int
    var archiveIndice: Int
    var archive: ARAppArchive
    @Binding var filterSelection: String
    var body: some View {
        HStack(alignment: .bottom) {
            Button {
                expandedAt = expandedAt == archiveIndice ? -1 : archiveIndice
            } label: {
                HStack(alignment: .bottom) {
                    Text("\(archive.title)")
                        .font(.body.bold())
                    
                    Text(archive.date.monthStyle())
                        .font(.caption.weight(.light))
                    
                    Spacer()
                    
                    Text("\(archive.files.count) File\(archive.files.count == 1 ? "" : "s")")
                        .font(.caption.weight(.light))
                }
            }.buttonStyle(.borderless)
            
            VStack {
                HStack {
                    Button {
                        if !filterSelection.hasPrefix("TYPE-") {
                            filterSelection = "TYPE-\(archive.releaseType)"
                        } else {
                            filterSelection = ""
                        }
                    } label: {
                        if !filterSelection.hasPrefix("TYPE-") {
                            Text("\(archive.releaseType)")
                                .font(.caption.weight(.light))
                                .padding(2)
                                .padding(.horizontal, 3)
                                .background(Color(.init("Accent")).opacity(0.1))
                        } else {
                            Text("\(archive.releaseType)")
                                .font(.caption.weight(.light))
                                .foregroundColor(.white)
                                .padding(2)
                                .padding(.horizontal, 3)
                                .background(Color(.init("Accent")))
                        }
                    }.buttonStyle(.borderless)
                    Button {
                        expandedAt = expandedAt == archiveIndice ? -1 : archiveIndice
                    } label: {
                        
                        Image(systemName: expandedAt == archiveIndice ? "chevron.down" : "chevron.forward")
                            .frame(width: 15, height: 15, alignment: .center)
                        
                    }.buttonStyle(.borderless)
                }
                
                Spacer(minLength: 0)
            }
        }.foregroundColor(.primary)
            .padding(.bottom, expandedAt == archiveIndice ? -1 : 0)
    }
}

func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

struct ContentVi2ew_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
