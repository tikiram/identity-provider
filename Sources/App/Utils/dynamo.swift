import AWSDynamoDB
import SharedBackend
import Foundation

// TODO: move to shared repo
func hasConditionalCheckFailed(_ error: TransactionCanceledException) -> Bool {

  let conditionalCheckFailed = error.properties.cancellationReasons?.contains { reason in
    return reason.code?.contains("ConditionalCheckFailed") ?? false
  }

  return conditionalCheckFailed ?? false
}


// TODO: move this to shared repo
public func getBooleanFromAttribute(_ attribute: DynamoDBClientTypes.AttributeValue?) throws -> Bool {
  guard let attribute else {
    throw RuntimeError("attribute is null")
  }
  guard case .bool(let value) = attribute else {
    throw RuntimeError("invalid attribute")
  }
  
  return value
}


public func getOptionalDoubleFromAttribute(_ attribute: DynamoDBClientTypes.AttributeValue?) throws -> Double? {
  guard let attribute else {
    return nil
  }
  guard case .n(let text) = attribute else {
    throw RuntimeError("invalid attribute")
  }

  guard let value = Double(text) else {
    throw RuntimeError("attribute is not a valid Double")
  }

  return value
}

public func getOptionalDateFromAttribute(_ attribute: DynamoDBClientTypes.AttributeValue?) throws -> Date? {
  // assumes the date is saved as ms
  let ms = try getOptionalDoubleFromAttribute(attribute)

  return  ms.map { Date(timeIntervalSince1970: TimeInterval($0 / 1000)) }
}
