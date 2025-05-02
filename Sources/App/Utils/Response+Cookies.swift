import AuthCore
import Vapor

private let REFRESH_TOKEN_COOKIE_NAME = "x_rtkn"

extension Response {

  func setRefreshTokenCookie(_ tokenInfo: TokenInfo) {

    let cookie = createRefreshTokenCookie(
      value: tokenInfo.value,
      expirationTime: tokenInfo.expiresIn
    )

    // TODO: this is the only required line but currently vapor still has no support for Partitioned attribute
    //response.cookies[REFRESH_TOKEN_COOKIE_NAME] = cookie

    let cookieValue = cookie.serialize(name: REFRESH_TOKEN_COOKIE_NAME)

    self.headers.add(
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
