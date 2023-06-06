// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "PluginPackageCreator",

    platforms: [
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PluginPackageCreator",
            type: .dynamic,
            targets: ["PluginPackageCreator"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/swift-setup/PluginInterface", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/stencilproject/Stencil", .upToNextMajor(from: "0.0.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/swift-setup/SwiftUIJsonSchemaForm", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PluginPackageCreator",
            dependencies: [
                .product(name: "PluginInterface", package: "PluginInterface"),
                .product(name: "Stencil", package: "Stencil"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "SwiftUIJsonSchemaForm", package: "SwiftUIJsonSchemaForm"),
            ]
        ),
        .testTarget(
            name: "PluginPackageCreatorTests",
            dependencies: ["PluginPackageCreator"]
        ),
    ]
)
