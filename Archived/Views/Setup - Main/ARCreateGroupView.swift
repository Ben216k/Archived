//
//  ARCreateGroupView.swift
//  Archived
//
//  Created by Ben Sova on 5/9/21.
//

import VeliaUI
import SwiftUI
import AVFoundation

struct ARCreateGroupView: View {
    @State var name = ""
    @State var category = ""
    @State var hovered: String?
    @State var titleEmpty = false
    @State var categoryEmpty = false
    @Binding var processedGroups: [ARCategory]
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
                (Text(titleEmpty ? "Please enter a group title.\n" : "").foregroundColor(.red) + Text("This should be the name of the item you're going to archive several versions of. For example, if I was archiving all the versions of macOS Big Sur, I would just type in macOS Big Sur here."))
                    .font(.caption)
                    .padding(.bottom, 5)
                VITextField(text: $category, s: Image(systemName: "rectangle.3.offgrid")) {
                    Text("Category")
                        .opacity(0.5)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(processedGroups, id: \.title) { category in
                            VIButton(id: category.title, h: .init(get: { category.title == self.category ? category.title : hovered }, set: { newValue in
                                hovered = newValue
                            })) {
                                Text(category.title)
                            } onClick: {
                                self.category = category.title
                            }.inPad()

                        }
                    }
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
                VIButton(id: "CREATE", h: $hovered) {
                    Text("Create")
                    Image("CheckCircle")
                } onClick: {
                    (titleEmpty, categoryEmpty) = (false, false)
                    if name.isEmpty { titleEmpty = true; return }
                    if category.isEmpty { categoryEmpty = true; return }
                    onDone(.init(uuid: UUID().description, title: name, category: category, appArchives: []))
                }.inPad()
            }
            Button("") {
                onBack()
            }.buttonStyle(.borderless).keyboardShortcut(.cancelAction)
        }.textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
