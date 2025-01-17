import CryptoKit
import Foundation

func generateSHA256(from input: String) -> String {
    // Convierte la cadena de entrada a datos
    let inputData = Data(input.utf8)
    
    // Genera el hash SHA-256
    let hashed = SHA256.hash(data: inputData)
    
    // Convierte el hash en una representación hexadecimal
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
}
