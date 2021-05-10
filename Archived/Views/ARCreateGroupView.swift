//
//  ARCreateGroupView.swift
//  Archived
//
//  Created by Ben Sova on 5/9/21.
//

import VeliaUI

struct ARCreateGroupView: View {
    @State var name = ""
    @State var type = ""
    @State var category = ""
    @State var hovered: String?
    var body: some View {
        VStack {
            Text("Create Archive Group")
                .font(.title2.bold())
                .padding(.bottom, 5)
            VStack(alignment: .leading) {
                HStack {
                    Text("Group Title:")
                    TextField("Group Name", text: $name)
                }
                Text("This should be the name of the item you're going to archive several versions of. For example, if I was archiving all the versions of macOS Big Sur, I would just type in macOS Big Sur here.")
                    .font(.caption)
                    .padding(.bottom, 5)
                HStack {
                    Text("Group Type:")
                    TextField("Group Type", text: $type)
                }
                Text("This is type of item you're archiving. What you put in here won't effect how the item is archived, it'll just be some metadata. Maybe it's macOS app, OS ISOs or something else.")
                    .font(.caption)
                    .padding(.bottom, 5)
                HStack {
                    Text("Category:")
                    TextField("Category", text: $category)
                }
                Text("If you have multiple archive groups that fall under the same category, you can write that category name here. All groups that are in the same category will show up together in the sidebar. This category could be something like macOS versions or Ben's Apps.")
                    .font(.caption)
            }
            HStack {
                VIButton(id: "BACK", h: $hovered) {
                    Image("BackArrowCircle")
                    Text("Back")
                }.inPad()
                VIButton(id: "CREATE", h: $hovered) {
                    Text("Create")
                    Image("CheckCircle")
                }.inPad()
            }
        }.textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
