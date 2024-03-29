//
//  ARGroupView.swift
//  Archived
//
//  Created by Ben Sova on 3/20/22.
//

import VeliaUI
import SwiftUI
import Files
import AVFoundation

struct ARGroupView: View {
    @Binding var group: ARGroup
    @State var newArchive = false
    @State var expandedAt = -1
    @State var hovered: String?
    @State var promptDelete = false
    @State var deleteAt = -1
    @State var filterSelection = ""
    @State var promptGroupDelete = false
    @State var promptUpdateGroup = false
    var onDelete: () throws -> ()
    var processGroups: () -> ()
    @State var sortMode = "By Date"
    @State var searchTerm = ""
    @State var editingArchive = false
    @Binding var archiveSource: String
    
    var body: some View {
        ScrollView {
            ARTopGroupView(searchTerm: $searchTerm, hovered: $hovered, sortMode: $sortMode)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(excessiveFiltering(group.appArchives), id: \.self) { archiveIndice in
                    
                    if let archive = Optional.some(group.appArchives[archiveIndice]) {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.init("Accent"))
                                .cornerRadius(20)
                                .opacity(0.1)
                            VStack(alignment: .leading) {
                                ARArchiveItemButton(expandedAt: $expandedAt, archiveIndice: archiveIndice, archive: archive, filterSelection: $filterSelection)
                                if expandedAt == archiveIndice {
                                    AnotherPiece(archive: archive, archiveIndice: archiveIndice, archiveSource: $archiveSource, hovered: $hovered, editingArchive: $editingArchive, group: $group, promptDelete: $promptDelete, deleteAt: $deleteAt)
                                }
                            }.padding(.horizontal, 7.5)
                                .padding(7.5)
                                .padding(.bottom, expandedAt == archiveIndice ? 5 : 0)
                        }.fixedSize(horizontal: false, vertical: true)
                            .contextMenu {
                                Button("Edit") {
                                    editingArchive = true
                                    expandedAt = archiveIndice
                                }
                                if !archive.files.isEmpty {
                                    Button("Reveal in Finder") {
                                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "\(archiveSource)/\(group.title)/\(archive.title)")
                                    }
                                }
                                Button("Delete") {
                                    deleteAt = archiveIndice
                                    promptDelete = true
                                }
                            }.alert(isPresented: .init(get: { promptDelete && archiveIndice == deleteAt }, set: {
                                promptDelete = $0
                            })) {
                                Alert(title: Text("Delete Archive?"), message: Text("This archive (and all archived files) will be permanently deleted and will not be recoverable. (This archive group will not be deleted.)"), primaryButton: .destructive(Text("Delete"), action: {
                                    do {
                                        if let archiveFolder = try? Folder(path: "\(archiveSource)/\(group.title)/\(archive.title)") {
                                            try archiveFolder.delete()
                                        }
                                        group.appArchives.remove(at: archiveIndice)
                                        expandedAt = -1
                                    } catch {
                                        presentAlert(m: "Unable to Remove Archive", i: error.localizedDescription)
                                    }
                                }), secondaryButton: .cancel())
                            }
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
                    AREditGroupView(__group: $group, group: group, archiveSource: $archiveSource, onBack: {
                        promptUpdateGroup = false
                    }, onDone: {
                        promptUpdateGroup = false
                        processGroups()
                    })
                }
                .alert(isPresented: $promptGroupDelete) {
                    Alert(title: Text("Delete Archive Group?"), message: Text("This archive group (including all archives and files in it) will be permanently deleted and will not be recoverable."), primaryButton: .destructive(Text("Delete"), action: {
                        do {
                            let archiveFolder = try? Folder(path: "\(archiveSource)/\(group.title)/")
                            _ = try? archiveFolder?.delete()
                            try onDelete()
                        } catch {
                            presentAlert(m: "Unable to Delete Archive Group", i: error.localizedDescription)
                        }
                    }), secondaryButton: .cancel())
                }
        }.toolbar() {
            ToolbarItemGroup {
                ARToolbarGroupView(promptUpdateGroup: $promptUpdateGroup, promptGroupDelete: $promptGroupDelete, newArchive: $newArchive)
            }
        }.navigationTitle(Text(group.title))
            .navigationSubtitle(Text(group.category))
            .sheet(isPresented: $newArchive) {
                ARNewArchiveView(newArchive: $newArchive, group: $group, archiveSource: $archiveSource)
            }
    }
    
    func excessiveFiltering(_ array: [ARAppArchive]) -> Array<Int> {
        array.indices.filter({ archiveIndice in
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
        })
    }
}

