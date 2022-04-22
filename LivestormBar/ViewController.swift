//
//  ViewController.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import Cocoa
import OAuth2
import Quartz

let OAuth2AppDidReceiveCallbackNotification = NSNotification.Name(rawValue: "OAuth2AppDidReceiveCallback")

class ViewController: NSViewController {
    
    let loader = GoogleLoader()

    @IBOutlet weak var ConnectToCalendarButton: NSButton!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var ikAvatar: IKImageView!
    

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

    @IBAction func connectToYourGoogleCalendar(_ sender: Any) {

        // show what is happening
        ConnectToCalendarButton?.title = "Authorizing..."
        ConnectToCalendarButton?.isEnabled = false
        
        // config OAuth2
        loader.oauth2.authConfig.authorizeContext = view.window
        NotificationCenter.default.removeObserver(self, name: OAuth2AppDidReceiveCallbackNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleRedirect(_:)), name: OAuth2AppDidReceiveCallbackNotification, object: nil)
        loader.requestUserdata() { dict, error in
            if let error = error {
                switch error {
                case OAuth2Error.requestCancelled:
                    self.ConnectToCalendarButton?.title = "Cancelled. Try Again."
                default:
                    self.ConnectToCalendarButton?.title = "Failed. Try Again."
                    self.show(error)
                }
            }
            else {
                if let imgURL = dict?["picture"] as? String {
                    // This does not work for NSImageView and drives my crazy and forces me to use IKImageView
                    //let image = NSImage(byReferencing:NSURL(string: imgURL)! as URL)
                    //self.avatarImage?.image = image
                    self.ikAvatar?.setImageWith(URL(string: imgURL)!)

                }
                if let username = dict?["name"] as? String {
                    self.nameLabel?.stringValue = "Hello there, \(username)!"
                }
                else {
                    self.nameLabel?.stringValue = "Failed to fetch your name"
                    NSLog("Fetched: \(String(describing: dict))")
                }
                self.ConnectToCalendarButton?.title = "Disconnect"
            }
            self.ConnectToCalendarButton?.isEnabled = true
            self.nameLabel?.isHidden = false
        }
    }

    
    @objc func handleRedirect(_ notification: Notification) {
        if let url = notification.object as? URL {
            NSLog("Handling redirect...")
            do {
                try loader.oauth2.handleRedirectURL(url)
            }
            catch let error {
                NSLog("handleRedirect: \(error)")
            }
        }
        else {
            NSLog("ici une erreur")
            //show(NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid notification: did not contain a URL"]))
        }
    }
    


    /** Forwards to `display(error:)`. */
    func show(_ error: Error) {
        if let error = error as? OAuth2Error {
            let err = NSError(domain: "OAuth2ErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: error.description])
            display(err)
        }
        else {
            display(error as NSError)
        }
    }
    
    /** Alert or log the given NSError. */
    func display(_ error: NSError) {
        if let window = self.view.window {
            NSAlert(error: error).beginSheetModal(for: window, completionHandler: nil)
            nameLabel?.stringValue = error.localizedDescription
        }
        else {
            NSLog("Error authorizing: \(error.description)")
        }
    }
}

