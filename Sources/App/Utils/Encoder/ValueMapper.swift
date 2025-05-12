protocol ValueMapper<R> {
  associatedtype R

  func map(_ value: Int) -> R
  func map(_ value: Int8) -> R
  func map(_ value: Int16) -> R
  func map(_ value: Int32) -> R
  func map(_ value: Int64) -> R
  func map(_ value: UInt) -> R
  func map(_ value: UInt8) -> R
  func map(_ value: UInt16) -> R
  func map(_ value: UInt32) -> R
  func map(_ value: UInt64) -> R
  func map(_ value: String) -> R
  func map(_ value: Bool) -> R
  func map(_ value: Double) -> R
  func map(_ value: Float) -> R
  func map(_ value: [R]) -> R
  func map(_ value: [String: R]) -> R
  func mapNil() -> R

}
