import AWSDynamoDB

struct Perro: Decodable {
  let name: String
  let age: Int
}

public func hope() throws {
  let inverseMapper = DynamoInverseMapper()

  let map: [String: AWSDynamoDB.DynamoDBClientTypes.AttributeValue] = [
    "name": .s("Perron"),
    "age": .n("10"),
  ]
  let m: AWSDynamoDB.DynamoDBClientTypes.AttributeValue = .m(map)

  let s = SimpleDecoder(codingPath: [], userInfo: [:], value: m, inverseMapper: inverseMapper)

  let pr = try Perro(from: s)
  print("result")
  print(pr)

}
