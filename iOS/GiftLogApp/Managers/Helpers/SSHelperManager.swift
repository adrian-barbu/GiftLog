//
//  SSHelper.swift
//
//  Created by Serhii Kharauzov on 12/23/15.
//  Copyright © 2015 Webs The Word. All rights reserved.
//

import Foundation
import MessageUI
import CoreLocation

typealias AlertViewConfirmCompletionHandler         = () -> Void
typealias AlertViewConfirmCancelHandler             = () -> Void

//MARK: iOS System constants

private enum UIUserInterfaceIdiom : Int {
    case unspecified
    case phone
    case pad
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad
}

/** This class created for gathering and using some popular methods, that help to make development process easy. */

class SSHelperManager:NSObject {
   
    // MARK: Properties
    
    static let shared = SSHelperManager()
    var mailComposerVC: MFMailComposeViewController!
    var messageComposerVC: MFMessageComposeViewController!
    
    override init() {
        if MFMessageComposeViewController.canSendText() {
            messageComposerVC = MFMessageComposeViewController()
        }
        if MFMailComposeViewController.canSendMail() {
            mailComposerVC = MFMailComposeViewController()
        }
    }
    
    func makeShakeAnimationOfView(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }
    
    /** Count flexible height for cell depending on its content. */
    func heightForViewWithContentString(_ content:String, viewWidth width:CGFloat, font fontSize:CGFloat, minimuSize:CGFloat) -> CGFloat {
        let fontSize:CGFloat = fontSize
        let viewContentWidth:CGFloat = width
        let viewContentMargin:CGFloat = 10.0 // 5.0 - default
        let text = content
        let constraint:CGSize =  CGSize(width: viewContentWidth - (viewContentMargin * 2), height: 20000.0)
        let attributedText:NSAttributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)])
        let rect:CGRect = attributedText.boundingRect(with: constraint, options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size:CGSize = rect.size
        let height:CGFloat = max(size.height,minimuSize)
        return height
    }
    
    /** Make call from device on phone number. */
    func makeCallOnPhoneNumber(_ phoneNumber:String) {
        if DeviceType.IS_IPAD {
            UIAlertController.showAlertWithTitle("Error", message: phoneNumber)
        } else {
            var number = phoneNumber
            number = number.replacingOccurrences(of: "+", with: "")
            number = number.replacingOccurrences(of: "(", with: "")
            number = number.replacingOccurrences(of: ")", with: "")
            number = number.replacingOccurrences(of: "-", with: "")
            number = number.replacingOccurrences(of: " ", with: "")
            if let url = URL(string: "tel://\(number)") {
                UIApplication.shared.openURL(url) // calling
            }
        }
    }
    
    func showShareActionSheetFromController(_ controller: UIViewController, withText text: String) {
        let sharedObjects = ["\(text)\nDownload the app: " as AnyObject, Constants.appStoreLink as AnyObject] as [AnyObject]
        let activityController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        if let popoverController = activityController.popoverPresentationController {
            popoverController.sourceView = controller.view
            popoverController.sourceRect = CGRect(x: controller.view.center.x, y: UIScreen.main.bounds.height, width: 1, height: 10)
        }
        controller.present(activityController, animated: true, completion: nil)
    }

    /** Check if email is valid */
    func isValidEmail(_ email:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    /* Use this method for textFields only */
    func areAllTextFieldsEnteredInView(_ view: UIView) -> Bool {
        for subview in view.subviews {
            if subview is UITextField {
                if (subview as! UITextField).text!.isEmpty {
                    return false
                }
            }
        }
        return true
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        if password.characters.count < Constants.minPasswordLength {
            return false
        }
        return true
    }
  
    func getBoldAttributedStringFromString(_ initialString: String, stringToMakeBold: String, color: UIColor, fontSize: CGFloat) -> NSMutableAttributedString {
      let stringToMakeBold = stringToMakeBold
      let initialString = initialString
      let fontSize: CGFloat = fontSize
      let attributes = [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize), NSForegroundColorAttributeName: color]
      let boldAttribute = [NSFontAttributeName:UIFont.boldSystemFont(ofSize: fontSize), NSForegroundColorAttributeName: color]
      // For Facebook
      let string = initialString.appending(stringToMakeBold)
      let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
      let nsString = NSString(string: string)
      let range = nsString.range(of: stringToMakeBold)
      if range.length > 0 { attributedString.setAttributes(boldAttribute, range: range) }
      return attributedString
    }
    
    func setUnderlinedAttributed(_ string: String, with color: UIColor, fontSize: CGFloat, font: String?) -> NSMutableAttributedString {
        var fontToUse = UIFont.systemFont(ofSize: fontSize)
        if font != nil {
            fontToUse = UIFont(name: font!, size: fontSize)!
        }
        let stringAttributes : [String: Any] = [
            NSFontAttributeName : fontToUse,
            NSForegroundColorAttributeName : color,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
        ]
        return NSMutableAttributedString(string: string, attributes: stringAttributes)
    }
    
    func setEmptyBackNavigationButtonIn(_ controller: UIViewController) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        controller.navigationItem.backBarButtonItem = backItem
    }
}

