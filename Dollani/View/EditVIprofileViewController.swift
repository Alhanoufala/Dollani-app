//
//  EditVIprofileViewController.swift
//  Dollani
//
//  Created by Sara on 26/12/2022.
//

import UIKit
import Firebase
import FirebaseStorage

class EditVIprofileViewController: UIViewController, UITextFieldDelegate,UINavigationBarDelegate {
    //Text fields
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    
    //save button
    @IBOutlet weak var saveButton: UIButton!

    //Error messages
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var phoneNumError: UILabel!

    @IBOutlet weak var navBar: UINavigationBar!
    
    //avatar
    @IBOutlet weak var avatar: UIImageView!
    var image: UIImage? = nil
   
   
    override func viewDidLoad() {
        
        avatar?.layer.cornerRadius = (avatar?.frame.size.width ?? 0.0) / 2
        avatar?.clipsToBounds = true
        avatar?.layer.borderWidth = 3.0
        avatar?.layer.borderColor = UIColor.white.cgColor
        super.viewDidLoad()
        name.delegate = self
        phoneNum.delegate = self
        navBar.delegate = self
        
        name.textAlignment = .right
        phoneNum.textAlignment = .right
        
        saveButton.isEnabled = false
        
        retriveUserInfo()
        setupAvatar()
    }
    func checkForValidForm()
        {
            if  nameError.isHidden &&  phoneNumError.isHidden
            {
                saveButton.isEnabled = true
            }
            else
            {
                saveButton.isEnabled = false
            }
        }
    func retriveUserInfo(){
        let user = Auth.auth().currentUser
        if let user = user {
        
          let currentEmail = user.email
            print(currentEmail! )
            Firestore.firestore().collection("users").whereField("email",isEqualTo:currentEmail!).getDocuments { snapshot, error in
                if  error != nil {
                           // ERROR
                       }
                       else {
                           if(snapshot?.count != 0){
                            
                               let userName = snapshot?.documents.first?.get("name") as! String
                               let userPhoneNum = snapshot?.documents.first?.get("phoneNum") as! String
                               
                               
                               //Set textView
                               self.name.text = userName
                               self.phoneNum.text = userPhoneNum
                                
                               let profilePicUrl = snapshot?.documents.first?.get("profilePhoto") as! String
                                                              //set profile pic
                                                              let storageRef = Storage.storage().reference(forURL: profilePicUrl)
                                                              storageRef.downloadURL(completion: { (url, error) in
                                                                  
                                                                  let data = NSData(contentsOf: url!)
                                                                  let image = UIImage(data: (data! as NSData) as Data)
                                                                  
                                                                  
                                                                  self.avatar?.image = image
                                                              })
                           }
                       }
                   }
       
          // ...
        }
               
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let container = segue.destination as? VIcontainerViewController{
            container.index = 0
        }
    }

    
    @IBAction func nameField(_ sender: Any) {
        if let name = name.text
                {
                    if let errorMessage = invalidName(name)
                    {
                        nameError.text = errorMessage
                        nameError.isHidden = false
                    }
                    else
                    {
                        nameError.isHidden = true
                    }
                }
                checkForValidForm()
    }
    func invalidName(_ value: String) -> String?
        {
            if(value == "" || value.trimmingCharacters(in: .whitespaces) == ""){
                return "مطلوب"
            }
            let set = CharacterSet(charactersIn: value)
            if CharacterSet.decimalDigits.isSuperset(of: set)
            {
                return "يجب ان يتكون الاسم من احرف فقط"
            }
            
            if ( value.count > 20){
                           return "الحد الاقصى ٢٠ حرف"
                       }
            
            return nil    }
    


    @IBAction func phoneField(_ sender: Any) {
        if let phoneNumber = phoneNum.text
                {
                    if let errorMessage = invalidPhoneNumber(phoneNumber)
                    {
                        phoneNumError.text = errorMessage
                        phoneNumError.isHidden = false
                    }
                    else
                    {
                        phoneNumError.isHidden = true
                    }
                }
                checkForValidForm()
    }
    func invalidPhoneNumber(_ value: String) -> String?
        {
            
            if(value == "" || value.trimmingCharacters(in: .whitespaces) == ""){
                return "مطلوب"
            }
            if !validatePhoneNum(value: value)
            {
                return "رقم الهاتف غير صحيح"
            }
            
           
            return nil
        }
    func validatePhoneNum(value: String) -> Bool {
        let PHONE_REGEX = "^((05))[0-9]{8}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }


    

    @IBAction func saveTapped(_ sender: Any) {
        
        if(self.image == nil ){
            self.image = self.avatar?.image
        }
        //set image
        guard let imageSelected = self.image else{
            print("Avatar is nil")
            return
        }
        
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else{
            return
        }
        
    
        //get data
        guard let Name = name.text else {return}
        guard let Phone = phoneNum.text else {return}
        
        //update
        let user = Auth.auth().currentUser
        if let user = user {
            
            let currentEmail = user.email
        
            
            var CGEmail  = [String] ()
            Firestore.firestore().collection("users").whereField("email",isEqualTo: Auth.auth().currentUser!.email!).getDocuments { [self] snapshot, error in
                if  error != nil {
                    //                print(error.localizedDescription)}
                }
                else{
                    CGEmail = snapshot?.documents.first?.get("CGEmail") as! [String]
                    
                    for i in 0..<CGEmail.count {
                        Firestore.firestore().collection("helpRequests").document(Auth.auth().currentUser!.email! + "-" + CGEmail[i]).updateData(["VIName":Name, "VIPhoneNum":Phone])
                        
                        
                    }
                }
                       }
       
            
            
            //set image
            let storageRef = Storage.storage().reference(forURL: "gs://dollani-app.appspot.com")
            let storageProfileRef = storageRef.child("profile").child(user.uid)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            storageProfileRef.putData(imageData,metadata: metadata)
            { (StorageMetadata, error) in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                
                storageProfileRef.downloadURL(completion: {(url, error) in
                    if let metaImageUrl = url?.absoluteString{
                        
                        //update user collection
                        Firestore.firestore().collection("users").document(currentEmail!).updateData(["name":Name, "phoneNum":Phone, "profilePhoto": metaImageUrl ])
                    }
                })
            }
            
        }
        //alert
        let alert = UIAlertController(title: nil, message:"تم حفظ التغييرات بنجاح", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  "حسنًا", style: .default, handler: { (_) -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }))
                        present(alert, animated: true, completion: nil)
        
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
        */

    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
    }
    
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    
    //Avatar
    func setupAvatar(){
       
        avatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatar.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentPicker(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker , animated: true, completion: nil)
    }
    
    //dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Do any additional setup after loading the view.
    }





extension EditVIprofileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            image = imageSelected
            avatar.image = imageSelected
        }
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = imageOriginal
            avatar.image = imageOriginal
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
