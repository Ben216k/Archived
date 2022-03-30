//
//  ARCreateGroupView.swift
//  Archived
//
//  Created by Ben Sova on 5/9/21.
//

import VeliaUI

struct ARCreateGroupView: View {
    @State var name = ""
    @State var category = ""
    @State var hovered: String?
    let onDone: (ARGroup) -> ()
    let onBack: () -> ()
    var body: some View {
        VStack {
            Text("Create Archive Group")
                .font(.title2.bold())
                .padding(.bottom, 5)
            VStack(alignment: .leading) {
//                HStack {
//                    Text("Group Title:")
//                    TextField("Group Title", text: $name)
//                }
                VITextField(text: $name, s: Image(systemName: "character.textbox")) {
                    Text("Group Title")
                        .opacity(0.5)
                }
                Text("This should be the name of the item you're going to archive several versions of. For example, if I was archiving all the versions of macOS Big Sur, I would just type in macOS Big Sur here.")
                    .font(.caption)
                    .padding(.bottom, 5)
                VITextField(text: $category, s: Image(systemName: "rectangle.3.offgrid")) {
                    Text("Category")
                        .opacity(0.5)
                }
                Text("If you have multiple archive groups that fall under the same category, you can write that category name here. All groups that are in the same category will show up together in the sidebar. This category could be something like macOS versions or Ben's Apps.")
                    .font(.caption)
            }
            HStack {
                VIButton(id: "BACK", h: $hovered) {
                    Image("BackArrowCircle")
                    Text("Back")
                } onClick: {
                    onBack()
                }.inPad()
                VIButton(id: "CREATE", h: $hovered) {
                    Text("Create")
                    Image("CheckCircle")
                } onClick: {
                    onDone(.init(uuid: UUID().description, title: name, category: category, appArchives: []))
                }.inPad()
            }
        }.textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
