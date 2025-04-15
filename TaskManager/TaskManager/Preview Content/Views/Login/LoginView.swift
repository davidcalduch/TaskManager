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
    @State private var isLogin = false
    @EnvironmentObject var userSession: UserSession
    
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
                NavigationLink(destination: MainTabView().navigationBarBackButtonHidden(true), isActive: $isLogin) {
                    EmptyView()
                }
                .hidden()
                
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
        guard let url = URL(string: "http://localhost:8080/users/login") else { return }
        
        let loginData = [
            "email": email,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginData) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("🔴 Error en la petición: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoginFailed = true
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No se pudo obtener una respuesta HTTP válida.")
                DispatchQueue.main.async {
                    isLoginFailed = true
                }
                return
            }

            print("📡 Status code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("❌ No se recibieron datos del servidor.")
                DispatchQueue.main.async {
                    isLoginFailed = true
                }
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Respuesta del servidor: \(responseString)")
            }

            if httpResponse.statusCode == 200 {
                if let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                    DispatchQueue.main.async {
                        userSession.name = userResponse.name
                        userSession.email = userResponse.email
                        userSession.password = userResponse.password
                        userSession.isLoggedIn = true
                        isLogin = true
                    }
                } else {
                    print("❌ No se pudo decodificar el usuario.")
                    DispatchQueue.main.async {
                        isLoginFailed = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    isLoginFailed = true
                }
            }
        }.resume()
    }
}
struct UserResponse: Codable {
    let name: String
    let email: String
    let password: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
