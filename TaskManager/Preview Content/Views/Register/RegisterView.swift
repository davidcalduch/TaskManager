//
//  RegisterView.swift
//  TaskManager
//
//  Created by David Calduch on 2/1/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var userName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var avatarImage: Image? = Image(systemName: "person.crop.circle.fill")

    var body: some View {
        NavigationView {
            VStack {
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                avatarImage?
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .shadow(radius: 5)
                    .padding()

                Button(action: {
                }) {
                    Text("Change Avatar")
                        .foregroundColor(.blue)
                }

                TextField("Enter your name", text: $userName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 10)

                TextField("Enter your email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)

                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 10)

                SecureField("Confirm your password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)

                Button(action: {
                    register()
                }) {
                    Text("Register")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)

                NavigationLink(destination: LoginView()) {
                    Text("Already have an account? Log in")
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding()
        }
    }

    private func register() {
        if password == confirmPassword {
            print("Account created for \(userName) with email \(email)")
        } else {
            print("Passwords do not match")
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
