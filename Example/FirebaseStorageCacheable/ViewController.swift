//
//  ViewController.swift
//  FirebaseStorageCacheable
//
//  Created by jaredanderton on 01/30/2019.
//  Copyright (c) 2019 jaredanderton. All rights reserved.
//

import UIKit
import FirebaseStorageCacheable

struct Foo: FirebaseStorageCacheable {
    
    static var targetFileName = "master.json"
    
    static var remoteFileName = "master.json"
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

