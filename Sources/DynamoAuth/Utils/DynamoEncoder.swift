import AWSDynamoDB
import Foundation

enum DynamoEncoderError: Error {
  case resultIsNotMap
}

func toDynamoItem(_ payload: Encodable) throws -> [String: DynamoDBClientTypes.AttributeValue] {
  let simpleEncoder = SimpleEncoder(codingPath: [], userInfo: [:])
  try payload.encode(to: simpleEncoder)
  let result = try simpleEncoder.valueIntention.result(DynamoMapper())

  guard case .m(let map) = result else {
    throw DynamoEncoderError.resultIsNotMap
  }
  return map
}

struct DynamoMapper: ValueMapper {
  func map(_ value: Date) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .s(value.ISO8601Format())
  }

  func map(_ value: Int) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: Int8) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: Int16) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: Int32) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: Int64) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: UInt) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: UInt8) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: UInt16) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: UInt32) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: UInt64) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: String) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .s(value)
  }

  func map(_ value: Bool) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .bool(value)
  }

  func map(_ value: Double) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: Float) -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .n(value.description)
  }

  func map(_ value: [AWSDynamoDB.DynamoDBClientTypes.AttributeValue])
    -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue
  {
    return .l(value)
  }

  func map(_ value: [String: AWSDynamoDB.DynamoDBClientTypes.AttributeValue])
    -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue
  {
    return .m(value)
  }

  func mapNil() -> AWSDynamoDB.DynamoDBClientTypes.AttributeValue {
    return .null(true)
  }
}
