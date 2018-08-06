/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {
    
    func alertController(_ title : String , _ message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var isDriveSwitch: UISwitch!
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var signUpSwitchOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
var signupMode = true
    @IBAction func sighnUpAction(_ sender: Any) {
        if textFieldUsername.text == "" || textFieldPassword .text == ""
        {
            alertController("Error in Form", "Username & Password are required")
        }
        else
        {
            if signupMode
            {
               let user = PFUser()
                user.username = textFieldUsername.text
                user.password = textFieldPassword.text
                user["isDrive"] = isDriveSwitch.isOn
                user.signUpInBackground { (success, error) in
                    if let error = error
                    {
                        var displayedError = "Please try again later"
                        self.alertController("Sign Up Failed", displayedError)
                    }
                    else
                    {
                        print("Sign Up Successfully")
                        if let isDrive = PFUser.current()?["isDrive"] as? Bool {
                            if isDrive
                            {
                                 self.performSegue(withIdentifier: "showDriverViewController", sender: self)
                            }
                            else
                            {
                               self.performSegue(withIdentifier: "showRiderViewController", sender: self)
                            }
                        }
                    }
                }
               
            }
           
            else
            {
                PFUser.logInWithUsername(inBackground: textFieldUsername.text!, password: textFieldPassword.text!) { (user, error) in
                    if let error = error
                    {
                        var displayedError = "Please try again later"
                        self.alertController("Sign Up Error", displayedError)
                    }
                    else
                    {
                        print("Log In Successfully")
                        if let isDrive = PFUser.current()?["isDrive"] as? Bool {
                            if isDrive
                            {
                                 self.performSegue(withIdentifier: "showDriverViewController", sender: self)
                            }
                            else
                            {
                                self.performSegue(withIdentifier: "showRiderViewController", sender: self)
                            }
                        }
                    }
                }
            }
            
        }
       
       
       
    }
    
    @IBAction func switchSignUpMode(_ sender: Any) {
        if signupMode {
            signUpOutlet.setTitle("Log In", for: [])
            signUpSwitchOutlet.setTitle("Switch to Sign Up", for: [])
            signupMode = false
            isDriveSwitch.isHidden = true
            riderLabel.isHidden = true
            driverLabel.isHidden = true
        }
        else
        {
            signUpOutlet.setTitle("Sign Up", for: [])
            signUpSwitchOutlet.setTitle("Switch to Log In", for: [])
            signupMode = true
            isDriveSwitch.isHidden = false
            riderLabel.isHidden = false
            driverLabel.isHidden = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if let isDrive = PFUser.current()?["isDrive"] as? Bool {
            if isDrive
            {
                performSegue(withIdentifier: "showDriverViewController", sender: self)
            }
            else
            {
                self.performSegue(withIdentifier: "showRiderViewController", sender: self)
            }
        }
    }
}
