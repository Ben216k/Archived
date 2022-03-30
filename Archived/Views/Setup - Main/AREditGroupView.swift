//
//  AREditGroupView.swift
//  Archived
//
//  Created by Ben Sova on 5/9/21.
//

import VeliaUI
import Files

struct AREditGroupView: View {
    @Binding var __group: ARGroup
    @State var group: ARGroup
    @State var hovered: String?
    @State var titleEmpty = false
    @State var categoryEmpty = false
    let onBack: () -> ()
    let onDone: () -> ()
    var body: some View {
        VStack {
            Text("Update Archive Group")
                .font(.title2.bold())
                .padding(.bottom, 5)
            VStack(alignment: .leading) {
//                HStack {
//                    Text("Group Title:")
//                    TextField("Group Title", text: $name)
//                }
                VITextField(text: $group.title, s: Image(systemName: "character.textbox")) {
                    Text("Group Title")
                        .opacity(0.5)
                }
                (Text(titleEmpty ? "Please enter a group title.\n" : "").foregroundColor(.red) + Text("This should be the name of the item you're going to archive several versions of. For example, if I was archiving all the versions of macOS Big Sur, I would just type in macOS Big Sur here."))
                    .font(.caption)
                    .padding(.bottom, 5)
                VITextField(text: $group.category, s: Image(systemName: "rectangle.3.offgrid")) {
                    Text("Category")
                        .opacity(0.5)
                }
                (Text(categoryEmpty ? "Please enter a category.\n" : "").foregroundColor(.red) + Text("If you have multiple archive groups that fall under the same category, you can write that category name here. All groups that are in the same category will show up together in the sidebar. This category could be something like macOS versions or Ben's Apps."))
                    .font(.caption)
            }
            HStack {
                VIButton(id: "BACK", h: $hovered) {
                    Image("BackArrowCircle")
                    Text("Back")
                } onClick: {
                    onBack()
                }.inPad()
                VIButton(id: "Update", h: $hovered) {
                    Text("Update")
                    Image("CheckCircle")
                } onClick: {
                    do {
                        (titleEmpty, categoryEmpty) = (false, false)
                        if group.title.isEmpty { titleEmpty = true; return }
                        if group.category.isEmpty { categoryEmpty = true; return }
                        if group.title != __group.title, let groupFolder = try? Folder(path: "/Users/\(NSUserName())/Archived/\(__group.title)") {
                            try groupFolder.rename(to: "\(group.title)")
                        }
                        __group = group
                        onDone()
                    } catch {
                        presentAlert(m: "Unable to Update Group", i: error.localizedDescription)
                    }
                }.inPad()
            }
        }.textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(30)
            .frame(width: 600, height: 400)
    }
}
