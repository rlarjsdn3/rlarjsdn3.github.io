---
date: '2025-11-05T13:34:02+09:00'
draft: false
title: '[번역] Swift Concurrency / Enable Data Race Safety Checking (Migrating to Swift 6)'
description: "Swift 6로 전체 데이터 경합 안정성 검사를 수행하거나, 기존 Swift 5 프로젝트에 엄격한 동시성 검사를 활성화하세요."
tags: ["Package Manager", "CLI", "Xcode"]
categories: ["Swift Concurrency"]
cover:
    image: images/code.jpg
    caption: ""
---

 Swift 프로젝트에서 데이터 경합 안전성 검사를 활성화하려면 Swift 6 언어 모드를 사용하세요. Swift 6에서는 기본적으로 전체 데이터 경합 안전성 검사를 수행합니다.

## Enable the Swift 6 language mode

### Swift 6 mode with Swift packages

swift-tools-version을 6.0으로 사용하는 _Package.swift_ 파일은 모든 타깃에 대해 Swift 6 언어 모드를 사용합니다. 패키지 전체에 대해서는 `Package`의 `swiftLanguageModes` 속성을 사용해 언어 모드를 설정할 수도 있습니다. 또한 새로운 `swiftLanguageMode` 빌드 설정을 사용하여 필요에 따라 타깃 별로 언어 모드를 달리할 수도 있습니다.

```swift
// swift-tools-version: 6.0

let package = Package(
    name: "MyPackage",
    products: [
        // ...
    ],
    targets: [
        // Uses the default tools language mode (6)
        .target(
            name: "FullyMigrated",
        ),
        // Still requires 5
        .target(
            name: "NotQuiteReadyYet",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
```

패키지가 이전 Swift 툴체인(toolchain) 버전을 계속 지원해야 하면서 `swiftLanguageMode`를 사용하려는 경우, 6 이전 툴체인을 위한 버전별 매니페스트를 만들어야 합니다. 예를 들어, 5.9 이상의 툴체인을 계속 지원하려 _Package@swift-5.9.swif_라는 매니페스트 파일을 만들어야 합니다.

```swift
// swift-tools-version: 5.9

let package = Package(
    name: "MyPackage",
    products: [
        // ...
    ],
    targets: [
        .target(
            name: "FullyMigrated",
        ),
        .target(
            name: "NotQuiteReadyYet",
        )
    ]
)
```

그리고 Swift 6.0 이상의 툴체인을 위한 또 다른 _Package.swift_ 파일을 둘 수 있습니다.

```swift
// swift-tools-version: 6.0

let package = Package(
    name: "MyPackage",
    products: [
        // ...
    ],
    targets: [
        // Uses the default tools language mode (6)
        .target(
            name: "FullyMigrated",
        ),
        // Still requires 5
        .target(
            name: "NotQuiteReadyYet",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
```

반대로, Swift 6 언어 모드를 사용할 수 있을 때만 적용하고(이전 모드도 계속 지원하면서) 싶다면, 하나의 _Package.swift_만 유지하면서 호환 가능한 방식으로 버전을 지정할 수 있습니다.

```swift
// swift-tools-version: 5.9

let package = Package(
    name: "MyPackage",
    products: [
        // ...
    ],
    targets: [
        .target(
            name: "FullyMigrated",
        ),
    ],
    // `swiftLanguageVersions` and `.version("6")` to support pre 6.0 swift-tools-version.
    swiftLanguageVersions: [.version("6"), .v5]
)
```


### Swift 6 mode with command-lilne invocations

_-swift-version 6_은 Swift 패키지 매니저 명령줄 실행 시 -Xswiftc 플래그를 사용하여 전달할 수 있습니다.

```
~ swift build -Xswiftc -swift-version -Xswiftc 6
~ swift test -Xswiftc -swift-version -Xswiftc 6
```

명령줄에서 swift 또는 swiftc를 직접 실행할 때 Swift 6 언어 모드를 활성화하려면 _-swift-version 6_를 전달하세요.

```
~ swift -swift-version 6 main.swift
```


## Swift 6 mode with Xcode

Xcode 프로젝트나 타깃의 언어 모드는 빌드 설정에서 "Swift Langugage Version" 값을 **6**으로 설정하여 제어할 수 있습니다.


### Setting XCConfig

또한 xcconfig 파일에서 SWIFT_VERSION 값을 6으로 지정할 수도 있습니다.

```
// In a Settings.xcconfig

SWIFT_VERSION = 6;
```


## Enable data-race safety checking as warnings

Swift 5 언어 모드 또는 그 이전 버전의 타깃이나 패키지에서는 프로젝트의 데이터 경합 안전성 문제를 모둘 단위로 해결할 수 있습니다. Swift 6 언어 모드를 켜기 전에, 컴파일러의 액터 격리(actor isolation)와 Sendable 검사를 경고(warning)로 활성화하여 데이터 경합 제거 상황을 점검하세요.

_-strict-concurrency_ 컴파일러 플래그를 사용하면 전체 데이터 경합 안전성 검사를 경고로 활성화할 수 있습니다.


### Checking with Swift packages

Swift 5.9 또는 Swift 5.10 툴을 사용하는 Swift 패키지에서 특정 타깃에 대해 완전한 동시성 검사를 활성화하려면, 해당 타깃의 Swift 설정에서 _SwiftSetting.enableExperimentalFeature_를 사용하세요.

```swift
.target(
  name: "MyTarget",
  swiftSettings: [
    .enableExperimentalFeature("StrictConcurrency")
  ]
)
```

Swift 6.0 툴 이상을 사용할 때, Swift 6 이전 언어 모드 타깃에서는 Swift 설정에서 _SwiftSetting.enableUpcomingFeature_를 사용하세요.

```swift
.target(
  name: "MyTarget",
  swiftSettings: [
    .enableUpcomingFeature("StrictConcurrency")
  ]
)
```

Swift 6 언어 모드를 사용하는 타깃은 기본적으로 전체 검사가 무조건 활성화되며, 별도의 설정 변경이 필요하지 않습니다.


### Checking with command-line invocations

명령줄에서 swift 또는 swiftc를 직접 실행할 때 전체 동시성 검사를 활성화하려면 _-strict-concurrency=complete_를 전달하세요.

```
~ swift -strict-concurrency=complete main.swift
```

_-strict-concurrency=complete_는 Swift 패키지 매니저 명령줄 실행 시 -Xswiftc 플래그를 사용하여 전달할 수 있습니다.

```
~ swift build -Xswiftc -strict-concurrency=complete
~ swift test -Xswiftc -strict-concurrency=complete
```

이는 패키지 매니페스트에 해당 플래그를 영구적으로 추가하기 전에, 동시성과 관련된 경고가 얼마나 발생하는지 가늠하는 데 유용합니다.


### Checking with Xcode

Xcode 프로젝트에서 전체 동시성 검사를 활성화하려면, Xcode 빌드 설정의 “Strict Concurrency Checking” 항목을 **Complete**로 설정하세요.


#### Setting XCConfig

또는 xcconfig 파일에서 SWIFT_STRICT_CONCURRENCY 값을 complete로 설정할 수도 있습니다.

```
// In a Settings.xcconfig

SWIFT_STRICT_CONCURRENCY = complete;
```
