// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Peopl",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Peopl",
            path: "Sources"
        ),
    ]
)
