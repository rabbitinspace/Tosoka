import PackageDescription

let package = Package(
    name: "Tosoka",
    dependencies: [
        .Package(url: "https://github.com/rabbitinspace/CCrypto", majorVersion: 0, minor: 1),
    ]
)

