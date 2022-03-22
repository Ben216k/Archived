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
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(group.appArchives.indices.filter({ archiveIndice in
                    if filterSelection.hasPrefix("TYPE-") {
                        var filterBy = filterSelection
                        filterBy.removeFirst(5)
                        return group.appArchives[archiveIndice].releaseType.hasPrefix(filterBy)
                    }
                    return true
                }).sorted(by: { first, second in
                    group.appArchives[first].date > group.appArchives[second].date
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
                                            .alert(isPresented: $promptDelete) {
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
                                }
                            }.padding(.horizontal, 7.5)
                                .padding(7.5)
                                .padding(.bottom, expandedAt == archiveIndice ? 5 : 0)
                        }.fixedSize(horizontal: false, vertical: true)
                    }
                    
                }
            }.padding(7.5)
        }.toolbar() {
            ToolbarItem {
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
