import UIKit

var greeting = "Hello, playground"

class ViewController: UIViewController, UITextViewDelegate {
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textView = UITextVi
        
        let text = NSMutableAttributedString(string: "Already have an account? ")
        text.addAttribute(NSAttributedStringKey.font,
                          value: UIFont.systemFont(ofSize: 12),
                          range: NSRange(location: 0, length: text.length))
        
        let interactableText = NSMutableAttributedString(string: "Sign in!")
        interactableText.addAttribute(NSAttributedStringKey.font,
                                      value: UIFont.systemFont(ofSize: 12),
                                      range: NSRange(location: 0, length: interactableText.length))
        
        // Adding the link interaction to the interactable text
        interactableText.addAttribute(NSAttributedStringKey.link,
                                      value: "SignInPseudoLink",
                                      range: NSRange(location: 0, length: interactableText.length))
        
        // Adding it all together
        text.append(interactableText)
        
        // Set the text view to contain the attributed text
        textView.attributedText = text
        
        // Disable editing, but enable selectable so that the link can be selected
        textView.isEditable = false
        textView.isSelectable = true
        textView.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        //Code to the respective action
        
        return false
    }
}

