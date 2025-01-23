// swift-tools-version:5.10
import PackageDescription

let package = Package(
  name: "identity-provider",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.105.0"),
    // JWT
    .package(url: "https://github.com/vapor/jwt.git", from: "4.2.1"),
    // AWS
    .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "1.0.69"),
    // Shared
    .package(url: "https://github.com/tikiram/vapor-utils.git", from: "0.3.0"),
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "JWT", package: "jwt"),
        .product(name: "AWSDynamoDB", package: "aws-sdk-swift"),
        .product(name: "SharedBackend", package: "vapor-utils"),
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
        .product(name: "Vapor", package: "vapor")
      ]
    ),
  ]
)

var swiftSettings: [SwiftSetting] {
  [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
  ]
}
