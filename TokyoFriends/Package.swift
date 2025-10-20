// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TokyoFriends",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TokyoFriends",
            targets: ["TokyoFriends"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TokyoFriends",
            dependencies: [],
            path: "TokyoFriends",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        .testTarget(
            name: "TokyoFriendsTests",
            dependencies: ["TokyoFriends"],
            path: "Tests"
        )
    ]
)
