import AWSDynamoDB
import AuthCore
import DynamoUtils
import Foundation

class DynamoSessionRepo: SessionRepo {

    private let client: DynamoDBClient
    private let tableName: String

    init(client: DynamoDBClient, tableName: String) {
        self.client = client
        self.tableName = tableName
    }

    func save(userId: String, sessionId: String, refreshTokenHash: String) async throws {
        // TODO: save ip, region and other related data, this can help to detect stolen refreshTokens
        let session = DynamoSession(
            userId: userId,
            id: sessionId,
            refreshTokenHash: refreshTokenHash,
            createdAt: Date(),
            lastAccessedAt: Date(),
            loggedOutAt: Date()
        )

        let input = PutItemInput(
            conditionExpression: "attribute_not_exists(id)",
            item: session.item(),
            tableName: self.tableName
        )
        let _ = try await client.putItem(input: input)
    }

    func update(
        userId: String,
        sessionId: String,
        newRefreshTokenHash: String,
        previousRefreshTokenHash: String
    ) async throws {

        do {

            let expression = "SET refreshTokenHash = :x, lastAccessedAt = :y"
            let expressionAttributeValues: [String: DynamoDBClientTypes.AttributeValue] = [
                ":x": toDynamoValue(newRefreshTokenHash),
                ":y": toDynamoValue(Date()),
                ":previousHash": toDynamoValue(previousRefreshTokenHash),
                ":nullVal": .null(true),
            ]

            let input = UpdateItemInput(
                conditionExpression:
                    "refreshTokenHash = :previousHash AND loggedOutAt = :nullVal",
                expressionAttributeValues: expressionAttributeValues,
                key: DynamoSessionKey(userId: userId, id: sessionId).item(),
                tableName: self.tableName,
                updateExpression: expression
            )

            let _ = try await client.updateItem(input: input)
        } catch _ as ConditionalCheckFailedException {
            throw SessionRepoError.tokenOutOfSync
        }

    }

    func invalidate(
        userId: String,
        sessionId: String,
        refreshTokenHash: String
    ) async throws {
        do {
            let expression = "SET loggedOutAt = :x"
            let expressionAttributeValues: [String: DynamoDBClientTypes.AttributeValue] = [
                ":previousHash": toDynamoValue(refreshTokenHash),
                ":x": toDynamoValue(Date()),
                ":nullVal": .null(true),
            ]

            let input = UpdateItemInput(
                conditionExpression:
                    "refreshTokenHash = :previousHash AND loggedOutAt = :nullVal",
                expressionAttributeValues: expressionAttributeValues,
                key: DynamoSessionKey(userId: userId, id: sessionId).item(),
                tableName: self.tableName,
                updateExpression: expression
            )

            let _ = try await client.updateItem(input: input)
        } catch _ as ConditionalCheckFailedException {
            throw SessionRepoError.tokenOutOfSync
        }
    }

}
