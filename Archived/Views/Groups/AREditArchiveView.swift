//
//  AREditArchiveView.swift
//  Archived
//
//  Created by Ben Sova on 3/20/22.
//

import VeliaUI
import SwiftUI
import Files

struct AREditArchiveView: View {
    @State var hovered: String?
    @Binding var newArchive: Bool
    @State var archive: ARAppArchive
    var ogArchive: ARAppArchive
    @State var date = Date()
    @State var datePopover = false
    @State var files: [File] = []
    @Binding var group: ARGroup
    @Binding var archiveSource: String
    var indexOfArchive: Int
    var body: some View {
        ScrollView {
            VStack {
                Text("Edit Archive")
                    .font(.title2.bold())
                    .padding(.bottom, 5)
                VStack(alignment: .leading) {
    //                HStack {
    //                    Text("Group Title:")
    //                    TextField("Group Title", text: $name)
    //                }
                    VITextField(text: $archive.title, s: Image(systemName: "character.textbox")) {
                        Text("Archive Title")
                            .opacity(0.5)
                    }
                    Text("This is the version of the item you're archiving usually, or it could also be the variant of it, or really anything you want. For the v1.1.0 update of Patched Sur, I would put Patched Sur v1.1.0 here.")
                        .font(.caption)
                        .padding(.bottom, 5)
                    VITextField(text: $archive.releaseType, s: Image(systemName: "tag")) {
                        Text("Archive Type")
                            .opacity(0.5)
                    }
                    
                    Text("This can be whatever you want. For software, I'd put this as something like RELEASE, BETA or ALPHA since there can be different types of releases of an app. You can put whatever you want. This looks better with all caps.")
                        .font(.caption)
                    
                    VIButton(id: "DateSetter", h: $hovered) {
                        Image(systemName: "calendar").font(.system(size: 15))
                        Text(archive.date.monthStyle())
                    } onClick: {
                        datePopover.toggle()
                    }.inPad()
                        .popover(isPresented: $datePopover) {
                            DatePicker(selection: $archive.date, displayedComponents: .date) {
                                EmptyView()
                            }
                            .datePickerStyle(.graphical)
                        }
                    
                    Text("When was this released or published or existified? (This is what the list is sorted by)")
                        .font(.caption)
                    
                    ZStack {
                        Color("Accent")
                            .opacity(0.05)
                        ZStack(alignment: .topLeading) {
                            if archive.notes.isEmpty {
                                Text("Notes")
                                    .foregroundColor(.init("Accent"))
                                    .padding(.leading, 5)
                                    .opacity(0.5)
                            }
                            ZStack(alignment: .bottomTrailing) {
                                CustomizableTextEditor(text: $archive.notes)
                                    .accentColor(.init("Accent"))
                            }
                        }.padding(14)
                    }.frame(width: 540, height: 125)
                    .cornerRadius(15)
                    Text("Any extra information you'd like to include? Just throw it here.")
                        .font(.caption)
                    
                    VIButton(id: "ADD-FILE", h: $hovered) {
                        Image(systemName: "doc.zipper").font(.system(size: 15))
                        Text("Add File")
                    } onClick: {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = true
                        panel.canChooseDirectories = false
                        if panel.runModal() == .OK {
                            panel.urls.forEach { url in
                                if let file = try? File(path: url.path) {
                                    files.append(file)
                                }
                            }
                        }
                    }.inPad()
                        .onAppear {
                            archive.files.forEach { this in
                                do {
                                    files.append(try File(path: "\(archiveSource)/\(group.title)/\(archive.title)/\(this)"))
                                } catch {
                                    // No one cares
                                }
                            }
                        }
                    
                    ForEach(files, id: \.self.path) { file in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.init("Accent"))
                                .cornerRadius(20)
                                .opacity(0.1)
                            HStack(alignment: .bottom) {
                                Text("\(file.name)")
                                    .font(.body.bold())
                                Text("\(file.path)")
                                    .font(.caption.weight(.light))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Spacer()
                                Button {
                                    files.removeAll(where: {
                                        $0.path == file.path
                                    })
                                } label: {
                                    Image(systemName: "xmark").font(.system(size: 15))
                                }.buttonStyle(.borderless)
                            }.padding(7.5)
                                .padding(.horizontal, 7.5)
                        }.fixedSize(horizontal: false, vertical: true)
                    }
                }
                HStack {
                    VIButton(id: "BACK", h: $hovered) {
                        Image("BackArrowCircle")
                        Text("Back")
                    } onClick: {
                        newArchive = false
                    }.inPad()
                    VIButton(id: "UPDATE", h: $hovered) {
                        Text("Update")
                        Image("CheckCircle")
                    } onClick: {
                        do {
                            let archivedFolder = try Folder(path: archiveSource)
                            let groupFolder = try archivedFolder.subfolder(named: group.title)
                            let archiveFolder = try groupFolder.subfolder(named: ogArchive.title)
                            if ogArchive.title != archive.title {
                                try archiveFolder.rename(to: archive.title)
                            }
                            var tempFiles = [] as [String]
                            try files.forEach { file in
                                if !file.path.contains("\(archiveSource)/\(group.title)/\(ogArchive.title)") {
                                    try file.copy(to: archiveFolder)
                                }
                                tempFiles.append(file.name)
                            }
                            archive.files = tempFiles
                            group.appArchives[indexOfArchive] = archive
                            newArchive = false
                        } catch {
                            presentAlert(m: "Failed to edit archive.", i: error.localizedDescription)
                        }
                        
                    }.inPad()
                }
                
                
            }.padding(30)
        }.textFieldStyle(RoundedBorderTextFieldStyle())
        .frame(width: 600, height: 400)
    }
}
