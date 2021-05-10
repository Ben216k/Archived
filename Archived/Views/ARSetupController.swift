//
//  ARSetupController.swift
//  Archived
//
//  Created by Ben Sova on 5/9/21.
//

import VeliaUI

struct ARSetupController: View {
    @Binding var groups: ARGroups
    @Binding var needsSetup: Bool
    @State var page = 0
    var body: some View {
        Group {
            switch page {
            case 0:
                ARSetupWelcomeView(p: $page)
                    .transition(.moveAway)
            case 1:
                ARCreateGroupView()
                    .transition(.moveAway)
            default:
                Text("Uh oh!")
                    .transition(.moveAway)
            }
        }.padding(30)
        .frame(width: 600, height: 400)
    }
}

struct ARSetupWelcomeView: View {
    @State var hovered: String?
    @Binding var p: Int
    var body: some View {
        VStack {
            Text("Welcome to Archived")
                .font(.title2.bold())
            Text(welcomeText)
                .multilineTextAlignment(.center)
                .padding(.vertical)
            VIButton(id: "GET-STARTED", h: $hovered) {
                Text("Get Started")
                Image("ForwardArrowCircle")
            } onClick: {
                withAnimation {
                    p = 1
                }
            }.inPad()
        }
    }
}

fileprivate let welcomeText = """
Archived allows you to build a history of all your favorite things. Whether it be an app or an entire OS, Archived has you covered. It allows you to organize your items into a format that you like, keeping any metadata you might need.

Some things to know:
An individual archive is a specific version of a specifc thing.
An archive group is all the versions of that specific thing.

So let's get started with your first archive, shell we?
"""
