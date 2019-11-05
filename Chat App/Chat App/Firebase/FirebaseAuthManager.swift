//
//  FirebaseAuthManager.swift
//  Chat App
//
//  Created by Kevin Li on 10/21/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import FirebaseAuth
import UIKit

class FirebaseAuthManager {
    
    func createUser(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if authResult?.user != nil {
                completionBlock(true)
            } else {
                completionBlock(false)
            }
        }
    }
    
    func signIn(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (result, error) in
            if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
                completionBlock(false)
            } else {
                completionBlock(true)
            }
        })
    }
    
}
