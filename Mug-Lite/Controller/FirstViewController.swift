//
//  FirstViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/24.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "firstSegue", sender: self)
    }
    
}
