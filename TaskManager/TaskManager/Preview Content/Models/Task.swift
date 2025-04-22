import Foundation

// Modelo de la tarea con dueDate como Double (timestamp en segundos)
struct Task1: Codable {
    var id: Int? 
    var title: String
    var description: String
    var dueDate: String  // Se mantiene como Double para enviar timestamp
    var priority: String?
    var completed: Bool
    var user: UserReference
}
struct UserReference: Codable {
    var id: Int
}


// Clase para manejar las peticiones al backend
import Foundation

class TaskService {
    let baseUrl = "http://localhost:8080/tasks"
    let username = "david"
    let password = "Pitita_44"
    
    func createTask(task: Task1, completion: @escaping (Bool) -> Void) {
        let loginData = "\(username):\(password)".data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        guard let url = URL(string: baseUrl) else {
            print("Error: URL no válida")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(task)
            request.httpBody = jsonData
            print("JSON Data: \(String(data: jsonData, encoding: .utf8) ?? "No data")")
        } catch {
            print("Error codificando JSON: \(error)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en la petición: \(error)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de estado HTTP: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                    print("Error: código de estado \(httpResponse.statusCode)")
                    completion(false)
                    return
                }
            }
            
            if let data = data {
                print("Respuesta del servidor: \(String(data: data, encoding: .utf8) ?? "No response")")
            }
            
            completion(true)
        }.resume()
    }
    
    func fetchTasks(completion: @escaping ([Task1]) -> Void ){
        
        guard let url = URL(string: baseUrl)else {
            print("🙅 Url no valida")
            completion([])
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = "\(username):\(password)".data(using: .utf8)!
            let base64LoginString = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en la peticion: \(error)")
                completion([])
                return
            }
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                        print("JSON recibido: \(jsonString)")
                    }
                do {
                    let tasks = try JSONDecoder().decode([Task1].self, from: data)
                                   DispatchQueue.main.async {
                                       completion(tasks)  
                    }
                } catch {
                    print("Error al decodificar JSON: \(error)")
                    completion([])
                }
            }
        }.resume()
    }
    
    
}




