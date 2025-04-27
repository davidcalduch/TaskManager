//
//  LoginView.swift
//  TaskManager
//
//  Created by David Calduch on 2/1/25.
//

import SwiftUI
import AuthenticationServices

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
                
                // Apple SignIn Button
                SignInWithAppleButton(.signIn, onRequest: { request in
                    // Configurar lo que pedimos a Apple
                    let nonce = randomNonceString()
                    request.nonce = nonce
                    request.requestedScopes = [.fullName, .email]
                }, onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        // Manejo del resultado exitoso
                        guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential else { return }
                        
                        // Obtener el token de Apple para verificar
                        let userToken = credential.identityToken
                        let userIdentifier = credential.user
                        
                        // Guardar esta información en el session
                        // Aquí puedes hacer una petición HTTP para validar el login con Apple
                        
                        // Para efectos de este ejemplo, solo estamos estableciendo en el UserSession
                        userSession.userId = userIdentifier.hashValue // Identificador único de Apple
                        userSession.isLoggedIn = true
                        isLogin = true
                        
                    case .failure(let error):
                        // Si hay un error, lo imprimimos
                        print("Error: \(error.localizedDescription)")
                    }
                })
                .signInWithAppleButtonStyle(.black)
                .frame(height: 44)
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
                        userSession.userId = userResponse.id
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
    let id: Int
    let name: String
    let email: String
    let password: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

// Método auxiliar para generación de nonce seguro para Sign In with Apple
func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    while remainingLength > 0 {
        let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0..<255) }
        randoms.forEach {
            if remainingLength == 0 { return }
            if $0 < charset.count {
                result.append(charset[Int($0)])
                remainingLength -= 1
            }
        }
    }
    return result
}
