//
//  ViewController.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        //view.window?.styleMask.remove(.resizable)
        //view.window?.styleMask.remove(.miniaturizable)
        //view.window?.center()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

