// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "identity-provider",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.105.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.11.0"),
        // 🐘 Fluent driver for Postgres.
        .package(
            url: "https://github.com/vapor/fluent-postgres-driver.git",
            from: "2.9.2"
        ),
        // JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.1"),
        // AWS
        .package(
            url: "https://github.com/awslabs/aws-sdk-swift",
            from: "1.0.69"
        )
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(
                    name: "FluentPostgresDriver",
                    package: "fluent-postgres-driver"
                ),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "AWSDynamoDB", package: "aws-sdk-swift"),
                "Sendgrid",
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
          name: "Sendgrid",
          dependencies: [
            .product(name: "Vapor", package: "vapor"),
          ]
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
