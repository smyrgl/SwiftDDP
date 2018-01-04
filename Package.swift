// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SwiftDDP",
    products: [
        .library(name: "SwiftDDP", targets: ["SwiftDDP"])
    ],
    dependencies: [
      .package(url: "https://github.com/daltoniam/Starscream.git", from: "3.0.3"),
      .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.8.0"),
      .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.5.0"),

    ],
    targets:[
        .target(name: "SwiftDDP", dependencies: ["Starscream", "CryptoSwift", "SwiftyBeaver"], path: "SwiftDDP"),
    ]
)
