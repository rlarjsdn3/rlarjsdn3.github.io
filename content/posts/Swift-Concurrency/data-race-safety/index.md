---
date: '2025-10-25T22:52:40+09:00'
draft: false
title: '[번역] Swift Concurrency / Data Race Safety (Migrating to Swift 6)'
description: "Swift에서 데이터 경합을 방지하는 동시성 코드를 작성하기 위해 사용하는 핵심적인 개념을 배워보세요."
tags: ["Data Isolation", "Actor", "Task"]
categories: ["Swift Concurrency"]
cover:
    image: images/code.jpg
---


전통적으로, 변경 가능한 상태(Mutable State)는 런타임에서 세심한 동기화(Synchronization)을 통해 수동으로 보호해야 했습니다. 락(Lock)과 큐(Queue) 같은 도구를 사용하여 데이터 경합을 방지하는 일은 전적으로 개발자의 몫이었습니다. 이는 처음부터 올바르게 구현하기도 어렵지만, 시간이 지나면서 계속 올바르게 작동하도록 유지하는 것은 더더욱 어렵습니다. 동기화가 필요한지 여부를 판단하는 것조차 매우 어려울 수 있습니다. 최악의 경우, 스레드에 안전하지 않은 코드는 런타임에서 예기치 못한 동작이 일어난다고 보장되지 않습니다. 이런 코드는 겉보기에는 잘 동작하는 것처럼 보일 수 있으며, 이는 데이터 경합 특유의 잘못되고 예측 불가능한 동작이 드러나려면 매우 이례적인 조건이 필요하기 때문입니다.

좀 더 엄밀히 말하면, 데이터 경합은 한 스레드가 메모리에 접근하는 동안 다른 스레드가 동일한 메모리를 변경할 때 발생합니다. Swift 6 언어 모드는 컴파일 시점에서 데이터 경합을 방지함으로써 이러한 문제를 제거합니다.

> **Important**:
> 다른 언어에서 `async`/`await`이나 액터(Actor)와 같은 요소를 접해보셨을 수 있습니다. Swift에서의 이러한 개념은 겉보기만 비슷할 수 있으므로 각별히 주의하세요.


## Data Isolation

Swift의 동시성 시스템은 컴파일러가 변경 가능한 모든 상태의 안정성을 이해하고 검증할 수 있게 합니다. 이는 **데이터 격리(Data Isolation)**라는 특별한 메커니즘으로 이루어집니다. 데이터 격리는 변경 가능한 상태에 대한 상호 배타적 접근을 보장합니다. 이는 동기화의 한 형태로, 개념적으로 락과 유사합니다. 그러나 락과 달리, 데이터 격리가 제공하는 보호는 컴파일 시점에 이루어집니다.

Swift 개발자는 다음 두 가지 방식으로 데이터 격리와 상호작용합니다. 정적 방식과 동적 방식입니다.

정적(static)이라는 용어는 런타임 상태의 영향을 받지 않는 프로그램 요소를 설명할 때 사용됩니다. 함수 정의와 같은 이러한 요소는 키워드와 애노테이션(annotation)으로 이루어집니다. Swift의 동시성 시스템은 타입 시스템의 확장입니다. 함수를 선언하고 타입을 선언할 때, 여러분은 이를 정적으로 선언한 것입니다. 격리는 이러한 정적 선언의 일부가 될 수 있습니다. 

그러나 타입 시스템만으로는 런타임 동작을 충분히 설명하지 못하는 경우가 있습니다. 예를 들어, Swift에 노출된 Objective-C 타입이 있을 수 있습니다. Swift 코드 밖에서 이루어진 이러한 선언은 안전한 사용을 보장하기에 컴파일러가 필요로 하는 정보를 충분히 제공하지 못할 수 있습니다. 이러한 상황을 수용하기 위해, 격리 요구사항을 동적으로 표현할 수 있게 해주는 추가 기능들이 제공됩니다. 

정적이든 동적이든 데이터 격리는 컴파일러가 여러분이 작성한 Swift 코드가 데이터 경합으로부터 자유롭도록 보장합니다.

