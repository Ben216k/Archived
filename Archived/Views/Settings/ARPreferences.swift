//
//  ARPreferences.swift
//  Archived
//
//  Created by Ben Sova on 4/3/22.
//

import VeliaUI
import SwiftUI
import Files
import CryptoKit

struct ARPreferences : View {
    @State var hovered: String?
    @Binding var archiveSource: String
    @State var archiveList = [] as [(path: String, connected: Bool)]
    var processGroups: () -> ()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    
                    // MARK: - Storage Location
                    
                    Text("Storage Location")
                        .font(.title2.bold())
                
                    HStack {
                        VIButton(id: "ADD-LOCATION", h: $hovered) {
                            Image(systemName: "plus")
                            Text("Add Location")
                        } onClick: {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = true
                            panel.canChooseFiles = false
                            if panel.runModal() == .OK {
                                if let url = panel.url {
                                    do {
                                        let bookmarkData = try url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope)
                                        
                                        let bookmarkFile = try Folder(path: "/Users/\(NSUserName())/Library/Containers/me.ben216k.Archived/Data/Archived").createFileIfNeeded(at: String(convertToSHA256(str: url.path).prefix(10)))
                                        try bookmarkFile.write(bookmarkData)
                                        
                                        let indexFile = try Folder(path: url.path).createFileIfNeeded(at: "Index.json")
                                        do {
                                            let rawJSON = try indexFile.readAsString()
                                            _ = try ARGroups(rawJSON)
                                        } catch {
                                            try indexFile.write("[]")
                                        }
                                        archiveList.append((url.path, true))
                                        archiveSource = url.path
                                        UserDefaults.standard.set(archiveSource, forKey: "Source")
                                        UserDefaults.standard.set(archiveList.map(\.path), forKey: "List")
                                        processGroups()
                                    } catch {
                                        presentAlert(m: "Failed to Add Location", i: error.localizedDescription)
                                    }
                                }
                            }
                        }.inPad()
                        Spacer()
                        VIButton(id: "REFRESH", h: $hovered) {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        } onClick: {
                            archiveList = []
                            (UserDefaults.standard.stringArray(forKey: "List") ?? []).forEach { source in
                                if (try? Folder(path: source)) != nil {
                                    archiveList.append((source, true))
                                } else {
                                    archiveList.append((source, false))
                                }
                            }
                        }.inPad()
                    }
                    ZStack {
                        Rectangle().foregroundColor(.init("Accent").opacity(0.1))
                            .cornerRadius(15)
                        HStack {
                            Text("~/Library/Containers/me.ben216k.Archived/Data/Archived")
                                .font(.system(size: 11.5).weight(.medium))
                            Text("DEFAULT")
                                .font(.caption.weight(.light))
                                .padding(2)
                                .padding(.horizontal, 3)
                                .background(Color(.init("Accent")).opacity(0.1))
                            Spacer()
                            VIButton(id: "Select-Default", h: archiveSource == "/Users/\(NSUserName())/Library/Containers/me.ben216k.Archived/Data/Archived" ? .constant("Select-Default") : $hovered) {
                                Text(archiveSource == "/Users/\(NSUserName())/Library/Containers/me.ben216k.Archived/Data/Archived" ? "Selected" : "Select")
                            } onClick: {
                                do {
                                    let indexFile = try Folder(path: "/Users/\(NSUserName())/Library/Containers/me.ben216k.Archived/Data/Archived").createFileIfNeeded(at: "Index.json")
                                    do {
                                        let rawJSON = try indexFile.readAsString()
                                        _ = try ARGroups(rawJSON)
                                    } catch {
                                        try indexFile.write("[]")
                                    }
                                    archiveSource = "/Users/\(NSUserName())/Library/Containers/me.ben216k.Archived/Data/Archived"
                                    UserDefaults.standard.set(archiveSource, forKey: "Source")
                                    processGroups()
                                } catch {
                                    presentAlert(m: "Failed to Load Location", i: error.localizedDescription)
                                }
                            }.inPad()
                        }
                            .padding(5)
                            .padding(.horizontal, 7.5)
                            .padding(.trailing, -6.5)
                    }.fixedSize(horizontal: false, vertical: true)
                        .onAppear {
                            (UserDefaults.standard.stringArray(forKey: "List") ?? []).forEach { source in
                                if (try? Folder(path: source)) != nil {
                                    archiveList.append((source, true))
                                } else {
                                    archiveList.append((source, false))
                                }
                            }
                        }
                    ForEach(archiveList, id: \.path) { source in
                        ZStack {
                            Rectangle().foregroundColor(.init("Accent").opacity(0.1))
                                .cornerRadius(15)
                            HStack {
                                Text(source.path)
                                    .font(.system(size: 11.5).weight(.medium))
                                if !source.connected {
                                    Text("DISCONNECTED")
                                        .font(.caption.weight(.light))
                                        .padding(2)
                                        .padding(.horizontal, 3)
                                        .background(Color(.init("Accent")).opacity(0.1))
                                }
                                Spacer()
                                if source.connected {
                                    VIButton(id: "Select-\(source.path)", h: archiveSource == source.path ? .constant("Select-\(source.path)") : $hovered) {
                                        Text(archiveSource == source.path ? "Selected" : "Select")
                                    } onClick: {
                                        do {
                                            let bookmarkFile = try Folder(path: "/Users/\(NSUserName())/Library/Containers/me.ben216k.Archived/Data/Archived").file(named: String(convertToSHA256(str: source.path).prefix(10)))
                                            
                                            let bookmarkFileData = try bookmarkFile.read()
//                                            let bookmarkFileString = String(decoding: bookmarkFileData, as: UTF8.self)
//                                            print(bookmarkFileString)
//                                            let decodedBookmark = Data(base64Encoded: bookmarkFileString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
//
//                                            guard let decodedBookmark = decodedBookmark else {
//                                                presentAlert(m: "Failed to Load Location", i: "Failed to decode bookmark! (Just delete the location and add it back).")
//                                                return
//                                            }
//
                                            var bookmarkStale = false
                                            let bookmarkURL = try URL(resolvingBookmarkData: bookmarkFileData, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkStale)
                                            _ = bookmarkURL.startAccessingSecurityScopedResource()
                                            let indexFile = try Folder(path: source.path).createFileIfNeeded(at: "Index.json")
                                            do {
                                                let rawJSON = try indexFile.readAsString()
                                                _ = try ARGroups(rawJSON)
                                            } catch {
                                                try indexFile.write("[]")
                                            }
                                            archiveSource = source.path
                                            UserDefaults.standard.set(archiveSource, forKey: "Source")
                                            processGroups()
                                        } catch {
                                            presentAlert(m: "Failed to Load Location", i: error.localizedDescription)
                                        }
                                    }.inPad()
                                }
                                VIButton(id: "Remove-\(source.path)", h: $hovered) {
                                    Text("Remove")
                                } onClick: {
                                    if source.connected {
                                        let al = NSAlert()
                                        al.messageText =  "Remove Storage Location"
                                        al.informativeText =  "Removing this storage location will stop Archived from showing it on this list. You can add it back if you'd like, however if you Continue and Delete Data, any groups, archives, and files found within this location will not be recoverable. Would you like to remove it, keeping or deleting data?"
                                        al.showsHelp = false
                                        al.addButton(withTitle: "Continue and Keep Data")
                                        al.addButton(withTitle: "Continue and Delete Data")
                                        al.addButton(withTitle: "Cancel")
                                        switch al.runModal() {
                                        case .alertFirstButtonReturn:
                                            if archiveSource == source.path {
                                                archiveSource = "/Users/\(NSUserName())/Library/Containers/me.ben216k.Archived/Data/Archived"
                                                UserDefaults.standard.set(archiveSource, forKey: "Source")
                                            }
                                            if let bookmarkFile = try? Folder(path: "/Users/\(NSUserName())/Library/Containers/me.ben216k.Archived/Data/Archived").file(named: String(convertToSHA256(str: source.path).prefix(10))) {
                                                _ = try? bookmarkFile.delete()
                                            }
                                            archiveList.remove(at: archiveList.firstIndex(where: { $0 == source })!)
                                            UserDefaults.standard.set(archiveList.map(\.path), forKey: "List")
                                            processGroups()
                                            break
                                        case .alertSecondButtonReturn:
                                            
                                            _ = try? call("rm -rf \"\(source.path)\"")
                                            
                                            if archiveSource == source.path {
                                                archiveSource = "/Users/\(NSUserName())/Library/Containers/me.ben216k.Archived/Data/Archived"
                                                UserDefaults.standard.set(archiveSource, forKey: "Source")
                                            }
                                            
                                            archiveList.remove(at: archiveList.firstIndex(where: { $0 == source })!)
                                            UserDefaults.standard.set(archiveList.map(\.path), forKey: "List")
                                            processGroups()
                                            break
                                        default:
                                            break
                                        }
                                    } else {
                                        archiveList.remove(at: archiveList.firstIndex(where: { $0 == source })!)
                                        UserDefaults.standard.set(archiveList.map(\.path), forKey: "List")
                                        processGroups()
                                    }
                                }.inPad()
                                    .btColor(.red)
                                    
                            }
                                .padding(5)
                                .padding(.horizontal, 7.5)
                        }.fixedSize(horizontal: false, vertical: true)
                    }
                    Text("Choosing where your archive is stored allows you to store files on an external drive, whether it be the cloud or a physical drive you can plug into another device.")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 15)
                    Text("Updates")
                        .font(.title2.bold())
                    ZStack {
                        Rectangle().foregroundColor(.init("Accent").opacity(0.1))
                            .cornerRadius(15)
                        HStack {
                            Text("Current Version: ") + Text(getCurrentVersionAndBuild()).bold()
                            Spacer()
                            VIButton(id: "githubUpdates", h: $hovered) {
                                Image("GitHubMark")
                                Text("Check GitHub")
                            } onClick: {
                                NSWorkspace.shared.open(URL(string: "https://github.com/Ben216k/Archived/releases/latest")!)
                            }.inPad().padding(.horizontal, -6.5)
                        } .padding(5)
                            .padding(.horizontal, 7.5)
                    }.fixedSize(horizontal: false, vertical: true)
                        .padding(.top, -5)
                        .padding(.bottom, 2)
                    Text("This feature is not currently available for this release. Please wait until a future update for this functionality. For the time being, if there is a new update, delete this app from the Applications folder and install a new version. Data will be saved from older versions.")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 15)
                    
                    // MARK: Support and Community
                    
                    Text("Support and Community")
                        .font(.title2.bold())
                    HStack(spacing: 15) {
                        VIButton(id: "githubMain", h: $hovered) {
                            Image("GitHubMark")
                            Text("GitHub")
                        } onClick: {
                            NSWorkspace.shared.open(URL(string: "https://github.com/Ben216k/Archived/")!)
                        }.inPad()
                        VIButton(id: "discordMain", h: $hovered) {
                            Image("DiscordMark")
                            Text("Discord")
                        } onClick: {
                            NSWorkspace.shared.open(URL(string: "https://discord.gg/2DxVn4HDX6")!)
                        }.inPad().padding(.horizontal, -6.5)
                        Spacer()
                    }.padding(.top, -5)
                        .padding(.bottom, 2)
                    Text("Finding bugs? Have questions? Came up with some suggestions? You can join the community on Discord for discussions. If you run into any issues, GitHub has an issues tab for all bugs that rise. Archived is in beta, so feedback is greatly appreciated.")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 15)
                }
                Rectangle()
                    .frame(height: 0)
            }.padding([.horizontal, .top], 15)
                .font(.system(size: 11.5))
        }
            .navigationTitle(Text("Preferences"))
    }
}


func convertToSHA256(str: String) -> String {
    let inputData = Data(str.utf8)
    let hashed = SHA256.hash(data: inputData)
    let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
    print(hashString)
    return hashString
}

func getCurrentVersionAndBuild() -> String {
    if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
       let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
        return "\(version) (\(build))"
    } else {
        return "Version information not available"
    }
}
