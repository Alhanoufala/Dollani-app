//
//  CategoryPlacesViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 01/06/1444 AH.
//

import UIKit

class CategoryPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var arrCategory = ["مدرجات","قاعات دراسية "," مكاتب"," دورات مياه"]
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = arrCategory[indexPath.row]
        return cell
    }
 
    
    @IBAction func backButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
   

}
