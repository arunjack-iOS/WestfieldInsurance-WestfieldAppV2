//
//  LoginViewController.swift
//  WestfieldAppV2
//
//  Created by Arun Jack on 22/12/17.
//  Copyright © 2017 Arun Jack. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, MiscellaneousServiceDelegate {
    
    
    var  indicatorView = ActivityView()
    var timerTest : Timer?

    let sharedInstnce = watsonSingleton.sharedInstance
    var logIndata : NSArray = []

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgotPwdButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    
    lazy var logInService: MiscellaneousService = MiscellaneousService(delegate:self)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.intialSetup()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        OrientationUtility.lockOrientation(.portrait)
    }
    func intialSetup()  {
        
        // Touch backgroud to dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Text Field initial setups

        self.userNameField.delegate = self
        self.passwordField.delegate = self

        self.userNameField.text = "arun"
        self.passwordField.text = "arun"

        self.userNameField.layer.cornerRadius = 4.0
        self.userNameField.layer.borderColor = UIColor.iwiSilver.cgColor
        self.userNameField.layer.borderWidth = 1.0
        self.userNameField.setLeftPaddingPoints(10)
        
        self.passwordField.layer.cornerRadius = 4.0
        self.passwordField.layer.borderColor = UIColor.iwiSilver.cgColor
        self.passwordField.layer.borderWidth = 1.0
        self.passwordField.setLeftPaddingPoints(10)
        
        self.signInButton.layer.cornerRadius = 4.0
        
        // Keyboard stuff.
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)


    }
    @IBAction func signInButtonAction(_ sender: Any) {
        
        if self.userNameField.text == "" || self.passwordField.text == "" {
            let alert = UIAlertController(title: "Alert", message: "Username/Password should not be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            
            let isConnectedNetwork = networkConnection()
            let connected = isConnectedNetwork.isInternetAvailable()
            
            if connected{
                self.validateSigningUser(userName: self.userNameField.text!, password: self.passwordField.text!)
            }else{
                logInNetworkError()
            }
            
        }
    }
    
    func validateSigningUser(userName:String, password:String) {
        StartAnimating()
        signInButton.isEnabled = false
        signInButton.alpha = 0.5
        self.userNameField.isEnabled = false
        self.passwordField.isEnabled = false
        timerTest = Timer.scheduledTimer(timeInterval: 45.0, target: self, selector: #selector(enableLogIn), userInfo: nil, repeats: false)
        //signInButton.backgroundColor = UIColor.gray
        logInService.serviceCallforLogin(withText: userName, and: password)
    }

   
    
    
    func logInError() {
        signInButton.isEnabled = true
        self.userNameField.isEnabled = true
        self.passwordField.isEnabled = true
        signInButton.alpha = 1.0
        let alert = UIAlertController(title: "Error", message: "The username or password you entered is not correct. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func logInNetworkError() {
        let alert = UIAlertController(title: "Error", message: "Network is not available. Please try again once connected to network.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func logInUser() {

        print("Login User")
        
        guard let adviceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "adviceVC") as? AdviceViewController else {
            return
        }
        let nav = UINavigationController(rootViewController: adviceVC)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = nav

       // self.navigationController?.pushViewController(adviceVC, animated: true)

    }

    
    //MARK:  -  TextField Delegates
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 150
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("TextField should return method called")
        
        if textField == userNameField {
            passwordField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder();
        }
        return true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    @objc func enableLogIn() {
        stopAnimating()
        signInButton.isEnabled = true
        signInButton.alpha = 1.0
        self.userNameField.isEnabled = true
        self.passwordField.isEnabled = true
        let alert = UIAlertController(title: "Error", message: "Session expired, please try again", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func StartAnimating() {
        
        indicatorView.frame = CGRect(x:0,y:0,width:50,height:50)
        indicatorView.center = self.view.center//CGPoint(x:self.view.center,y:self.view)
        indicatorView.lineWidth = 5.0
        indicatorView.strokeColor = UIColor(red: 0.0/255, green: 122.0/255, blue: 255.0/255, alpha: 1)
        self.view.addSubview(indicatorView)
        indicatorView.startAnimating()
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    func stopAnimating() {
        signInButton.isEnabled = true
        signInButton.alpha = 1.0
        indicatorView.stopAnimating()
        indicatorView.hidesWhenStopped = true
        indicatorView.removeFromSuperview()
        
        
    }
    
    
    // MARK:- MiscellaneousServiceDelegate
    func didReceiveMessage(withText text: Any) {
        
        stopAnimating()
        if timerTest != nil {
            timerTest?.invalidate()
            timerTest = nil
        }
        print("myValue>>>\(text)")
        
        if let logIndata = text as? NSArray{
            self.logIndata = logIndata
        }
        
        // self.logIndata = text as? NSArray
        
        // guard let count = self.logIndata.count else { return <#return value#> }
        
        if self.logIndata.count>0{
            UserDefaults.standard.setValue(self.logIndata, forKey: "UserDetail")
            
            let dict2 = self.logIndata[0] as? Dictionary<String,AnyObject>
            
            let voiceVal = (dict2?["voice"] as? String!)!
            
            print(voiceVal ?? "")
            
            if (voiceVal == "on") {
                sharedInstnce.isVoiceOn = true
            }else{
                sharedInstnce.isVoiceOn = false
            }
            
            self.logInUser()
        }else{
            self.logInError()
        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

