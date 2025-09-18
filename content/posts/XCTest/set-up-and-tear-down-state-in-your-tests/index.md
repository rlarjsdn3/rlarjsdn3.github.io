---
date: '2024-12-12T23:17:04+09:00'
draft: true
title: '[번역] XCTest / Set Up and Tear Down State in Your Tests (애플 공식 문서)'
description: "테스트를 실행하기 전에 초기 상태를 준비하고, 테스트를 완료하면 자원을 해제하세요."
tags: ["XCTest", "XCTestCase"]
categories: ["XCTest"]
cover:
    image: images/docs*1.jpg
---


## Overview

코드가 올바른 결과를 지속적이고 올바르게 도출하도록 검증하려면 테스트는 잘 알려지고 예측 가능한 상태에서 시작해야 할 필요가 있습니다. 일부 경우에는 테스트 클래스에서 모든 테스트 메서드에 대해 한번 상태를 설정해야 할 수 있습니다. 다른 경우에는 각 테스트 메서드를 실행하기 전에 알려진 상태로 재설정해야 할 수 있습니다. 

각 테스트 메서드나 테스트 클래스가 완료되면 임시 파일이나 스크린샷과 같이 필요로 하지 않는 파일을 삭제해야 할 수 있습니다. 또는, 실패 진단을 돕기 위해 테스트 후 최종 상태를 기록(capture)해야 할 수 있습니다.

