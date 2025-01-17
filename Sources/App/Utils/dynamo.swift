import AWSDynamoDB

// TODO: move to shared repo
func hasConditionalCheckFailed(_ error: TransactionCanceledException) -> Bool {

  let conditionalCheckFailed = error.properties.cancellationReasons?.contains { reason in
    return reason.code?.contains("ConditionalCheckFailed") ?? false
  }

  return conditionalCheckFailed ?? false
}
