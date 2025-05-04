public protocol PoolRepo {

  func getAll() async throws -> [Pool]

}
