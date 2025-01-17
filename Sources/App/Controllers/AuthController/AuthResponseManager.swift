import Vapor


let REFRESH_TOKEN_COOKIE_NAME = "x_rtkn"

class AuthResponseManager {

  private let response: Response

  init(_ response: Response) {
    self.response = response
  }

  func setRefreshTokenCookie(_ refreshToken: String, expirationTime: TimeInterval) {

    let cookie = createRefreshTokenCookie(
      value: refreshToken, expirationTime: expirationTime)

    // TODO: this is the only required line but currently vapor still has no support for Partitioned attribute
    //response.cookies[REFRESH_TOKEN_COOKIE_NAME] = cookie

    let cookieValue = cookie.serialize(name: REFRESH_TOKEN_COOKIE_NAME)

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
