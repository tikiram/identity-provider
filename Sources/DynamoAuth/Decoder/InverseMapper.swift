import Foundation

public enum InverseMapperError: Error {
  case invalidType
}

public protocol InverseMapper<V> {
  associatedtype V

  func mapMap(_ input: V) throws -> [String: V]
  func mapList(_ input: V) throws -> [V]
  func mapInt(_ input: V) throws -> Int
  func mapInt8(_ input: V) throws -> Int8
  func mapInt16(_ input: V) throws -> Int16
  func mapInt32(_ input: V) throws -> Int32
  func mapInt64(_ input: V) throws -> Int64
  func mapUInt(_ input: V) throws -> UInt
  func mapUInt8(_ input: V) throws -> UInt8
  func mapUInt16(_ input: V) throws -> UInt16
  func mapUInt32(_ input: V) throws -> UInt32
  func mapUInt64(_ input: V) throws -> UInt64
  func mapString(_ input: V) throws -> String
  func mapBool(_ input: V) throws -> Bool
  func mapDouble(_ input: V) throws -> Double
  func mapFloat(_ input: V) throws -> Float
  func mapDate(_ input: V) throws -> Date

  func isNil(_ input: V) -> Bool
}
