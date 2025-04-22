//
//  UserSession.swift
//  TaskManager
//
//  Created by David Calduch on 15/4/25.
//

import Foundation
class UserSession: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var userId: Int? = nil 
}
