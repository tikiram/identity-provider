public class PoolService {

  private let poolRepo: PoolRepo

  public init(_ poolRepo: PoolRepo) {
    self.poolRepo = poolRepo
  }

  public func getAll() async throws -> [Pool] {
    return try await self.poolRepo.getAll()
  }
}
