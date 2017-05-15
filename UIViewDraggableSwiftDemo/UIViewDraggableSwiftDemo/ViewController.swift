//
//  ViewController.swift
//  UIViewDraggableSwiftDemo
//
//  Created by Victor Carreño on 6/15/15.
//  Copyright (c) 2015 Victor Carreño. All rights reserved.
//

import UIKit
import UIView_draggable



class ViewController: UIViewController {
    
    @IBOutlet var draggableViews: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        for view in self.draggableViews{
            view.enableDragging()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

