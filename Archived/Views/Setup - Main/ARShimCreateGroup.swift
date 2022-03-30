//
//  ARShimCreateGroup.swift
//  Archived
//
//  Created by Ben Sova on 3/20/22.
//

import SwiftUI
import Files

struct ARShimCreateGroup: View {
    @Binding var groups: ARGroups
    @Binding var creatingGroup: Bool
    @Binding var processedGroups: [ARCategory]
    var onDone: () -> ()
    var body: some View {
        ARCreateGroupView(processedGroups: $processedGroups) {
            groups.append($0)
            do {
                indexFile = try Folder(path: "~/Archived").createFileIfNeeded(at: "Index.json")
                try indexFile!.write(try groups.jsonData())
                creatingGroup = false
                onDone()
            } catch {
                presentAlert(m: "Failed to Create Archive Group", i: "\(error.localizedDescription)")
                creatingGroup = false
            }
        } onBack: {
            creatingGroup = false
        }
        .padding(30)
        .frame(width: 600, height: 400)
    }
}
