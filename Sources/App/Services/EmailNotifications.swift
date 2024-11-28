class EmailNotifications {

  private let emailService: EmailService

  init(emailService: EmailService) {
    self.emailService = emailService
  }

  func sendRecoveryCode(to email: String, code: String) async throws {

    // TODO: move this to a configuration and get values from constructor

    let payload = EmailPayload(
      from: "no-reply@equanimousoft.com",
      to: [email],
      subject: "Reset Password",
      content: "This is the code \(code)"
    )

    try await self.emailService.send(payload)
  }

}