[XCTest](https://developer.apple.com/documentation/xctest/xctest)와 [XCTestCase](https://developer.apple.com/documentation/xctest/xctestcase)의 메서드를 사용하여 테스트를 위한 상태를 준비하거나, 테스트 후 필요 없는 임시 파일을 삭제하도록 하세요.

## Decide When to Set up and Tear Down State in Your Test Class

테스트 케이스를 실행하면 XCTest는 먼저 XCTestCase *setUp()* 클래스 메서드를 호출합니다. 이 메서드는 테스트 클래스의 모든 테스트 메서드에 공통적으로 적용될 상태를 설정하는 데 사용하세요.

XCTest는 아래 순서로 설정(setUp)과 해제(teardown) 메서드를 호출하며 각 테스트 메서드를 실행합니다.

1. XCTest는 각 테스트 메서드를 실행하기 전에 설정 메서드를 실행합니다. 먼저 *setUp() async throws* 메서드, 그 다음 *setupWithError()* 메서드, 마지막으로 *setUp()* 메서드를 실행합니다. 이 메서드들은 각 테스트 메서드에 필요한 상태를 설정하는 데 사용됩니다.

2. XCTest는 테스트 메서드를 실행합니다.

3. XCTest는 테스트 메서드에 추가한 해제 블록을 후입선출 순으로 실행합니다. 이 블록들은 특정 테스트 메서드를 실행한 후 상태를 해제하고 자원을 정리하는 데 사용됩니다. 

4. XCTest는 각 테스트 메서드를 실행한 후 해제 메서드를 실행합니다. 먼저 *tearDown()* 메서드, 그 다음 *tearDownWithError()* 메서드, 마지막으로 *tearDown() async throws* 메서드를 실행합니다. 이 메서드들은 각 테스트 메서드를 실행한 후 상태를 해제하는 데 사용됩니다.

XCTest가 모든 테스트 메서드를 실행하고 테스트 클래스가 종료되면 XCTest는 XCTest *tearDown()* 클래스 메서드를 호출합니다. 이 메서드는 테스트 클래스의 모든 테스트 메서드에 공통적인 상태를 해제하는 데 사용하세요.

> **Tip**:
> 테스트 클래스의 *setUp() async throws*, *setUpWithError()*, *setUp()*, *tearDown()*, *tearDownWithError()*와 *tearDown() async throws* 인스턴스 메서드에 테스트 검증을 포함할 수 있습니다. XCTest는 매 테스트 메서드 실행의 일부로 해당 검증을 평가합니다. 그러나, *setUp()*과 *tearDown()* 클래스 메서드에는 이러한 검증을 포함할 수 없습니다. 테스트 검증은 테스트 클래스 인스턴스를 필요로 하며, 클래스 메서드의 범위 내에 해당 인스턴스가 존재하지 않습니다. 

## Prepare and Tear Down State for a Test Class

테스트 클래스의 모든 테스트 메서드가 공통적이고, 각 테스트 메서드마다 상태를 재설정해줄 필요가 없다면, [XCTestCase](https://developer.apple.com/documentation/xctest/xctestcase)의 [setUp()](https://developer.apple.com/documentation/xctest/xctestcase/1496262-setup) 클래스 메서드를 사용하세요.

```swift
override class func setUp() {
	// This is the tearDown() class method.
    // XCTest calls it abefore calling the first test method.
    // Set up any overall intial state here.
}
```

XCTest는 테스트 클래스가 시작되기 전에 *setUp()* 클래스 메서드를 한번 실행합니다.

테스트 클래스가 완료된 후 임시 파일을 제거하거나 분석하고자 하는 데이터를 기록해야 한다면 XCTestCase의 [tearDown()](https://developer.apple.com/documentation/xctest/xctestcase/1496280-teardown) 클래스 메서드를 사용하세요.

```swift
override class func tearDown() {
	// This is the tearDown() class method.
    // XCTest calls it after the last test method completes.
    // Perform any overall cleanup here.
}
```

## Prepare and Tear Down State for Each Test Method

각 테스트 메서드에서 필요한 상태에 대해 설정 요구사항에 가장 적합한 [XCTest](https://developer.apple.com/documentation/xctest/xctest)의 설정 메서드를 선택하여 사용하세요.

* 상태를 비동기적으로 설정해야 한다면 [setUp(completion:)](https://developer.apple.com/documentation/xctest/xctest/3856481-setup) 메서드를 오버라이드하세요.

* 모든 상태를 동기적으로 설정하고 예외를 던진다면 [setUpWithError()](https://developer.apple.com/documentation/xctest/xctest/3521150-setupwitherror) 메서드를 오버라이드하세요. 이 메서드는 던져진 예외를 포착하고 테스트 실패로 기록합니다. 

* 상태를 동기적으로 설정하고 예외를 처리할 필요가 없다면 [setUp()](https://developer.apple.com/documentation/xctest/xctest/1500341-setup) 메서드를 오버라이드하세요.

```swift
override func setUp() async throws {
	// This is the setUp() async instance method.
    // XCTest calls it before each test method.
    // Perform any asynchronous setup in this method.
}

override func setUpWithError() throws {
	// This is the setUpWithError() instance method.
    // XCTest calls it before each test method.
    // Set up any synchronous per-test state that might throw errors here.
}

override func setUp() {
	// This is the setUp() instance method.
    // XCTest calls it before each test method.
    // Set up any synchronous per-test state here.
}
```

XCTest는 각 테스트 메서드를 실행하기 전에 설정 메서드를 실행합니다. 먼저 *setUp() async throws* 메서드, 그 다음 *setupWithError()* 메서드, 마지막으로 *setUp()* 메서드를 실행합니다.

테스트 메서드가 완료된 후 임시 파일을 제거하거나 분석하고자 하는 데이터를 기록해야 한다면 XCTest의 해제 메서드를 오버라이드하세요.

```swift
override func tearDown() {
	// This is the tearDown() instance method.
    // XCTest calls it after each test method.
    // Perform any synchronous per-test cleanup here.
}

override func tearDownWithError() throws {
	// This is the tearDownWithError() instance method.
    // XCTest calls it after each test method.
    // Perform any synchrounous per-test cleanup that might throw errors here.
}

override func tearDown() async throws {
	// This is the tearDown() async instance method.
    // XCTest calls it after each test method.
    // Perform any asynchronous per-test cleanup here.
}
```

XCTest는 각 테스트 메서드를 실행한 후 해제 메서드를 실행합니다. 먼저 *tearDown()* 메서드, 그 다음 *tearDownWithError()* 메서드, 마지막으로 *tearDown() async throws* 메서드를 실행합니다. 해제 메서드에서 이후 테스트를 위한 상태를 설정하는 건 피하세요. XCTest는 테스트가 완료되기 전에 크래시가 발생하면, 해제 블록이나 메서드의 호출을 보장하지 않습니다.

> **Important**:
> 설정이나 해제 코드를 메인 액터(Main Actor)에서 실행해야 한다면 정의한 비동기 설정과 해제 메서드에 *@MainActor*를 명시하세요. 액터를 명시하지 않으면 *setUp() async throws*와 *tearDown() async throws* 메서드의 비동기 코드가 임의의 액터에서 실행됩니다.


## Tear Down State After a Specific Test Method

특정 테스트 메서드가 완료된 직후에 즉시 해제해야 한다면 해당 테스트 메서드에 해제 블록을 추가하세요.

```swift
func testMothod1() throws {
	// This is the first test method.
    // Your testing code goes here.
    addTearDownBlock {
    	// XCTest executes this when testMothod1() ends.
    }
}

func testMethod2() throws {
	// This is the second test method.
    // Your testing code goes here.
    addTearDownBlock {
    	// XCTest executes this last when testMethod2() ends.
    }
    addTearDownBlock {
    	// XCTest executes this first when testMethod2() ends.
    }
}
```

해제 블록에서 *await*을 사용하여 비동기 코드를 호출할 수 있으며, 예외를 던져 테스트 실패로 기록할 수 있습니다.

테스트 메서드가 실행되는 동안에 해제 블록을 등록하면 XCTest는 테스트 메서드가 종료된 후, 해제 인스턴스 메서드를 호출하기 전에 해당 해제 블록을 실행합니다. XCTest는 해제 블록을 후입선출 순으로 실행합니다. XCTest는 테스트 메서드의 성공 여부에 상관없이, 심지어 테스트 케이스의 *continueAfterFailure* 프로퍼티를 *false*로 두더라도 등록된 해제 블록을 호출합니다.

해제 블록에서 이후 테스트를 위한 상태를 설정하는 건 피하세요. XCTest는 테스트가 완료되기 전에 크래시가 발생하면, 해제 블록의 호출을 보장하지 않습니다.

> **Important**:
> 해제 블록에 작성한 비동기 코드가 메인 액터에서 실행해야 한다면 해제 블록에 *@MainActor*를 명시하세요. 액터를 명시하지 않으면 해제 블록의 비동기 코드를 임의의 액터에서 실행합니다. 해제 블록에서 *try*를 사용하여 예외를 던지는 메서드를 호출한다면 해당 블록은 비동기로 실행됩니다.