import AuthCore

final class DevSimpleHasher: SimpleHasher {
  func hash(_ input: String) -> String {
    return input
  }
}
