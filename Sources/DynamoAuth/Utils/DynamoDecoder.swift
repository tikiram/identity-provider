import AWSDynamoDB
import Foundation

public struct DynamoInverseMapper: InverseMapper {

  public init() {}

  public func mapMap(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws
    -> [String: AWSDynamoDB.DynamoDBClientTypes.AttributeValue]
  {
    guard case .m(let map) = input else {
      throw InverseMapperError.invalidType
    }

    return map
  }

  public func mapList(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws
    -> [AWSDynamoDB.DynamoDBClientTypes.AttributeValue]
  {
    guard case .l(let list) = input else {
      throw InverseMapperError.invalidType
    }

    return list
  }

  public func mapInt(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> Int {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = Int(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapInt8(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> Int8 {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = Int8(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapInt16(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> Int16 {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = Int16(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapInt32(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> Int32 {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = Int32(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapInt64(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> Int64 {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = Int64(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapUInt(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> UInt {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = UInt(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapUInt8(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> UInt8 {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = UInt8(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapUInt16(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> UInt16 {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = UInt16(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapUInt32(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> UInt32 {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = UInt32(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapUInt64(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> UInt64 {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = UInt64(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapString(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> String {
    guard case .s(let text) = input else {
      throw InverseMapperError.invalidType
    }
    return text
  }

  public func mapBool(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> Bool {
    guard case .bool(let value) = input else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapDouble(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> Double {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = Double(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapFloat(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> Float {
    guard case .n(let text) = input else {
      throw InverseMapperError.invalidType
    }
    guard let value = Float(text) else {
      throw InverseMapperError.invalidType
    }
    return value
  }

  public func mapDate(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) throws -> Date {
    guard case .s(let text) = input else {
      throw InverseMapperError.invalidType
    }

    let newFormatter = ISO8601DateFormatter()
    let date = newFormatter.date(from: text)

    guard let date = date else {
      throw InverseMapperError.invalidType
    }
    return date
  }

  public func isNil(_ input: AWSDynamoDB.DynamoDBClientTypes.AttributeValue) -> Bool {
    if case .null(let value) = input {
      return value
    }

    return false
  }
}
