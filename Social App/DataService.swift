//
//  DataService.swift
//  Social App
//
//  Created by Timm Liberty on 12/7/16.
//  Copyright © 2016 Briantiumapps. All rights reserved.
//

import Foundation
import Firebase

// contains the root location of the database

let DB_BASE = FIRDatabase.database().reference()

// contains the root location of the storage
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    // DB references
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("Posts")
    private var _REF_USERS = DB_BASE.child("Users")
    
    // Storage references
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMAGES
    }
    
    // use this function to create and write to a user
    func createFirebaseDBUser(uid: String, userData:Dictionary<String, String>){
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}
