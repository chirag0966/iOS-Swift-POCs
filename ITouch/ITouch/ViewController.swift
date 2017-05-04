import UIKit
import LocalAuthentication

let STORYBOARD : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
let COLOR_BLUE = UIColor(red: 30/255, green: 127/255, blue: 171/255, alpha: 1)

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldBox1: TextBox!
    @IBOutlet weak var textFieldBox2: TextBox!
    @IBOutlet weak var textFieldBox3: TextBox!
    @IBOutlet weak var textFieldBox4: TextBox!
    
    var textBoxes = [TextBox]()
    var pinInput = ""
    let PIN = "1234"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EHFAuthenticator.sharedInstance.reason = "Touch Home Button To Get In"
        
        setUpTouchID()
        
        textBoxes = [textFieldBox1, textFieldBox2, textFieldBox3, textFieldBox4]
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer
			= UITapGestureRecognizer(target: self, action: #selector(ViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        for textBox in textBoxes {
            textBox.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        resetTestFields()
        
        self.navigationController?.navigationBarHidden = true
        
        var error : NSError?
        if (!EHFAuthenticator.canAuthenticateWithError(&error)) {
            var authErrorString = "Check your Touch ID Settings."
            if let code = error?.code {
                switch (code) {
                case LAError.TouchIDNotEnrolled.rawValue:
                    authErrorString = "No Touch ID fingers enrolled.";
                    break;
                case LAError.TouchIDNotAvailable.rawValue:
                    authErrorString = "Touch ID not available on your device.";
                    break;
                case LAError.PasscodeNotSet.rawValue:
                    authErrorString = "Need a passcode set to use Touch ID.";
                    break;
                default:
                    authErrorString = "Check your Touch ID Settings.";
                }
            }
            print(authErrorString)
        }
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        for textBox in textBoxes {
            textBox.resignFirstResponder()
        }
    }
    
    func resetTestFields(){
        
        self.pinInput = ""
        self.textBoxes.first?.becomeFirstResponder()
        
        for textBox in self.textBoxes {
            textBox.text = ""
        }
    }
    
    func setUpTouchID(){
        
        EHFAuthenticator.sharedInstance.authenticateWithSuccess({
            
            self.goToNextVC()
            
            }, failure:{ errorCode in
                
                var authErrorString : NSString
                
                var shouldAskForSettings : Bool = false
                
                switch (errorCode) {
                case LAError.SystemCancel.rawValue:
                    authErrorString = "System canceled auth request due to app coming to foreground or background.";
                    break;
                case LAError.AuthenticationFailed.rawValue:
                    authErrorString = "User failed after a few attempts.";
                    break;
                case LAError.UserCancel.rawValue:
                    authErrorString = "User cancelled.";
                    break;
                    
                case LAError.UserFallback.rawValue:
                    authErrorString = "Fallback auth method should be implemented here.";
                    break;
                case LAError.TouchIDNotEnrolled.rawValue:
                    
                    authErrorString = "No Touch ID fingers enrolled.";
                    
                    shouldAskForSettings = true
                    
                    break;
                case LAError.TouchIDNotAvailable.rawValue:
                    
                    authErrorString = "Touch ID not available on your device.";
                    break;
                case LAError.PasscodeNotSet.rawValue:
                    
                    authErrorString = "Need a passcode set to use Touch ID.";
                    
                    shouldAskForSettings = true
                    
                    break;
                default:
                    
                    authErrorString = "Check your Touch ID Settings.";
                    
                    shouldAskForSettings = true
                    
                    break;
                }
                
                if shouldAskForSettings {
                    
                    let alertController = UIAlertController(title:"Touch ID", message: authErrorString as String, preferredStyle:.Alert)
                    alertController.addAction (UIAlertAction(title: "OK", style: .Default, handler: self.openSettings))
                    alertController.addAction (UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }else {
                    
                    self.presentAlertControllerWithMessage(authErrorString)
                }
        })
    }
    
    @IBAction func buttonTap(sender: UIButton) {
        setUpTouchID()
    }
    
    func openSettings(alert: UIAlertAction!){
        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
    }
    
    func presentAlertControllerWithMessage(message : NSString) {
        
        let alertController = UIAlertController(title:"Touch ID", message:message as String, preferredStyle:.Alert)
        
        alertController.addAction (UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text?.characters.count < 1 && string.characters.count > 0 {
            
            textField.text = string
            
            if !(textField == textBoxes.last) {
                
                let index = textBoxes.indexOf(textField as! TextBox)! + 1
                textBoxes[index].becomeFirstResponder()
            }
            
            pinInput = ""
            
            for textBox in textBoxes {
                pinInput = pinInput + textBox.text!
            }
            
            if pinInput == PIN {
                
                goToNextVC()
            }else if pinInput.characters.count >= 4{
                
                resetTestFields()
                self.presentAlertControllerWithMessage("Invalid PIN \nTry 1234")
            }
            
            return false
            
        }else if (textField.text?.characters.count == 1  && string.characters.count == 0) {
            
            textField.text = ""
            
            pinInput.removeAtIndex(pinInput.characters.indexOf(pinInput.characters.last!)!)
            
            if !(textField == textBoxes.first) {
                
                let index = textBoxes.indexOf(textField as! TextBox)! - 1
                textBoxes[index].becomeFirstResponder()
            }
            
            return false
            
        }else if string.characters.count == 0 {
            
            return true
        }else {
            
            return false
        }
    }
    
    func goToNextVC() {
        
        let nextVC = STORYBOARD.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
        self.navigationController?.navigationBar.tintColor = COLOR_BLUE
        self.navigationItem.title = ""
        self.navigationController?.navigationBarHidden = false
    }
}
