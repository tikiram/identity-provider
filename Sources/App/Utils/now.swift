import Foundation

func nowMS() -> Int {
  return Int(Date().timeIntervalSince1970 * 1000)
}
