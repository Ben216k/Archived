//
//  ARNewArchiveView.swift
//  Archived
//
//  Created by Ben Sova on 3/20/22.
//

import VeliaUI
import SwiftUI
import Files

struct ARNewArchiveView: View {
    @State var hovered: String?
    @Binding var newArchive: Bool
    @State var title = ""
    @State var releaseType = ""
    @State var notes = ""
    @State var date = Date()
    @State var datePopover = false
    @State var files: [File] = []
    @Binding var group: ARGroup
    @Binding var archiveSource: String
    var body: some View {
        ScrollView {
            VStack {
                Text("New Archive")
                    .font(.title2.bold())
                    .padding(.bottom, 5)
                VStack(alignment: .leading) {
    //                HStack {
    //                    Text("Group Title:")
    //                    TextField("Group Title", text: $name)
    //                }
                    VITextField(text: $title, s: Image(systemName: "character.textbox")) {
                        Text("Archive Title")
                            .opacity(0.5)
                    }
                    Text("This is the version of the item you're archiving usually, or it could also be the variant of it, or really anything you want. For the v1.1.0 update of Patched Sur, I would put Patched Sur v1.1.0 here.")
                        .font(.caption)
                        .padding(.bottom, 5)
                    VITextField(text: $releaseType, s: Image(systemName: "tag")) {
                        Text("Archive Type")
                            .opacity(0.5)
                    }
                    
                    Text("This can be whatever you want. For software, I'd put this as something like RELEASE, BETA or ALPHA since there can be different types of releases of an app. You can put whatever you want. This looks better with all caps.")
                        .font(.caption)
                    
                    VIButton(id: "DateSetter", h: $hovered) {
                        Image(systemName: "calendar").font(.system(size: 15))
                        Text(date.monthStyle())
                    } onClick: {
                        datePopover.toggle()
                    }.inPad()
                        .popover(isPresented: $datePopover) {
                            DatePicker(selection: $date, displayedComponents: .date) {
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
                            if notes.isEmpty {
                                Text("Notes")
                                    .foregroundColor(.init("Accent"))
                                    .padding(.leading, 5)
                                    .opacity(0.5)
                            }
                            ZStack(alignment: .bottomTrailing) {
                                CustomizableTextEditor(text: $notes)
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
                    VIButton(id: "CREATE", h: $hovered) {
                        Text("Create")
                        Image("CheckCircle")
                    } onClick: {
                        do {
                            let archivedFolder = try Folder(path: archiveSource)
                            let groupFolder = try archivedFolder.createSubfolderIfNeeded(withName: group.title)
                            let archiveFolder = try groupFolder.createSubfolderIfNeeded(withName: title)
                            try files.forEach { file in
                                try file.copy(to: archiveFolder)
                            }
                            group.appArchives.append(.init(uuid: UUID().uuidString, title: title, releaseType: releaseType, date: date, notes: notes, files: files.map(\.name)))
                            newArchive = false
                        } catch {
                            presentAlert(m: "Failed to create archive.", i: error.localizedDescription)
                        }
                        
                    }.inPad()
                }
                Button("") {
                    newArchive = false
                }.buttonStyle(.borderless).keyboardShortcut(.cancelAction)
                
            }.padding(30)
        }.textFieldStyle(RoundedBorderTextFieldStyle())
        .frame(width: 600, height: 400)
    }
}

struct CustomizableTextEditor: View {
    @Binding var text: String
    
    var body: some View {
        GeometryReader { geometry in
            NSScrollableTextViewRepresentable(text: $text, size: geometry.size)
        }
    }
    
}

struct NSScrollableTextViewRepresentable: NSViewRepresentable {
    typealias Representable = Self
    
    // Hook this binding up with the parent View
    @Binding var text: String
    var size: CGSize
    
    // Get the UndoManager
    @Environment(\.undoManager) var undoManger
    
    // create an NSTextView
    func makeNSView(context: Context) -> NSScrollView {
        
        // create NSTextView inside NSScrollView
        let scrollView = NSTextView.scrollableTextView()
        let nsTextView = scrollView.documentView as! NSTextView
        
        // use SwiftUI Coordinator as the delegate
        nsTextView.delegate = context.coordinator
        
        // set drawsBackground to false (=> clear Background)
        // use .background-modifier later with SwiftUI-View
        nsTextView.drawsBackground = false
        
        // allow undo/redo
        nsTextView.allowsUndo = true
        
        nsTextView.textColor = .init(named: "Accent")!
        
        nsTextView.font = .systemFont(ofSize: NSFont.systemFontSize)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        // get wrapped nsTextView
        guard let nsTextView = scrollView.documentView as? NSTextView else {
            return
        }
        
        // fill entire given size
        nsTextView.minSize = size

        // set NSTextView string from SwiftUI-Binding
        nsTextView.string = text
    }
    
    // Create Coordinator for this View
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Declare nested Coordinator class which conforms to NSTextViewDelegate
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: Representable // store reference to parent
        
        init(_ textEditor: Representable) {
            self.parent = textEditor
        }
        
        // delegate method to retrieve changed text
        func textDidChange(_ notification: Notification) {
            // check that Notification.name is of expected notification
            // cast Notification.object as NSTextView

            guard notification.name == NSText.didChangeNotification,
                let nsTextView = notification.object as? NSTextView else {
                return
            }
            // set SwiftUI-Binding
            parent.text = nsTextView.string
        }
        
        // Pass SwiftUI UndoManager to NSTextView
        func undoManager(for view: NSTextView) -> UndoManager? {
            parent.undoManger
        }

        // feel free to implement more delegate methods...
        
    }
    
}

extension Date {
    func monthStyle() -> String {
        let dateformat = DateFormatter()
        dateformat.dateStyle = .medium
        dateformat.timeStyle = .none
        return dateformat.string(from: self)
     }
}
