//
//  VIHomePageViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 20/05/1444 AH.
//

import UIKit
import Firebase
import CoreNFC

class VIHomePageViewController: UIViewController , NFCNDEFReaderSessionDelegate {
  
    
    @IBOutlet weak var NFCmsg: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func PlacesTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "places")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    @IBAction func FavListTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "FavList")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    
    @IBAction func askForHelpTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "askForHelp")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    var nfcSession: NFCNDEFReaderSession?
    var word = "none"
    @IBAction func nfcreaderbtn(_ sender: Any) {
        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
         
        
    }
    
    @objc func didTapReadNFC(){
        
    }
    
    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("the session was invalidated: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var result = ""
        for payload in messages[0].records{
            result += String.init(data: payload.payload.advanced(by: 3), encoding: .utf8) ?? "format not supported"
        }
        
        DispatchQueue.main.async {
         //   self.NFCmsg.text = result
            let alert = UIAlertController(title: "", message: result , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "حسنًا", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
}
