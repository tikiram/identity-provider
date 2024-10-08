
class EmailNotifications {
  
  private let emailService: EmailService
  
  init(emailService: EmailService) {
    self.emailService = emailService
  }
  
  func sendRecoveryCode(to email: String, code: Int) async throws {
    let payload = EmailPayload(
      from: "no-reply@equanimousoft.com",
      to: [email],
      subject: "Reset Password",
      content: "This is the code \(code)"
    )
    
    try await self.emailService.send(payload)
  }
  
}
