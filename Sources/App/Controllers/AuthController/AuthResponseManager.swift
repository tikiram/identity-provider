import Vapor

class AuthResponseManager {

  private let response: Response

  init(_ response: Response) {
    self.response = response
  }

  func setRefreshTokenCookie(_ refreshToken: String, expirationTime: TimeInterval) {

    let cookie = getRefreshTokenCookie(
      value: refreshToken, expirationTime: expirationTime)

    response.cookies["refreshToken"] = cookie
  }

  private func getRefreshTokenCookie(value: String, expirationTime: TimeInterval)
    -> HTTPCookies.Value
  {
    let cookie = HTTPCookies.Value(
      string: value,
      expires: Date().addingTimeInterval(expirationTime),
      isSecure: true,
      isHTTPOnly: true,
      sameSite: HTTPCookies.SameSitePolicy.none
    )
    return cookie
  }
}
