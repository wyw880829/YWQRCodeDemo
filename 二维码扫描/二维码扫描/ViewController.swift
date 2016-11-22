//
//  ViewController.swift
//  二维码扫描
//
//  Created by wyw on 16/11/18.
//  Copyright © 2016年 wyw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var qrcodeLable: UILabel!
    
    override func viewDidLoad() {
        
    }
    
    
    @IBAction func QRCodeClick(_ sender : Any) {
        
        let NAV = UIStoryboard.init(name: "QRCodeViewController", bundle: nil).instantiateInitialViewController() as! UINavigationController

        present(NAV, animated: false, completion: nil)
        
        let VC = NAV.topViewController as! QRCodeViewController
        VC.stringClosure = { (qrcString : String) -> Void in
            print("qrcString = \(qrcString)")
            self.qrcodeLable.text = qrcString
        }
        
    }
}

