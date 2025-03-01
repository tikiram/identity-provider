// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "identity-provider",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
    // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
    // AWS
    .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "1.0.69"),
    // Shared
    .package(url: "https://github.com/tikiram/vapor-utils.git", from: "0.9.0"),
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "AWSDynamoDB", package: "aws-sdk-swift"),
        .product(name: "SharedBackend", package: "vapor-utils"),
        "Sendgrid",
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOPosix", package: "swift-nio"),
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
  ],
  swiftLanguageModes: [.v5]
)

var swiftSettings: [SwiftSetting] {
  [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
  ]
}
