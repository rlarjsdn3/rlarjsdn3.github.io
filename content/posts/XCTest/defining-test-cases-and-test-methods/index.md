---
date: '2024-12-17T23:29:53+09:00'
draft: false
title: '[번역] XCTest / Defining Test Cases and Test Methods (애플 공식 문서)'
description: "작성한 코드가 예상대로 동작하는 걸 확인하기 위해 테스트 타깃에 테스트 메소드와 테스트 케이스를 추가하세요."
tags: ["XCTest", "XCTestCase"]
categories: ["XCTest"]
cover:
---

## Overview

코드의 특정 측면을 검증하고자 하나 이상의 테스트 메소드를 작성하여 Xcode 프로젝트에 테스트를 추가하세요. 관련된 테스트 메서드들은 [XCTestCase]()의 서브 클래스인 테스트 케이스로 그룹화하세요.

프로젝트에 테스트를 추가하려면:

* 테스트 타겟에 새로운 *XCTestCase*의 서브 클래스를 생성하세요.

* 테스트 케이스에 하나 이상의 테스트 메서드를 작성하세요.

* 각 테스트 메서드에 하나 이상의 테스트 검증(Assertion)을 작성하세요.

테스트 메서드는 *XCTestCase* 서브 클래스의 인스턴스 메서드로 매개변수와 반환값이 없으며, *test*라는 소문자 이름으로 시작합니다. 테스트 메서드는 XCTest 프레임워크에 의해 자동으로 감지됩니다.

```swift
class TableValidationTests: XCTestCase {
	/// Tests that a new table instane has zero rows and columns.
    func testEmptyTableRowAndColumnCount() {
    	let table = Table()
        XCAssertEqual(table.rowCount, 0, "Row count was not zero.")
        XCAssertEqual(table.columnCount, 0, "Column count was not zero.")
    }
}
```

위 예제는 *TableValidationTests*라 불리는 *XCTestCase* 서브 클래스를 정의하고, 해당 클래스는 *testEmptyTableRowAndColumnCount()*라 불리는 단일 테스트 메서드가 포함되어 있습니다. 이 테스트 메서드는 *Table*이라 불리는 새로운 클래스 인스턴스를 생성하며, 해당 인스턴스가 초기화된 이후 *rowCount*와 *columnCount* 프로퍼티가 모두 0인지 확인합니다.

> **Tip**:
> 테스트 케이스와 테스트 메서드 이름은 Xcode의 테스트 네비게이터와 테스트를 그룹화하고 식별하기 위한 통합 보고서로 사용됩니다.
>
> 테스트 구성을 명확히 하기 위해 각 테스트 케이스의 이름을 그 안에 포함된 테스트를 요약하는 이름으로 지정하세요. 예를 들어, *TableValidationTests*, *NetworkReachabilityTests* 또는 *JSONParsingTests*가 있을 수 있습니다.
>
> 실패한 테스트를 식별하기 위해 각 테스트 메서드에 해당 메서드에 의해 무엇을 테스트하는지 명확히 나타내는 이름을 지정하세요. 예를 들어, *testEmptyTableRowAndColumnCount()*, *testUnreachableURLAccessThrowsAnError()* 또는 *testUserJSONFeedParsing()*이 있을 수 있습니다. 

## Asserting Test Conditions

테스트 메서드 내에서 코드가 예상한대로 제대로 동작하는지 검증할 수 있습니다. *XCTAssert* 함수군을 사용하여 불리언(Boolean) 조건, *nil*인지 *nil*이 아닌지, 예상한 값과 예외를 던지는지 확인할 수 있습니다.

예를 들어, 위 예제는 *XCTAssertEqual(\*:\*:\*:file:line:)* 함수를 사용하여 두 정수가 동일한 값을 가지는지 검증합니다.