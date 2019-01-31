//
//  ViewController.swift
//  FirebaseStorageCacheable
//
//  Created by jaredanderton on 01/30/2019.
//  Copyright (c) 2019 jaredanderton. All rights reserved.
//

import UIKit
import FirebaseStorageCacheable

class MyReplaceable: FirebaseStorageCacheable {
    static var remotePath: String = "gs://remote/path/to/your/file.json"
    static var targetPath: String = "/local/path/relative/to/your/apps/Documents/cached.json"
    static var bundledFileName: String = "bundled.json"
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // check if the file has been cached locally
        if !MyReplaceable.targetFileExists {
            // copy the file from the bundle, if provided
            MyReplaceable.writeFromBundle(onComplete: {
                // copy from bundle to app documents directory succeeded
            },onError: { (error: FirebaseStorageCacheableError?) in
                // handle error
            })
        }
        
        // get the date of the last time the remote file was modified
        MyReplaceable.getRemoteModified(onComplete: { date in
            print("last updated: \(date)")
        }, onError: { error in
            // handle error
        })
        
        // check to see if there is an updated version
        MyReplaceable.checkForUpdate(onComplete: { (status: FirebaseStorageCacheableStatus) in
            switch status {
            case .updateAvailable:
                // you could trigger the .update method here
                print("Update is available")
            case .upToDate:
                // your could display to the user they have up to date information
                print("File is up to data")
            }
        }, onError: { (error: FirebaseStorageCacheableError?) in
            // handle error
        })
        
        // download the most recent version
        MyReplaceable.update(onComplete: { (replaced: Bool) in
            if replaced {
                // file was replaced, you now have an updated version
            } else {
                // file was not replaced
            }
        }, onError: { (error: FirebaseStorageCacheableError?) in
            // handle error
        }, inProgress: { (fractionComplete: Double?) in
            // Update UI with download progress (this closure param optional)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

