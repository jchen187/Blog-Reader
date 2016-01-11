//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Johnny Chen on 1/10/16.
//  Copyright (c) 2016 JohnnyChen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var webview: UIWebView!
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        
        //the detail item was set in the prepare for segue method
        if let detail: AnyObject = self.detailItem {
            //in case it runs before webview is created
            if let wv = self.webview {
                
                wv.loadHTMLString(detail.valueForKey("content")!.description, baseURL: nil)
//                label.text = detail.valueForKey("timeStamp")!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