> **Note**:
> 동적 격리에 대한 더 많은 정보를 보려면 [동적 격리(Dynamic Isolation)](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/incrementaladoption#Dynamic-Isolation)를 참고하세요.


### Isolation Domains

데이터 격리는 공유되는 변경 가능한 상태를 보호하기 위해 사용되는 메커니즘입니다. 하지만 독립적인 격리 단위에 대해 논하는 것이 유용할 때가 있습니다. 이를 **격리 도메인(Isolation Domain)**이라고 합니다. 특정 도메인이 보호를 책임지는 상태의 범위는 매우 다양합니다. 격리 도메인은 단일 변수 하나를 보호할 수도 있고, 사용자 인터페이스와 같은 전체 하위 시스템을 보호할 수도 있습니다.

격리 도메인의 핵심적인 특징은 바로 그것이 제공하는 안정성입니다. 변경 가능한 상태는 한 번에 하나의 격리 도메인에서만 접근할 수 있습니다. 변경 가능한 상태를 한 격리 도메인에서 다른 도메인으로 전달할 수는 있지만, 서로 다른 도메인에서 동시에 그 상태에 접근할 수는 없습니다. 이 보장은 컴파일러에 의해 검증됩니다.

직접 명시적으로 정의하지 않았더라도, 모든 함수와 변수 선언에는 명확하게 정의된 정적 격리 도메인이 있습니다. 이러한 도메인은 항상 다음 세 가지 범주 중 하나에 속합니다:

1. 격리되지 않음(Non-isolated)

2. 특정 값에 격리됨(Isolated to an actor value)

3. 전역 액터에 격리됨(Isolated to a global actor)


## Non-isolated

함수와 변수는 반드시 명시적인 격리 도메인의 일부일 필요는 없습니다. 사실, 격리가 없는 것이 기본값이며 이를 **비-격리(Non-Isolated)**라고 합니다. (비-격리라 하더라도) 데이터 격리 규칙은 동일하게 적용되기 때문에, 비-격리 코드는 다른 도메인에 속한 상태를 함부로 변경할 수 없습니다.

```swift
func sailTheSea() {
}
```

이 최상위 함수에는 정적 격리가 없으므로 비-격리 상태입니다. 따라서 다른 비격리 함수를 안전하게 호출할 수 있고, 비격리 변수에도 접근할 수 있습니다. 하지만 다른 격리 도메인에 속한 어떤 것에도 접근할 수는 없습니다.

```swift
class Chicken {
    let name: String
    var currentHunger: HungerLevel
}
```

위 코드는 비-격리 타입의 예시입니다. 상속은 정적 격리에 영향을 줄 수 있습니다. 하지만 상위 클래스나 프로토콜 채택이 없는 이 단순한 클래스는 기본 격리를 사용합니다.

데이터 격리는 비-격리 엔터티가 다른 도메인의 변경 가능한 상태에 (동기적으로) 접근하지 못하도록 보장합니다. 따라서 비격리 함수와 변수는 (`await`을 통해) 어떤 다른 도메인에서도 항상 안전하게 접근할 수 있습니다.


## Actors

액터는 개발자가 격리 도메인을 정의하고, 그 도메인 안에서 동작하는 메서드를 함께 정의할 수 있도록 합니다. 액터의 모든 저장 프로퍼티는 해당 액터 인스턴스에 격리되어 있습니다.

```swift
actor Island {
    var flock: [Chicken]
    var food: [Pineapple]

    func addToFlock() {
        flock.append(Chicken())
    }
}
```

여기서 각 `Island` 인스턴스는 새로운 도메인을 정의하게 하며, 이는 해당 인스턴스의 프로퍼티 접근을 보호하는 데 사용됩니다. `Island.addToFlock` 메서드는 `self`에 격리되어 있다고 표현합니다. 메서드의 본문(body)에서는 격리 도메인이 공유하는 모든 데이터에 접근할 수 있기 때문에, `flock` 프로퍼티에도 동기적으로 접근할 수 있습니다.

액터 격리는 선택적으로 비활성화할 수 있습니다. 이는 격리된 타입 안에 코드를 그대로 두고 싶지만, 그와 함께 따라오는 격리 요구 사항에서는 벗어나고 싶을 때 유용합니다. 비격리 메서드는 어떤 보호된 상태에도 동기적으로 접근할 수 없습니다.

```swift
actor Island {
    var flock: [Chicken]
    var food: [Pineapple]

    nonisolated func canGrow() -> PlantSpecies {
        // neither flock nor food are accessible here
    }
}
```

액터의 격리 도메인은 해당 액터의 메서드에만 국한되지 않습니다. `isolated` 매개변수를 받는 함수 또한 다른 어떤 형태의 동기화를 하지 않고도 액터 격리 상태에 접근할 수 있습니다.

```swift
func addToFlock(of island: isolated Island) {
    island.flock.append(Chicken())
}
```

> **Note**:
> 액터에 대한 더 많은 정보를 보려면 Swift 프로그래밍 가이드의 [액터(Actors)](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/incrementaladoption#Dynamic-Isolation)를 참고하세요.


## Global Actors

전역 액터는 일반 액터의 모든 특성을 공유하지만, 선언을 그 격리 도메인에 정적으로 할당할 수 있다는 의미도 가집니다. 이는 액터 이름과 일치하는 애노테이션을 사용하여 이루어집니다. 전역 액터는 여러 타입의 그룹이 모두 하나의 공유되는 변경 가능한 상태 풀(single pool of shared mutable state)로 운용되어야 할 때 특히 유용합니다.

```swift
@MainActor
class ChickenValley {
    var flock: [Chicken]
    var food: [Pineapple]
}
```

이 클래스는 메인 액터(MainActor)에 정적으로 격리되어 있습니다. 이는 해당 클래스의 변경 가능한 상태에 대한 모든 접근이 그 격리 도메인에서 이루어지도록 보장합니다.

`nonisolated` 키워드를 사용하면 특정 프로퍼티나 메서드를 액터 격리에서 제외할 수 있습니다. 다만 액터 타입과 마찬가지로, 그렇게 되면 어떤 보호된 상태에도 (동기적으로) 접근할 수 없게 됩니다.

```swift
@MainActor
class ChickenValley {
    var flock: [Chicken]
    var food: [Pineapple]

    nonisolated func canGrow() -> PlantSpecies {
        // neither flock, food, nor any other MainActor-isolated
        // state is accessible here
    }
}
```


## Tasks

작업(task)은 프로그램 내에서 동시에 실행될 수 있는 작업의 한 단위입니다. Swift에서는 작업 밖에서 동시 코드를 실행할 수는 없지만, 항상 직접 수동으로 작업을 시작해야 한다는 뜻은 아닙니다. 일반적으로 비동기 함수는 자신을 실행하는 작업을 인지할 필요가 없습니다. 실제로 작업은 종종 더 높은 수준, 애플리케이션 프레임워크 내부나 심지어 프로그램의 진입점에서 시작되기도 합니다. 

작업은 서로 동시에 실행될 수 있지만, 각 개별 작업은 한 번에 하나의 함수만 실행합니다. 작업은 코드를 시작부터 끝까지 순서대로 실행합니다. 


```swift
Task {
    flock.map(Chicken.produce)
}
```

작업은 항상 격리 도메인을 가집니다. 작업은 액터 인스턴스에 격리되거나, 전역 액터에 격리되거나, 또는 비-격리일 수 있습니다. 이러한 격리는 수동으로 설정할 수도 있지만, 컨텍스트에 따라 자동으로 상속될 수도 있습니다. 작업 격리는 다른 모든 Swift 코드와 마찬가지로 변경 가능한 상태에 접근할 수 있는지를 결정합니다.

작업은 동기 코드와 비동기 코드 모두 실행할 수 있습니다. 그러나 구조가 어떻든, 또 몇 개의 작업이 포함되었든 간에 동일한 격리 도메인에 속한 함수들은 서로 동시에 호출될 수 없습니다. 동일한 격리 도메인 안에서는 동기 코드가 항상 하나씩 차례대로 실행됩니다.

> **Note**:
> 작업에 대한 더 많은 정보를 보려면 Swift 프로그래밍 가이드의 [작업(Tasks)](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/incrementaladoption#Dynamic-Isolation)를 참고하세요.


## Isolation Inference and Inheriance

격리를 명시적으로 지정하는 방법은 여러 가지가 있습니다. 그러나 선언의 컨텍스트에 따라 격리가 암묵적으로 설정되는 경우도 있으며, 이를 **격리 추론(Isolation Inference)**이라고 합니다.


### Classes

하위 클래스는 항상 상위 클래스와 동일한 격리를 가집니다. 

```swift 
@MainActor
class Animal {
}

class Chicken: Animal {
}
```

`Chicken`은 `Animal`을 상속하기 때문에, `Animal` 타입의 정적 격리가 암묵적으로 그대로 적용됩니다. 뿐만 아니라 이 격리는 하위 클래스에서 변경할 수도 없습니다. 모든 `Animal` 인스턴스가 메인 액터에 격리되도록 선언되어 있으므로, 모든 `Chicken` 인스턴스 역시 동일하게 메인 액터에 격리됩니다.

타입의 정적 격리는 기본적으로 해당 타입의 프로퍼티와 메서드에도 추론되어 적용됩니다.

```swift
@MainActor
class Animal {
    // all declarations within this type are also
    // implicitly MainActor-isolated
    let name: String

    func eat(food: Pineapple) {
    }
}
```

> **Note**:
> 상속에 대한 더 많은 정보를 보려면 Swift 프로그래밍 가이드의 [상속(Inheritance)](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/incrementaladoption#Dynamic-Isolation)을 참고하세요.
{% endhint %}


### Protocols

프로토콜 준수는 격리에 암묵적으로 영향을 줄 수 있습니다. 그러나 프로토콜이 격리에 미치는 효과는 해당 준수가 어떻게 적용되느냐에 따라 달라집니다.

```swift
@MainActor
protocol Feedable {
    func eat(food: Pineapple)
}

// inferred isolation applies to the entire type
class Chicken: Feedable {
}

// inferred isolation only applies within the extension
extension Pirate: Feedable {
}
```

프로토콜의 요구사항 자체도 격리될 수 있습니다. 이를 통해 프로토콜을 따르는 타입에서 격리가 어떻게 추론되는지를 더 세밀하게 제어할 수 있습니다.

```swift
protocol Feedable {
    @MainActor
    func eat(food: Pineapple)
}
```

프로토콜이 어떻게 정의되었든, 그리고 준수가 어떻게 추가되었든 간에 다른 정적 격리 메커니즘을 변경할 수는 없습니다. 어떤 타입이 전역적으로 격리되어 있다면, 명시적으로든 또는 상위 클래스로부터의 추론을 통해서든, 프로토콜 준수를 사용해 이를 바꿀 수는 없습니다.

{% hint style="info" %}
**Note**
프로토콜에 대한 더 많은 정보를 보려면 Swift 프로그래밍 가이드의 [프로토콜( Protocol)](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/incrementaladoption#Dynamic-Isolation)을 참고하세요.
{% endhint %}


#### Function Types

격리 추론은 타입이 자신의 프로퍼티와 메서드의 격리를 암묵적으로 정의할 수 있게 합니다. 그러나 이는 모두 선언 시에 적용되는 내용입니다. 함수 값에서도 격리 상속을 통해 유사한 효과를 얻을 수 있습니다.

기본적으로 클로저는 생성된 컨텍스트와 동일한 격리에 속합니다. 예를 들어:

```swift
@MainActor
class Model { ... }

@MainActor
class C {
    var models: [Model] = []

    func mapModels<Value>(
      _ keyPath: KeyPath<Model, Value>
    ) -> some Collection<Value> {
        models.lazy.map { $0[keyPath: keyPath] }
    }
}
```

위 코드에서 `LazySequence.map`에 전달되는 클로저는 `@escaping (Base.Element) -> U` 타입을 가집니다. 이 클로저는 처음 생성된 메인 액터에 머물러야 합니다. 이렇게 함으로써 클로저는 주변 컨텍스트에서 상태를 캡처하거나 격리된 메서드를 호출할 수 있습니다. 

원래 컨텍스트와 동시에 실행될 수 있는 클로저는 이후 섹션에서 설명할 `@Sendable`과 `sending` 애노테이션으로 명시적으로 표시해, 동시성 안전성을 보장해야 합니다.

동시에 실행될 수 있는 `async` 클로저의 경우에도, 해당 클로저는 여전히 원래 컨텍스트의 격리를 캡처할 수 있습니다. 이 메커니즘은 `Task` 생성자에서 사용되며, 기본적으로 전달된 작업이 원래 컨텍스트에 격리되도록 하면서도 명시적으로 격리를 지정할 수 있게 해줍니다.

```swift
@MainActor
func eat(food: Pineapple) {
    // the static isolation of this function's declaration is
    // captured by the closure created here
    Task {
        // allowing the closure's body to inherit MainActor-isolation
        Chicken.prizedHen.eat(food: food)
    }

    Task { @MyGlobalActor in
        // this task is isolated to `MyGlobalActor`
    }
}
```

여기서 클로저의 타입은 `Task.init`에 의해 정의됩니다. 해당 선언이 어떤 액터에도 격리되어 있지 않더라도, 새로 생성된 작업은 명시적인 전역 액터로 지정되지 않는 한 자신을 둘러싼 스코프의 `MainActor` 격리를 상속합니다. 함수 타입은 격리 동작을 제어할 수 있는 여러 메커니즘을 제공하지만, 기본적으로 다른 타입들과 동일하게 동작합니다.

> **Note**:
> 클로저에 대한 더 많은 정보를 보려면 Swift 프로그래밍 가이드의 [클로저( Closure)](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/incrementaladoption#Dynamic-Isolation)을 참고하세요.
{% endhint %}


## Isolation Boundaries

격리 도메인은 변경 가능한 상태를 보호하지만, 프로그램은 이러한 보호만으로는 충분하지 않을 수 있습니다. 프로그램은 데이터를 주고받으며 소통하고 조율해야 합니다. 격리 도메인 안팎으로 값을 이동하는 것을 **격리 경계를 넘는다(crossing an isolation boundary)**라고 합니다.

값은 공유되는 변경 가능한 상태에 동시에 접근할 가능성이 없을 때만 격리 경계를 넘어갈 수 있습니다. 값은 비동기 함수 호출을 통해 직접 경계를 넘어갈 수 있습니다. 서로 다른 격리 도메인에 속한 비동기 함수를 호출할 때는 매개변수와 반환 값이 그 도메인으로 이동해야 합니다. 값은 클로저에 캡처될 때 간접적으로 경계를 넘어갈 수 있습니다. 클로저는 동시 접근이 발생할 수 있는 많은 가능성을 만들어내며, 한 도메인에서 생성된 뒤 다른 도메인에서 실행될 수도 있습니다. 심지어 여러 다른 도메인에서 실행될 수도 있습니다.


### Sendable Types

특정 타입의 값이 격리 경계를 넘어가도 안전한 경우가 있습니다. 이는 타입 자체가 스레드에 안전할 때 발생합니다. 이러한 특성은 `Sendable` 프로토콜로 표현됩니다. `Sendable`을 준수한다는 것은 해당 타입이 스레드에 안전하다는 의미이며, 그 타입의 값은 데이터 경합 위험 없이 임의의 격리 도메인 간에 공유될 수 있습니다. 

Swift는 값 타입을 사용할 것을 권장하는데, 이는 값 타입이 본질적으로 안전하기 때문입니다. 값 타입을 사용하면 프로그램의 다른 부분이 동일한 값에 대한 참조를 공유할 수 없습니다. 값 타입의 인스턴스를 함수에 전달하면, 함수는 해당 값의 독립적인 복사본을 갖게 됩니다. 값 타입은 공유되는 변경 가능한 상태가 없음을 보장하므로, Swift에서 값 타입은 저장 프로퍼티가 모두 `Sendable`일 경우 암묵적으로 `Sendable`이 됩니다. 그러나 이러한 암묵적 준수는 모듈 밖에서는 보이지 않습니다. 모듈 외부에서는 이 암시적 준수가 드러나지 않기 때문에, 외부에서는 해당 타입이 `Sendable`인지 여부를 알 수 없습니다. 타입을 `Sendable`로 만드는 것은 해당 타입의 퍼블릭 API 규칙의 일부이므로 항상 명시적으로 선언해야 합니다.

```swift
enum Ripeness {
    case hard
    case perfect
    case mushy(daysPast: Int)
}

struct Pineapple {
    var weight: Double
    var ripeness: Ripeness
}
```

여기서 `Ripness`와 `Pineapple` 타입은 모두 암시적으로 `Sendable`입니다. 두 타입이 전부 `Sendable` 값 타입으로만 구성되어 있기 때문입니다.

> **Note**:
> 센더블에 대한 더 많은 정보를 보려면 Swift 프로그래밍 가이드의 [센더블( Sendable)](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/incrementaladoption#Dynamic-Isolation)을 참고하세요.



### Flow-Sensitive Isolation Analysis

`Sendable` 프로토콜은 타입 전체의 스레드 안전성을 표현하는 데 사용됩니다. 그러나 어떤 경우에는 `Sendable`이 아닌 타입의 특정 인스턴스가 안전하게 사용될 수도 있습니다. 컴파일러는 종종 [지역 기반 격리(Region-Based Isolation)](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0414-region-based-isolation.md)라고 불리는 흐름 민감적 분석(flow-sensitive analysis)을 통해 실제로 동시성 문제로부터 안전한지를 판단할 수 있습니다.  

지역 기반 격리는 컴파일러가 데이터 경합을 유발하지 않는다는 것을 증명할 수 있을 때, `Sendable`이 아닌 타입의 인스턴스가 격리 경계를 넘나드는 것을 허용합니다.

```swift
func populate(island: Island) async {
    let chicken = Chicken()

    await island.adopt(chicken)
}
```

여기서 컴파일러는 `chicken`이 `Sendable`이 아닌 타입이더라도, `chicken`이 `island` 격리 도메인으로 넘어가는 것이 안전하다고 올바르게 판단할 수 있습니다. 그러나 이러한 `Sendable` 검사 예외는 주변 코드에 본질적으로 의존합니다. 만약 `chicken` 변수에 대해 안전하지 않은 접근이 추가된다면, 컴파일러는 여전히 오류를 발생시킬 것입니다.

```swift
func populate(island: Island) async {
    let chicken = Chicken()

    await island.adopt(chicken)

    // this would result in an error
    chicken.eat(food: Pineapple())
}
```

지역 기반 격리는 코드에 아무런 변경을 하지 않아도 동작합니다. 그러나 함수의 매개변수나 반환 값을 통해 지역 기반 격리에 기반한 도메인 간 이동을 지원한다는 사실을 명시적으로 표현할 수도 있습니다.

```swift
func populate(island: Island, with chicken: sending Chicken) async {
    await island.adopt(chicken)
}
```

컴파일러는 이제 모든 호출 지점에서 `chicken` 매개변수가 보다 안전한 방식으로 접근할 것임을 보장할 수 있습니다. 이는 본래 매우 큰 제약을 완화한 것입니다. `ssending`이 없다면, 이 함수를 구현하려면 먼저 `Chicken`이 `Sendable`을 준수하도록 요구해야 했을 것입니다.


## Actor-Isolated Types

액터는 값 타입이 아니지만, 자신의 모든 상태를 고유한 격리 도메인에서 보호하기 때문에 본질적으로 격리 경계를 넘어 전달해도 안전합니다. 따라서 액터 타입의 프로퍼티가 `Sendable`이 아니더라도, 모든 액터 타입은 암시적으로 `Sendable`로 간주합니다.

```swift
actor Island {
    var flock: [Chicken]  // non-Sendable
    var food: [Pineapple] // Sendable
}
```

전역 액터에 격리된 타입은 비슷한 이유로 암시적으로 `Sendable`입니다. 이들은 독자적인 격리 도메인을 갖고 있지는 않지만, 여전히 액터에 의해 상태가 보호되기 때문입니다.

```swift
@MainActor
class ChickenValley {
    var flock: [Chicken]  // non-Sendable
    var food: [Pineapple] // Sendable
}
```

<details>

<summary>원문 보기</summary>

Actors are not value types, but because they protect all of their state in their own isolation domain, they are inherently safe to pass across boundaries. This makes all actor types implicitly `Sendable`, even if their properties are not `Sendable` themselves.

```swift
actor Island {
    var flock: [Chicken]  // non-Sendable
    var food: [Pineapple] // Sendable
}
```

Global-actor-isolated types are also implicitly `Sendable` for similar reasons. They do not have a private, dedicated isolation domain, but their state is still protected by an actor.

```swift
@MainActor
class ChickenValley {
    var flock: [Chicken]  // non-Sendable
    var food: [Pineapple] // Sendable
}
```

</details>


## Reference Types

값 타입과 달리 참조 타입은 암시적으로 `Sendable`이 될 수 없습니다. 참조 타입을 `Sendable`로 만들수는 있지만, 그 과정에서 여러 가지 제약이 따릅ㄴ디ㅏ. 클래스를 `Sendable`로 만들려면 변경 가능한 상태를 전혀 포함하지 않아야 하며, 모든 불변 프로퍼티도 반드시 `Sendable`이어야 합니다. 또한, 컴파일러는 `final` 클래스에 대해서만 `Sendable`인지 검증할 수 있습닌다. 

```swift
final class Chicken: Sendable {
    let name: String
}
```

컴파일러가 판단할 수 없는 동기화 요소(예: C/C++/Objective-C로 구현된 스레드에 안전한 타입)를 사용하여 `Sendable`의 스레드 안전성 요구 사항을 충족하는 것도 가능합니다. 이러한 타입은 `@unchecked Sendable`을 준수한다고 표시하여, 해당 타입이 스레드에 안전하다고 컴파일러에 약속할 수 있습니다. 컴파일러는 `@unchecked Sendable` 타입에 대해서는 어떤 검사도 수행하지 않으므로, 이 예외는 신중하게 사용해야 합니다.



## Suspension Points

한 작업에서 한 함수가 다른 격리 도메인의 함수를 호출할 때 격리 도메인 사이를 전환할 수 있습니다. 격리 경계를 넘는 호출은 비동기적으로 이루어져야 하는데, 목적지 도메인이 다른 작업을 실행 중일 수 있기 때문입니다. 그런 경우, 작업은 목적지 도메인이 사용 가능해질 때까지 일시 중단됩니다. 한 가지 중요한 점은, 일시 중단 지점(Suspension Point)에서는 스레드를 차단(block)하지 않습니다. 현재 격리 도메인(과 그 도메인을 사용 중인 스레드)는 다른 작업을 수행할 수 있도록 비워집니다. Swift 동시성 런타임은 일시 중단된 작업을 기다리는 동안에도 시스템이 계속해서 작업을 진행할 수 있도록 보장합니다. 이를 통해 동시성 코드에서 흔히 발생하는 교착 상태(deadlocks)의 원인을 제거합니다.

```swift
@MainActor
func stockUp() {
    // beginning execution on MainActor
    let food = Pineapple()

    // switching to the island actor's domain
    await island.store(food)
}
```

잠재적인 일시 중단 지점은 소스 코드에서 `await` 키워드로 표시됩니다. 이 키워드는 호출이 런타임에 일시 중단될 수 있음을 나타내지만, `await` 자체가 반드시 중단을 강제하는 것은 아닙니다. 호출된 함수는 특정한 동적 조건에서만 중단될 수 있으며, `await`으로 표시된 호출이 실제로 중단되지 않을 수도 있습니다.


## Atomicity

액터는 데이터 경합으로부터 안전을 보장하지만, 일시 중단 지점 전반에 걸친 원자성(Atomicity)을 보장하지 않습니다. 동시 코드에서는 다른 스레드가 중간 상태를 볼 수 없도록 일련의 연산을 하나의 원자적 단위로 함께 실행해야 할 때가 자주 있습니다. 이러한 특성을 필요로 하는 코드 단위를 **임계 구역(Critical Section)**이라 합니다.

현재 격리 도메인이 (일시 중단되어) 다른 작업을 수행할 수 있도록 비워질 수 있기 때문에, 비동기 호출 이후 액터에 격리된 상태가 변경될 수 있습니다. 따라서, 잠재적인 일시 중단 지점을 명시적으로 표시하는 것은 임계 구역의 끝을 알리는 방법으로 볼 수 있습니다.

```swift
func deposit(pineapples: [Pineapple], onto island: Island) async {
   var food = await island.food
   food += pineapples
   await island.store(food)
}
```

이 코드는 비동기 호출 사이에 `island` 액터의 `food` 값이 변경되지 않는다고 잘못 가정합니다. 임계 구역은 항상 동기적으로 실행되도록 구성해야 합니다.

> **Note**:
비동기 함수를 정의하고 호출하는 더 자세한 방법을 보려면 Swift 프로그래밍 가이드의 [Defining and Calling Asynchronous Functions](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/incrementaladoption#Dynamic-Isolation)을 참고하세요.
