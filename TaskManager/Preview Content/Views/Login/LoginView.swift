//
//  LoginView.swift
//  TaskManager
//
//  Created by David Calduch on 2/1/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoginFailed: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                TextField("Enter your email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)

                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)

                if isLoginFailed {
                    Text("Invalid email or password")
                        .foregroundColor(.red)
                        .padding(.bottom, 20)
                }

                Button(action: {
                    login()
                }) {
                    Text("Log In")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)

                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Sign up")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
        }
    }

    private func login() {
        if email == "test@example.com" && password == "password123" {
            isLoginFailed = false
        } else {
            isLoginFailed = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
