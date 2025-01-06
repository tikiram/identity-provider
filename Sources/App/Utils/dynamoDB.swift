import AWSDynamoDB

func getStringFromAttribute(_ attribute: DynamoDBClientTypes.AttributeValue?) throws -> String {
  guard let attribute else {
    throw RuntimeError("attribute is null")
  }
  guard case .s(let value) = attribute else {
    throw RuntimeError("invalid attribute")
  }
  return value
}

