import Vapor

class AuthResponseManager {

  private let response: Response

  init(_ response: Response) {
    self.response = response
  }

  func setRefreshTokenCookie(_ refreshToken: String, expirationTime: TimeInterval) {

    let cookie = createRefreshTokenCookie(
      value: refreshToken, expirationTime: expirationTime)

    // TODO: this is the only required line but currently vapor still has no support for Partitioned attribute
    //response.cookies["refreshToken"] = cookie
    
    let cookieValue = cookie.serialize(name: "refreshToken")

    response.headers.add(
      name: .setCookie,
      value: "\(cookieValue); Partitioned"
    )

    
  }

  private func createRefreshTokenCookie(value: String, expirationTime: TimeInterval)
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
