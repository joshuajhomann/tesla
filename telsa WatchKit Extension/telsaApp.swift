//
//  telsaApp.swift
//  telsa WatchKit Extension
//
//  Created by Joshua Homann on 1/29/21.
//

import SwiftUI

@main
struct telsaApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