struct AnotherPiece: View {
    
    var archive: ARAppArchive
    var archiveIndice: Int
    @Binding var archiveSource: String
    @Binding var hovered: String?
    @Binding var editingArchive: Bool
    @Binding var group: ARGroup
    @Binding var promptDelete: Bool
    @Binding var deleteAt: Int
    
    var body: some View {
        VStack(alignment: .leading) {
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
                    if let metadata = obtainCoolMetadata(g: group.title, a: archive.title, f: file, s: archiveSource) {
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading) {
                                Text(metadata.title)
                                    .bold()
                                Text("\(metadata.author) - \(file)")
                            }
                        }
                    } else {
                        Text(file)
                    }
                    Spacer()
                    Button {
                        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: "\(archiveSource)/\(group.title)/\(archive.title)/\(file)")])
                    } label: {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 15))
                    }.buttonStyle(.borderless)
                }.padding(.horizontal, 7.5)
                    .padding(7.5).background(Color("Accent").opacity(0.1))
                    .cornerRadius(15)
            }
            HStack {
                if !archive.files.isEmpty {
                    VIButton(id: "REVEAL", h: $hovered) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 15))
                        Text("Reveal in Finder")
                    } onClick: {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "\(archiveSource)/\(group.title)/\(archive.title)")
                    }.inPad()
                }
                VIButton(id: "EDITARCHIVE", h: $hovered) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 15))
                    Text("Edit Archive")
                } onClick: {
                    editingArchive = true
                }.inPad()
                    .sheet(isPresented: $editingArchive) {
                        AREditArchiveView(newArchive: $editingArchive, archive: archive, ogArchive: archive, group: $group, archiveSource: $archiveSource, indexOfArchive: archiveIndice)
                    }
                VIButton(id: "DELETE", h: $hovered) {
                    Image(systemName: "trash")
                        .font(.system(size: 15))
                    Text("Delete Archive")
                } onClick: {
                    deleteAt = archiveIndice
                    promptDelete = true
                }.btColor(.red).inPad()
            }
        }
    }
}

struct ARToolbarGroupView: View {
    @Binding var promptUpdateGroup: Bool
    @Binding var promptGroupDelete: Bool
    @Binding var newArchive: Bool
    var body: some View {
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
        Button {
            newArchive = true
        } label: {
            Label {
                Text("New Archive")
            } icon: {
                Image(systemName: "plus")
            }
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
                    if !archive.releaseType.isEmpty {
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
                    }
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

struct ARTopGroupView: View {
    @Binding var searchTerm: String
    @Binding var hovered: String?
    @Binding var sortMode: String
    
    var body: some View {
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

func obtainCoolMetadata(g group: String, a archive: String, f file: String, s source: String) -> (title: String, author: String)? {
    let asset = AVAsset(url: URL(fileURLWithPath: "\(source)/\(group)/\(archive)/\(file)"))
    let metadata = asset.commonMetadata
    var returnable = (title: "", author: "")
    metadata.forEach { data in
        if data.key == nil { return }
        if "\(data.key!)" == "TT2" {
            returnable.title = data.stringValue ?? ""
        } else if "\(data.key!)" == "TP1" {
            returnable.author = data.stringValue ?? ""
        }
    }
    if returnable.title.isEmpty || returnable.author.isEmpty {
        return nil
    }
    return returnable
}
