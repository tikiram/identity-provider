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

func hasConditionalCheckFailed(_ error: TransactionCanceledException) -> Bool {

  let conditionalCheckFailed = error.properties.cancellationReasons?.contains { reason in
    return reason.code?.contains("ConditionalCheckFailed") ?? false
  }

  return conditionalCheckFailed ?? false
}
