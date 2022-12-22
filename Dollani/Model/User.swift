//
//  User.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 28/05/1444 AH.
//

import Foundation
struct User:Identifiable{
    
    var id:String = UUID().uuidString
    var name:String
    var email:String
    var phoneNum:String
    var category:String
    var CGEmail:String?
    
}
