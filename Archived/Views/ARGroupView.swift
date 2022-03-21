//
//  ARGroupView.swift
//  Archived
//
//  Created by Ben Sova on 3/20/22.
//

import VeliaUI
import SwiftUI

struct ARGroupView: View {
    @Binding var group: ARGroup
    var body: some View {
        Text(group.title).toolbar() {
            ToolbarItem {
                Button {
                    
                } label: {
                    Label {
                        Text("Patched Sur")
                    } icon: {
                        Image(systemName: "circle")
                    }
                }
            }
        }.navigationTitle(Text(group.title))
            .navigationSubtitle(Text(group.category))
    }
}

func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
