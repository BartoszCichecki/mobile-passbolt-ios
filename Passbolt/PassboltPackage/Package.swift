// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "PassboltPackage",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "Accounts",
      targets: ["Accounts"]
    ),
    .library(
      name: "AccountSetup",
      targets: ["AccountSetup"]
    ),
    .library(
      name: "Commons",
      targets: ["Commons"]
    ),
    .library(
      name: "Crypto",
      targets: ["Crypto"]
    ),
    .library(
      name: "Diagnostics",
      targets: ["Diagnostics"]
    ),
    .library(
      name: "Features",
      targets: ["Features"]
    ),
    .library(
      name: "Networking",
      targets: ["Networking"]
    ),
    .library(
      name: "NetworkClient",
      targets: ["NetworkClient"]
    ),
    .library(
      name: "PassboltApp",
      targets: ["PassboltApp"]
    ),
    .library(
      name: "PassboltExtension",
      targets: ["PassboltExtension"]
    ),
    .library(
      name: "Resources",
      targets: ["Resources"]
    ),
    .library(
      name: "Safety",
      targets: ["Safety"]
    ),
    .library(
      name: "Settings",
      targets: ["Settings"]
    ),
    .library(
      name: "SignIn",
      targets: ["SignIn"]
    ),
    .library(
      name: "Storage",
      targets: ["Storage"]
    ),
    .library(
      name: "UICommons",
      targets: ["UICommons"]
    ),
    .library(
      name: "UIComponents",
      targets: ["UIComponents"]
    ),
    .library(
      name: "User",
      targets: ["User"]
    )
  ],
  dependencies: [
    .package(
      name: "Aegithalos",
      url: "https://github.com/miquido/aegithalos.git",
      .upToNextMajor(from: "2.0.0")
    )
  ],
  targets: [
    .target(
      name: "Accounts",
      dependencies: [
        "Commons",
        "Diagnostics",
        "Features",
        "Settings",
        "Storage"
      ]
    ),
    .target(
      name: "AccountSetup",
      dependencies: [
        "Accounts",
        "Commons",
        "Diagnostics",
        "Features",
        "NetworkClient",
        "Safety"
      ]
    ),
    .target(name: "Commons"),
    .target(
      name: "Crypto",
      dependencies: [
        "Commons"
      ] // TODO: Add opengpg as dependency
    ),
    .target(
      name: "Diagnostics",
      dependencies: [
        "Commons",
        "Storage"
      ] // TODO: Add opengpg as dependency
    ),
    .target(
      name: "Features",
      dependencies: [
        "Commons",
        "Crypto",
        "Networking",
        "Storage"
      ]
    ),
    .target(
      name: "Networking",
      dependencies: [
        "Commons"
      ]
    ),
    .target(
      name: "NetworkClient",
      dependencies: [
        "Accounts",
        "Commons",
        "Diagnostics",
        "Features",
        "Networking"
      ]
    ),
    .target(
      name: "PassboltApp",
      dependencies: [
        "Accounts",
        "AccountSetup",
        "Commons",
        "UICommons",
        "UIComponents",
        "Diagnostics",
        "Features",
        "SignIn",
        "Resources",
        "User"
      ]
    ),
    .testTarget(
      name: "PassboltAppTests",
      dependencies: [
        "PassboltApp"
      ]
    ),
    .target(
      name: "PassboltExtension",
      dependencies: [
        "Accounts",
        "Commons",
        "UICommons",
        "UIComponents",
        "Diagnostics",
        "Features",
        "SignIn",
        "Resources"
      ]
    ),
    .testTarget(
      name: "PassboltExtensionTests",
      dependencies: ["PassboltExtension"]
    ),
    .target(
      name: "Resources",
      dependencies: [
        "Accounts",
        "Commons",
        "Diagnostics",
        "Features",
        "NetworkClient",
        "Safety",
        "Settings",
        "Storage"
      ]
    ),
    .target(
      name: "Safety",
      dependencies: [
        "Accounts",
        "Commons",
        "Crypto",
        "Diagnostics",
        "Features",
        "Settings"
      ]
    ),
    .target(
      name: "Settings",
      dependencies: [
        "Commons",
        "Diagnostics",
        "Features",
        "Storage"
      ]
    ),
    .target(
      name: "SignIn",
      dependencies: [
        "Accounts",
        "Commons",
        "Diagnostics",
        "Features",
        "Safety",
        "NetworkClient"
      ]
    ),
    .target(
      name: "Storage",
      dependencies: [
        "Commons"
      ] // TODO: Add database as dependency
    ),
    .target(
      name: "UICommons",
      dependencies: [
        "Commons",
        .product(name: "AegithalosCocoa", package: "Aegithalos")
      ]
    ),
    .target(
      name: "UIComponents",
      dependencies: [
        "Commons",
        "Features",
        "UICommons",
        .product(name: "AegithalosCocoa", package: "Aegithalos")
      ]
    ),
    .testTarget(
      name: "UIComponentsTests",
      dependencies: [
        "UIComponents"
      ]
    ),
    .target(
      name: "User",
      dependencies: [
        "Accounts",
        "Commons",
        "Diagnostics",
        "Features",
        "NetworkClient",
        "Safety",
        "Settings",
        "Storage"
      ]
    )
  ]
)