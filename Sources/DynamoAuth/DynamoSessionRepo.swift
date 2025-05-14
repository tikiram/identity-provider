import AWSDynamoDB
import AuthCore
import DynamoUtils
import Foundation

public class DynamoSessionRepo: SessionRepo {

    private let client: DynamoDBClient
    private let tableName: String

    public init(_ client: DynamoDBClient, _ tableName: String) {
        self.client = client
        self.tableName = tableName
    }

    public func save(userId: String, sessionId: String, refreshTokenHash: String) async throws {
        // TODO: save ip, region and other related data, this can help to detect stolen refreshTokens
        let session = DynamoSession(
            userId: userId,
            id: sessionId,
            refreshTokenHash: refreshTokenHash,
            createdAt: Date(),
            lastAccessedAt: Date(),
            loggedOutAt: nil
        )

        let input = PutItemInput(
            conditionExpression: "attribute_not_exists(id)",
            item: try toDynamoItem(session),
            tableName: self.tableName
        )
        let _ = try await client.putItem(input: input)
    }

    public func update(
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
            ]

            let input = UpdateItemInput(
                conditionExpression:
                    "refreshTokenHash = :previousHash AND attribute_not_exists(loggedOutAt)",
                expressionAttributeValues: expressionAttributeValues,
                key: try toDynamoItem(DynamoSessionKey(userId: userId, id: sessionId)),
                tableName: self.tableName,
                updateExpression: expression
            )

            let _ = try await client.updateItem(input: input)
        } catch _ as ConditionalCheckFailedException {
            throw SessionRepoError.tokenOutOfSync
        }

    }

    public func invalidate(
        userId: String,
        sessionId: String,
        refreshTokenHash: String
    ) async throws {
        do {
            let expression = "SET loggedOutAt = :x"
            let expressionAttributeValues: [String: DynamoDBClientTypes.AttributeValue] = [
                ":previousHash": toDynamoValue(refreshTokenHash),
                ":x": toDynamoValue(Date()),
            ]

            let input = UpdateItemInput(
                conditionExpression:
                    "refreshTokenHash = :previousHash AND attribute_not_exists(loggedOutAt)",
                expressionAttributeValues: expressionAttributeValues,
                key: try toDynamoItem(DynamoSessionKey(userId: userId, id: sessionId)),
                tableName: self.tableName,
                updateExpression: expression
            )

            let _ = try await client.updateItem(input: input)
        } catch _ as ConditionalCheckFailedException {
            throw SessionRepoError.tokenOutOfSync
        }
    }

}
