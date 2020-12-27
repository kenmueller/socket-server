// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "socket",
	platforms: [
		.macOS(.v10_15)
	],
	products: [
		.library(name: "Socket", targets: ["Socket"])
	],
	dependencies: [
		.package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
	],
	targets: [
		.target(
			name: "Socket",
			dependencies: [
				.product(name: "Vapor", package: "vapor")
			]
		)
	]
)
