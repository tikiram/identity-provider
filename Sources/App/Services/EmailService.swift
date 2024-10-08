
import Vapor
import Sendgrid

class EmailService {
  
  private let sendgrid: Sendgrid
  
  init(sendgrid: Sendgrid) {
    self.sendgrid = sendgrid
  }
  
  func send(_ payload: EmailPayload) async throws {
        
    let fromPayload = FromPayload(email: payload.from)
    
    let toPayloads = payload.to.map(ToPayload.init)
    let personalization = Personalization(to: toPayloads)
    
    // TODO: format this to html
    let content = EmailContent(type: "text/plain", value: payload.content)
    
    let payload = SendgridPayload(
      personalizations: [personalization],
      from: fromPayload,
      subject: payload.subject,
      content: [content]
    )
    
    try await sendgrid.sendEmail(payload)
  }
  
}

struct EmailPayload {
  let from: String
  let to: [String]
  let subject: String
  let content: String
}
