import AuthCore
import Vapor

private let REFRESH_TOKEN_COOKIE_NAME = "x_rtkn"

extension Request {
  func getRefreshTokenFromCookie() throws -> String {
    guard let refreshTokenCookie = self.cookies[REFRESH_TOKEN_COOKIE_NAME] else {
      throw Abort(.badRequest, reason: "MISSING_REFRESH_TOKEN")
    }
    return refreshTokenCookie.string
  }
}

extension Response {

  func removeRefreshTokenCookie() {
    setRefreshTokenCookie(TokenInfo(value: "", expiresIn: 0))
  }

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

extension Response {

  func handlePayload(_ clientType: ClientType, tokens: Tokens) throws {
    switch clientType {
    case .web:
      let responseContent = LiteTokensResponse(
        accessToken: tokens.accessTokenInfo.value,
        expiresIn: tokens.accessTokenInfo.expiresIn,
        payload: nil
      )
      try self.content.encode(responseContent, as: .json)

    case .mobile, .service:
      let responseContent = TokensResponse(
        accessToken: tokens.accessTokenInfo.value,
        expiresIn: tokens.accessTokenInfo.expiresIn,
        refreshToken: tokens.refreshTokenInfo.value,
        refreshTokenExpiresIn: tokens.refreshTokenInfo.expiresIn,
        payload: nil
      )
      try self.content.encode(responseContent, as: .json)
      self.setRefreshTokenCookie(tokens.refreshTokenInfo)
    }
  }

  func handlePayload(_ clientType: ClientType, user: User, tokens: Tokens) throws {
    switch clientType {
    case .web:
      let responseContent = LiteTokensResponse(
        accessToken: tokens.accessTokenInfo.value,
        expiresIn: tokens.accessTokenInfo.expiresIn,
        payload: UserPayload(userId: user.id)
      )
      try self.content.encode(responseContent, as: .json)

    case .mobile, .service:
      let responseContent = TokensResponse(
        accessToken: tokens.accessTokenInfo.value,
        expiresIn: tokens.accessTokenInfo.expiresIn,
        refreshToken: tokens.refreshTokenInfo.value,
        refreshTokenExpiresIn: tokens.refreshTokenInfo.expiresIn,
        payload: UserPayload(userId: user.id)
      )
      try self.content.encode(responseContent, as: .json)
      self.setRefreshTokenCookie(tokens.refreshTokenInfo)
    }
  }

}

private struct UserPayload: Content {
  let userId: String
}

private struct LiteTokensResponse: Content {
  let accessToken: String
  let expiresIn: Double
  let payload: UserPayload?
}
private struct TokensResponse: Content {
  let accessToken: String
  let expiresIn: Double
  let refreshToken: String
  let refreshTokenExpiresIn: Double
  let payload: UserPayload?
}
