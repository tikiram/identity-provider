import Sendgrid
import SharedBackend
import Vapor

struct SendGridConfiguration {
  let apiKey: String
}

struct SendGridConfigurationKey: StorageKey {
  typealias Value = SendGridConfiguration
}

extension Application {
  var sendGridConfiguration: SendGridConfiguration? {
    get {
      self.storage[SendGridConfigurationKey.self]
    }
    set {
      self.storage[SendGridConfigurationKey.self] = newValue
    }
  }
}

extension Request {
  var emailNotifications: EmailNotifications {
    get throws {
      guard let configuration = self.application.sendGridConfiguration else {
        throw RuntimeError("No SendGrid configuration found")
      }

      let sendgrid = Sendgrid(client: client, token: configuration.apiKey)
      let emailService = EmailService(sendgrid: sendgrid)
      return EmailNotifications(emailService: emailService)
    }
  }
}
