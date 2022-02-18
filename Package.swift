// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "TBAlertController",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "TBAlertController", targets: ["TBAlertController"])
    ],
    targets: [
        .target(
            name: "TBAlertController",
            path: "Classes"
        )
    ]
)
