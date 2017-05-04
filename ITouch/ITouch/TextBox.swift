import UIKit

class TextBox: UITextField {
    
    let COLOR_GRAY = UIColor(red: 196/255, green: 198/255, blue: 198/255, alpha: 1).CGColor
    let COLOR_BLUE = UIColor(red: 30/255, green: 127/255, blue: 171/255, alpha: 1).CGColor
    
    override func drawRect(rect: CGRect) {
        
        if self.isFirstResponder() {
            
            self.layer.borderColor = COLOR_BLUE
            self.layer.borderWidth = 2
        }else {
            
            self.layer.borderWidth = 1
            self.layer.borderColor = COLOR_GRAY
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        
        super.becomeFirstResponder()
        self.layer.borderColor = COLOR_BLUE
        self.layer.borderWidth = 2
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        
        super.resignFirstResponder()
        self.layer.borderColor = COLOR_GRAY
        self.layer.borderWidth = 1
        return true
    }
}
