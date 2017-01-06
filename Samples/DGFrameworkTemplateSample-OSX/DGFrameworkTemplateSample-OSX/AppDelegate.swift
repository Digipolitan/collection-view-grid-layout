//
//  AppDelegate.swift
//  DGFrameworkTemplateSample-OSX
//
//  Created by Benoit BRIATTE on 23/12/2016.
//  Copyright © 2016 Digipolitan. All rights reserved.
//

import Cocoa
import DGFrameworkTemplate

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let t = TemplateClass()
        print(t)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