extension UIViewController {
  
    /** Get last visible window */
    static func lastWindow() -> UIWindow? {
        return UIApplication.shared.windows.last ?? nil
    }
    
    /** Get visible viewcontroller from any class . */
    static func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        var rootViewController = rootViewController
        if rootViewController == nil { rootViewController = UIApplication.shared.delegate!.window!!.rootViewController }
        
        if let nav = rootViewController as? UINavigationController {
            return getVisibleViewController(nav.visibleViewController)
        }
        
        if let tab = rootViewController as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController , top.view.window != nil {
                return getVisibleViewController(top)
            } else if let selected = tab.selectedViewController {
                return getVisibleViewController(selected)
            }
        }
        
        if let presented = rootViewController?.presentedViewController {
            return getVisibleViewController(presented)
        }
        
        return rootViewController
    }
}

extension UIAlertController {

    /** Show alertView with two options : 'Confirm' and 'Cancel' . */
    
    static func showAlertWithTitle(_ titleText:String, message messageText:String, cancelButtonText cancelText:String, confirmButtonText confirmText:String , confirmCancelHandler:AlertViewConfirmCancelHandler?, confirmCompletionHandler:AlertViewConfirmCompletionHandler?) {
        
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelText, style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            if let handler = confirmCancelHandler {
                handler()
            }
            
        }))
        alert.addAction(UIAlertAction(title: confirmText, style: .default, handler: { (action) -> Void in
            if let handler = confirmCompletionHandler {
                handler()
            }
        }))
        
        let currentController = UIViewController.getVisibleViewController(nil)
        if let controller = currentController {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    /** Show alertView with one option : 'Ok' . */
   
    static func showAlertWithTitle(_ titleText:String, message messageText:String) {
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        // Must not search needed controller in all view hierarchy, beacause of possible issues
        let currentController = UIViewController.getVisibleViewController(nil)
        if let controller = currentController {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    //FIXME: Remove in production this code
    static func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Debug mode", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        // Must not search needed controller in all view hierarchy, beacause of possible issues
        let currentController = UIViewController.getVisibleViewController(nil)
        if let controller = currentController {
            controller.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: MFMailComposeViewController

extension SSHelperManager: MFMailComposeViewControllerDelegate {
    
    func showMailComposerFor(recipients: [String], withText text: String, withFile file: Data? = nil) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = configuredMailComposeViewController(recipients: recipients, withText: text, withFile: file)
            let currentController = UIViewController.getVisibleViewController(nil)
            if let controller = currentController {
                controller.present(mailComposeViewController, animated: true)  {
                    
                }
            }
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController(recipients: [String], withText text: String, withFile file: Data? = nil) -> MFMailComposeViewController {
        if mailComposerVC == nil {
            mailComposerVC = MFMailComposeViewController()
        }
        if let file = file {
            mailComposerVC.addAttachmentData(file, mimeType: "text/csv", fileName: "AppData.csv")
        }
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(recipients)
        mailComposerVC.setMessageBody(text, isHTML: false)
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("Cannot send email", comment: ""),
                                             message: NSLocalizedString("For allowing device to send email please check your mail settings and try again.", comment: ""), delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: {
            self.mailComposerVC = nil
        })
    }
}

// MARK: MFMessageComposeViewController

extension SSHelperManager: MFMessageComposeViewControllerDelegate {
    
    func showMessageComposerFor(recipients: [String], withText text: String) {
        if MFMessageComposeViewController.canSendText() {
            let messageComposeViewController = configuredMessageComposeViewController(recipients: recipients, withText: text)
            let currentController = UIViewController.getVisibleViewController(nil)
            if let controller = currentController {
                controller.present(messageComposeViewController, animated: true)  {
                }
            }
        } else {
            self.showSendMessageErrorAlert()
        }
    }
    
    func configuredMessageComposeViewController(recipients: [String], withText text: String) -> MFMessageComposeViewController {
        if messageComposerVC == nil {
            messageComposerVC = MFMessageComposeViewController()
        }
        messageComposerVC.messageComposeDelegate = self
        messageComposerVC.recipients = recipients
        messageComposerVC.body = text
        return messageComposerVC
    }
    
    func showSendMessageErrorAlert() {
        let sendMessageErrorAlert = UIAlertView(title: NSLocalizedString("Cannot send message", comment: ""),
                                             message: NSLocalizedString("For allowing device to send message please check your message settings and try again.", comment: ""), delegate: self, cancelButtonTitle: "OK")
        sendMessageErrorAlert.show()
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: {
            self.messageComposerVC = nil
        })
    }

}
