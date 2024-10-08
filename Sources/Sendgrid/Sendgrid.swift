
import Vapor

public class Sendgrid {
  
  private let client: Client
  private let token: String
  
  public init(client: Client, token: String) {
    self.client = client
    self.token = token
  }
  
  public func sendEmail(_ payload: SendgridPayload) async throws {
    let response = try await client.post("https://api.sendgrid.com/v3/mail/send") { req in
      
      let authorization = BearerAuthorization(token: token)
      req.headers.bearerAuthorization = authorization
      
      
      try req.content.encode(payload)
    }
    
    guard response.status == .ok else {

      print(response.status)
      print(response.description)
      
      throw MailError.badResponse(response.description)
    }
    
  }
}

public enum MailError: Error {
  case badResponse(String)
}

public struct SendgridPayload: Content {
  let personalizations: [Personalization]
  let from: FromPayload
  let subject: String
  let content: [EmailContent]
  
  public init(personalizations: [Personalization], from: FromPayload, subject: String, content: [EmailContent]) {
    self.personalizations = personalizations
    self.from = from
    self.subject = subject
    self.content = content
  }
}

public struct FromPayload: Content {
  let email: String
  public init(email: String) {
    self.email = email
  }
}

public struct ToPayload: Content {
  let email: String
  public init(email: String) {
    self.email = email
  }
}

public struct Personalization: Content {
  let to: [ToPayload]
  public init(to: [ToPayload]) {
    self.to = to
  }
}

public struct EmailContent: Content {
  let type: String
  let value: String
  public init(type: String, value: String) {
    self.type = type
    self.value = value
  }
}
