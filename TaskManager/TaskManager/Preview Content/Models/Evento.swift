
//
//  Event.swift
//  TaskManager
//
//  Created by David Calduch on 22/4/25.
//

import Foundation
struct Evento: Codable{
    var id: Int?
    var user: UserReference
    var name: String
    var date: String      // formato: "yyyy-MM-dd"
    var time: String      // formato: "HH:mm"
    var description: String
    var color: Int
    
}
class EventService {
    let baseUrl = "http://localhost:8080/eventos"
    let username = "david"
    let password = "Pitita_44"
    
    func createEvent(event: Evento, completion: @escaping (Bool) -> Void) {
        let loginData = "\(username):\(password)".data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        guard let url = URL(string: baseUrl) else {
            print("❌ URL no válida")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(event)
            request.httpBody = jsonData
            print("📤 JSON enviado: \(String(data: jsonData, encoding: .utf8) ?? "Sin datos")")
        } catch {
            print("❌ Error al codificar JSON: \(error)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error en la petición: \(error)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Código de estado: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    completion(false)
                    return
                }
            }
            
            completion(true)
        }.resume()
    }
}
