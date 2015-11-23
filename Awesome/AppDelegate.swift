//
//  AppDelegate.swift
//  Awesome
//
//  Created by Marshall Brekka on 3/27/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Cocoa
import Carbon

func OnHotKeyDown(handler: EventHandlerCallRef, event: EventRef, managerPtr: UnsafeMutablePointer<Void>) -> OSStatus {
    print("got called", handler, event)
    return noErr
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

//    @IBOutlet weak var window: NSWindow!
    
    var context: AWJSContext?
    var manager: AWManager?
    var menuItem:AWStatusItem?
    var menuTarget:AWStatusTarget?
    var hk:AWHotKeyManager?
    var ms:AWMouse?
    var accessibilityEnabled:AWAccessibilityEnabled?
    var ref:EventHotKeyRef = nil
    private var observerContext = 0
    //var HKM2:AWHotKeyManager?


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        AWAccessibilityAPI.promptToTrustProcess()
        accessibilityEnabled = AWAccessibilityEnabled()
        menuTarget = AWStatusTarget(accessibility: accessibilityEnabled!)
        menuItem = AWStatusItem(target:menuTarget!)
        hk = AWHotKeyManager()
        if accessibilityEnabled!.enabled {
            startApp()
        }
        
        hk!.addHotKey("r", modifiers: ["ctrl", "opt", "cmd"], callback: {(down: Bool, key:String, modifiers:[String]) in
            if !down {
                self.reloadJS()
            }
        })
        accessibilityEnabled?.addObserver(self, forKeyPath: "enabled", options: .New, context: &context)
    }
    
    func startApp() {
        NSLog("staring app")
        manager = AWManager()
        loadJSEnvironment()
    }
    
    func stopApp() {
        NSLog("stopping app")
        manager = nil
        context = nil
    }
    
    func reloadJS() {
        NSLog("reloading js")
        if (manager != nil) {
            context = nil
            loadJSEnvironment()
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &self.context {
            if accessibilityEnabled!.enabled {
                startApp()
            } else {
                stopApp()
                AWAccessibilityAPI.promptToTrustProcess()
            }
        }
    }
    
    
    
    func loadJSEnvironment() {
        if let filePath = AWPreferences.getString(AWPreferences.JSFilePath) {
            do {
                let contents = try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
                context = AWJSContext(manager: manager!, hotKeys: hk!, customContent: contents)
                
            } catch _ {
                print("ERROR", filePath)
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        print("terminating")
        
    }


}

