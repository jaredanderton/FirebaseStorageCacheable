//
//  ViewController.swift
//  FirebaseStorageCacheable
//
//  Created by jaredanderton on 01/30/2019.
//  Copyright (c) 2019 jaredanderton. All rights reserved.
//

import UIKit
import FirebaseStorageCacheable

struct Foo: FirebaseStorageCacheable {}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Foo().temp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

