//
//  ContactViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 28/05/1444 AH.
//

import UIKit
import Firebase

class ContactViewController: UIViewController,ObservableObject {
    @IBOutlet weak var tableView: UITableView!
    
   @Published var users = [User]()
    private var db = Firestore.firestore()
    
    let user = Auth.auth().currentUser
    var CGEmailList = [String] ()
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate =  self
        tableView.dataSource = self
        
        
           }

       
        // Do any additional setup after loading the view.
    
    func fetchData() {
        let user = Auth.auth().currentUser
        let CGemail = [user?.email]
        
        db.collection("users").whereField("CGEmail", arrayContainsAny:  CGemail as [Any] ).addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                 
                self.users = documents.map { (queryDocumentSnapshot) -> User in
                    let data = queryDocumentSnapshot.data()
                    let name = data["name"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let phoneNum = data["phoneNum"] as? String ?? ""
                    let category = data["category"] as? String ?? ""
                  
                    
                    return User(name: name, email: email,phoneNum: phoneNum,category:category)
                }
            self.tableView.reloadData()
            }
        }
    
    @IBAction func AddVI(_ sender: Any) {
        // create the actual alert controller view that will be the pop-up
        let alertController = UIAlertController(title: "اضافة جهة اتصال جديدة", message: "", preferredStyle: .alert)
       
        
        alertController.addTextField { (textField) in
            // configure the properties of the text field
            textField.placeholder = "الايميل"
        }
        
        
        // add the buttons/actions to the view controller
        let cancelAction = UIAlertAction(title: "الغاء", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "اضافة", style: .default) { _ in
            let user = Auth.auth().currentUser
            
            let VIemail = alertController.textFields![0].text!
         
            // this code runs when the user hits the "save" button
            //Validation
            Firestore.firestore().collection("users").whereField("email",isEqualTo:VIemail).getDocuments { snapshot, error in
                if  (snapshot?.count == 0 ){
                    let innerAlert = UIAlertController(title: nil, message:"تأكد من ادخال ايميل صحيح", preferredStyle: .alert)
                    innerAlert.addAction(UIAlertAction(title:  "الغاء", style: .default, handler:nil))
                    self.present(innerAlert, animated: true, completion: nil)
                }
                else {
                    let CGEmailListBefore = snapshot!.documents.first!.get("CGEmail") as! [String] 
                    self.CGEmailList.append(contentsOf: CGEmailListBefore )
                        self.CGEmailList.append((user?.email!)!)
                    Firestore.firestore().collection("users").document(VIemail).setData(["CGEmail": self.CGEmailList], merge: true) { error in
                        if  error != nil {
                            print(error!.localizedDescription)
                        }
                        else{
                            self.tableView.reloadData()
                            let innerAlert = UIAlertController(title: nil, message:"تمت عملية الاضافة بنجاح", preferredStyle: .alert)
                            innerAlert.addAction(UIAlertAction(title:  "الغاء", style: .default, handler:nil))
                            self.present(innerAlert, animated: true, completion: nil)
                            
                          
                        }
                        
                        
                        self.CGEmailList = []
                        
                        
                    }
                }
            }
        }
            
            
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            
        
            
            present(alertController, animated: true, completion: nil)
            
            
            
        }
    
    @IBAction func backButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CGcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

extension ContactViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell tapped")
    }
}

extension ContactViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
       
        
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
}
