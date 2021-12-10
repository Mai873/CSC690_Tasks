//
//  EntryViewController.swift
//  CSC690_Task
//
//  Created by Mai Ra on 12/9/21.
//

import UIKit

class EntryViewController: UIViewController, UISearchTextFieldDelegate {
    @IBOutlet var field: UITextField!
    
    var update:(() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        field.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTask))

        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        saveTask()
        return true
    }
         @objc func saveTask(){
             guard let text = field.text, !text.isEmpty else {
                 return
             }
             
             guard let count = UserDefaults().value(forKey: "count") as? Int else {
                 return
             }
             let newCount = count + 1
             UserDefaults().set(newCount, forKey: "count")
             UserDefaults().set(text, forKey: "task_\(newCount)")
             
             update?()
             navigationController?.popViewController(animated: true)
    }
}
