
import Vapor

func getIndicatorCookie(_ cookie: HTTPCookies.Value) -> HTTPCookies.Value {
  // Just a cookie that can be read from JS
  let indicatorCookie = HTTPCookies.Value(
    string: "true",
    expires: cookie.expires,
//    isSecure: cookie.isSecure,
    isSecure: false,
    isHTTPOnly: false,
    sameSite: cookie.sameSite
  )
  return indicatorCookie
}
