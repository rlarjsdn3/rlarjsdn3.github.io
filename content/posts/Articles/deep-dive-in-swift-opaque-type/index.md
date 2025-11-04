---
date: '2024-09-03T21:58:10+09:00'
draft: false
title: 'Swift 불투명한 타입(some) 알아보기'
description: ""
tags: ["Opaque Type", "Boxed Protocol Type", "some", "any"]
categories: ["Articles"]
cover:
    image: images/swift.jpg
    caption: ""
---

## 개요

Swift 5.1에 새롭게 등장한 불투명한 타입(opaque type)은 프로토콜을 준수하는 실제 타입(underlying type)에 대한 자세한 정보를 숨깁니다. 불투명한 반환 타입을 가지는 함수는 자신이 반환하는 타입에 대한 구체적인 정보를 외부에 드러내지 않습니다. 

Swift는 프로토콜을 준수하는 실제 타입을 불투명한 타입과 박스형 프로토콜 타입으로 외부에 드러내지 않고 감출 수 있습니다. 겉으로 보이는 기능은 동일해 보이지만, Swift 컴파일러가 해당 타입을 처리하는 내부 방식에는 큰 차이가 있으며, 이는 성능에도 큰 영향을 끼칩니다. 따라서 이러한 차이를 정확히 이해하고 적재적소에 적용할 필요가 있습니다.

## 불투명한 타입

불투명한 타입은 프로토콜을 준수하는 실제 타입에 대한 자세한 정보를 숨깁니다. 이 타입은 함수나 메서드, 프로퍼티를 호출하는 호출자에게 구체적인 타입을 은닉하고자 할 때 유용합니다. 이는 호출자에게 구체적인 타입이 별로 중요하지 않은 경우, 이를 숨기고 프로토콜 준수 여부만을 공개하여 인터페이스를 단순화할 수 있습니다.

프로토콜 앞에 **some** 키워드를 붙여 불투명한 타입으로 만들 수 있습니다. 아래 예제는 불투명한 타입을 반환하는 메서드를 보여줍니다.

```swift
func `repeat`<E>(_ element: E, count: Int) -> some Collection {
    Array<E>(repeating: element, count: count)
}
```

이 메서드는 구체적인 타입은 숨기고, 단지 **Collection** 프로토콜을 준수하는 객체를 반환한다는 사실만 알리고 있습니다. 호출자는 이 타입의 구체적인 정보를 알 수 없지만, 컴파일러는 해당 타입을 식별할 수 있습니다.

이 덕분에, 만약 프로토콜이 **Self**(프로토콜이 준수하는 실제 객체)를 참조하거나 연관된 타입(associated type)을 가지고 있다면, 불투명한 반환 타입을 통해 구체적인 타입은 숨기면서 컴파일러는 해당 타입을 추론할 수 있습니다.

> **🟡 Important**
> 프로토콜이 **Self**를 참조하거나 연관된 타입을 가진다면, 함수에서 해당 프로토콜을 반환 타입으로 사용하지 못합니다. 이는 컴파일 시간에 함수 외부에서 해당 타입의 실제 타입을 추론할 수 없기 때문입니다. 오직 제네릭 제약으로만 사용할 수 있습니다.
>
>```swift
>protocol Container {
>    associatedtype Item
>    var count: Int { get }
>    subscript(i: Int) -> Item { get }
>}
>extension Array: Container { }
> // 🔴 Error: Protocol with associated types can't be used as a return type.
>func makeArray<T>(items: T...) -> Container {
>    items
>}
>```
>

### 불투명한 타입은 역-제네릭 타입
  
실제 반환 타입에 대한 자세한 정보를 숨긴다는 이런 특징은 불투명한 타입을 역-제네릭 타입이라고 부르게 합니다. 아래 예제는 우리가 자주 접하는 제네릭 함수를 보여줍니다.
  
```swift
extension Array {
    
    func map<T>(_ transform: (Element) -> T) -> [T] {
        var result = [T]()
        self.forEach { element in
            result.append(transform(element))
        }
        return result
    }
    
}
```

**map(_:)** 함수는 제네릭의 가장 일반적인 특징을 보여줍니다. 해당 함수의 구현부는 구체적인 타입이 추상화되어 있는 반면에, 호출부에서는 타입을 지정하며 해당 타입이 무엇인지 정확히 알 수 있습니다.
  
반면에, 불투명한 반환 타입을 가지는 함수는 구현부에서 반환하는 실제 타입을 명확하게 지정하며 해당 타입이 무엇인지 알 수 있는 반면에, 호출부에서는 구체적인 타입은 알 수 없으며 프로토콜 수준으로 추상화되어 있습니다.
  
아래 표는 제네릭과 불투명한 타입의 차이를 보여줍니다.
  
| <div width="20px">구분</div> | 제네릭 | 불투명한 타입 |
| :-- | :--- | :-------- |
| 호출부 | ・ 구현 내부에서 사용할 타입을 지정하고 알 수 있음  | ・ 반환받는 실제 타입은 알 수 없고 추상화되어 있음 |
| 구현부 | ・ 구현부의 실제 타입을 알 수 없고, 호출 시 결정됨 | ・ 반환하는 실제 타입을 구현부에서 지정하고 알 수 있음 |
  


### 하나의 실제 타입만을 취급
  
불투명한 타입은 박스형 프로토콜 타입과는 달리, 메서드나 프로퍼티에서 하나의 실제 타입만을 취급해야 한다는 점입니다. 예를 들어, 불투명한 반환 타입을 가지는 함수나 메서드는 서로 다른 실제 타입을 동시에 반환하지 못하며, 동일한 실제 타입만을 반환해야 합니다. 아래 예제는 이를 보여주고 있습니다.
  
```swift
protocol Shape {
    func draw() -> String
}

struct Square: Shape {
    var size: Int
    func draw() -> String {
        var results = [String]()
        (1...size).forEach { size in
            results.append(String(repeating: "*", count: size))
        }
        return results.joined(separator: "\n")
    }
}

struct Triangle: Shape {
    var size: Int
    func draw() -> String {
        var results = [String]()
        (1...size).forEach { size in
            results.append(String(repeating: "*", count: size))
        }
        return results.joined(separator: "\n")
    }
}

// 🔴 Error: The return statements in its body do not have matching underlying types
func makeShape(size: Int, vertextCount: Int) -> some Shape {
    if vertextCount == 3 { return Triangle(size: size) }
    else { return Square(size: size) }
}
```
  
**makeShape(size:vertexCount:)** 함수는 꼭지점의 개수에 따라 서로 다른 실제 타입(도형)을 반환합니다. 불투명한 타입은 실제 타입을 더 강력하게 제한하기 때문에, Swift 컴파일러는 이를 허용하지 않습니다.
  
하나의 실제 타입만을 취급한다는 건 타입의 정체성(identity)을 보존할 수 있는 여지가 있다는 의미입니다. 자세한 설명은 아래 **불투명한 타입과 박스형 프로토콜 타입의 차이** 를 참조하세요.
 
    
## 박스형 프로토콜 타입

Swift 5.7에 새롭게 등장한 박스형 프로토콜 타입은 프로토콜을 준수하는 다양한 타입을 추상화합니다. 프로토콜이 타입으로 사용될 때, 해당 타입을 **존재 타입(existential type)** 이라고 부릅니다. 
  
{{< figure src="../image.png" width="650px" align="center" >}}
  
프로토콜을 준수하는 실제 타입은 상자(box)라고 불리는 컨테이너(container)에 넣어, 실제 타입의 구체적인 정보를 숨깁니다. 이렇게 숨겨진 타입은 오직 프로토콜에 정의된 인터페이스만을 외부에 노출시키며, 이를 **타입 제거(type erasure)** 라고 합니다.
  
프로토콜 앞에 **any** 키워드를 붙여 박스형 프로토콜 타입으로 만들 수 있습니다. 아래 예제는 박스형 프로토콜 타입 배열을 저장하는 프로퍼티를 보여줍니다.

```swift
var shapes: [any Shape] = [Triangle(size: 2), Square(size: 3), Triangle(size: 4)]
```

### 존재 타입임을 명시
  
```swift
let triangle: Shape = Triangle()   // 타입으로 프로토콜
let triangle: any Shape = Circle() // 존재 타입
```
  
프로토콜이 타입으로 사용될 때, 해당 타입을 존재 타입이라고 부릅니다. 존재 타입이라는 표현은 사실 Swift 5.7 이전에 **타입으로 프로토콜**을 사용하는 것과 동일합니다. 하지만 **any** 키워드로 프로토콜 타입을 존재 타입이라고 명시하지 않더라도 그다지 문제는 없어보이는데, 왜 해당 키워드가 도입되었을까요? 
  
존재 타입은 정적 타입(static type)이 같으나, 동적 타입(dynamic type)은 서로 다를 수 있습니다. 이는 런타임 중 어떤 실제 타입이 사용될지 결정되며, 이로 인해 성능 비용이 높아질 수 있습니다. 그럼에도 불구하고 이를 개발자에게 표면적으로 알려줄 수 있는 키워드가 없었기 때문에 등장하게 되었습니다.
  
아래 예제에서 **refuel(_:)** 함수의 매개변수 타입은 **Vehicle**입니다. 하지만 해당 타입이 해당 프로토콜을 준수하는 객체를 전달해야 하는지, 아니면 구조체를 전달해야 하는지 명확히 구분되지 않습니다. 
  
```swift
func refuel(_ vehicle: Vehicle) { ... }
```

**any** 키워드는 해당 프로토콜을 존재 타입으로 취급하겠다는 사실을 개발자와 컴파일러에게 알려주는 역할을 합니다. 그러므로 Swift 5.7부터 타입으로 프로토콜이라는 개념은 존재 타입으로 대체되었다고 볼 수 있습니다.

> **🟡 Important**
> Swift 6.0부터 모든 존재 타입에 **any** 키워드가 강제됩니다.
  

### 여러 실제 타입을 동시에 취급

박스형 프로토콜 타입은 여러 실제 타입을 동시에 취급할 수 있습니다. 예를 들어, 박스형 프로토콜 반환 타입을 가지는 함수나 메서드는 여러 실제 타입을 동시에 반환할 수 있습니다. 아래 예제는 이를 보여주고 있습니다.
  
```swift
func makeShape(size: Int, vertextCount: Int) -> any Shape {
    if vertextCount == 3 { return Triangle(size: size) }
    else { return Square(size: size) }
}
```
  
**makeShape(size:vertexCount:)** 함수는 꼭지점의 개수에 따라 서로 다른 실제 타입의 도형을 반환합니다. 박스형 프로토콜 타입은 이러한 유연성을 허용합니다.
  
여러 실제 타입을 동시에 취급한다는 건 타입을 깊게 추상화한다는 의미이고, 이는 타입의 정체성을 보존할 수 없다는 걸 시사합니다. 자세한 설명은 아래 **불투명한 타입과 박스형 프로토콜 타입의 차이**를 참조하세요. 
    
## 불투명한 타입과 박스형 프로토콜 타입의 차이
  
프로토콜을 준수하는 객체를 취급한다는 점에서 불투명한 타입과 박스형 프로토콜 타입의 차이는 없어 보입니다. 하지만, Swift 컴파일러가 해당 타입을 처리하는 내부 방식에는 큰 차이가 있으며, 이는 성능에도 큰 영향을 끼칩니다. 따라서 이러한 차이를 정확히 이해하고 적재적소에 적용할 필요가 있습니다.

### 타입 정체성 보존

불투명한 타입은 타입 정체성을 보존합니다. 반면에, 박스형 프로토콜 타입은 타입 정체성을 보존하지 않습니다.
  
타입 정체성을 보존한다는 건 프로토콜을 준수하는 실제 타입에 대한 자세한 정보를 숨기더라도 Swift 컴파일러가 **Self**나 연관된 타입을 추론할 수 있다는 의미입니다. 아래 예제는 서로 다른 **ToyBox** 객체가 서로 동일한지 확인하는 모습을 보여줍니다.
  
```swift
protocol Box: Equatable {
    associatedtype Item: Numeric
    var item: Item { get set }
    func get() -> Item
}
extension Box {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.item == rhs.item
    }
}

struct ToyBox: Box {
    var item: Int
    func get() -> Int {
        item
    }
}

func makeToyBox(_ item: Int) -> any Box {
    ToyBox(item: item)
}

let box1 = makeToyBox(10)
let box2 = makeToyBox(20)

// 🔴 Error: Binary operator '==' cannot be applied to two 'any Box' operands
print(box1 == box2) 
```

**makeToyBox(_:)** 함수는 박스형 프로토콜 반환 타입으로 **Box** 타입을 반환하고 있습니다. 이는 **==(lhs:rhs:)** 정적 메서드의 매개변수 타입인 **Self**를 참조할 수 없다는 의미입니다. 타입 정체성이 보존되는 않는 타입에서는 **==** 연산자를 사용할 수 없다는 걸 보여주고 있습니다.
  
반면에, **makeToyBox(_ item:)** 메서드가 불투명한 반환 타입으로 **Box** 타입을 반환한다면, 타입 정체성이 보존되므로 **==** 연산자를 사용할 수 있습니다.
  
```swift
func makeToyBox(_ item: Int) -> some Box { // ✅
    ToyBox(item: item)
}
```


### 정적과 동적 디스패치 동작

불투명한 반환 타입은 한번에 하나의 실제 타입만을 취급하며, 그 타입을 제한합니다. 이 덕분에 컴파일러는 어떤 실제 타입을 반환할 지 컴파일 시간에 미리 알 수 있으며, 성능 비용을 낮춥니다. 불투명한 반환 타입은 **정적 디스패치(static dispatch)**에서 동작합니다.
  
반면에, 박스형 프로토콜 타입(존재 타입)은 여러 실제 타입을 동시에 취급하며, 이 타입을 추상화합니다. 그러나 존재 타입은 정적 타입(static type)이 같으나, 동적 타입(dynamic type)은 서로 다를 수 있습니다. 이는 런타임 중 어떤 실제 타입이 사용될지 결정되며, 이로 인해 성능 비용을 높아질 수 있습니다. 박스형 프로토콜 타입은 **동적 디스패치(dynamic dispatch)**에서 동작합니다.

## 결론

불투명한 타입은 프로토콜을 준수하는 실제 타입에 대한 자세한 정보를 외부에 드러내지 않습니다. **Self**를 참조하거나 연관된 타입을 추론하는 게 가능하며, 해당 타입의 정체성을 보존합니다. 그리고 정적 디스패치로 동작하기에 성능 비용을 낮춥니다.
  
박스형 프로토콜 타입은 프로토콜을 준수하는 다양한 타입을 추상화합니다. 프로토콜이 타입으로 사용될 때, 해당 타입을 존재타입이라 부릅니다. 그리고 동적 디스패치로 동작하기에 성능 비용이 높아질 수 있습니다.
  
그렇다면 두 타입은 언제 어떻게 사용해야 할까요? 프로그래밍에서는 개발자가 예측 가능한 프로그래밍을 해야 유지보수가 용이해지며, 버그 발생 가능성이 줄어듭니다. 추상화 수준을 높이면 코드의 유연성은 증가하지만, 그만큼 예측 가능성은 떨어집니다. 
  
이러한 이유로, 불투명한 타입을 적극적으로 활용하세요. 불투명한 타입은 실제 타입에 대한 자세한 정보를 외부에 드러내지 않지만, 컴파일러는 여전히 해당 타입을 식별할 수 있으므로, 타입 안전성을 유지하며 예측 가능한 코드 작성이 가능해집니다.
  
## 참고 자료
  
* [Opaque Types in Swift](https://protocorn93.github.io/tags/some/)
  
* [Opaue Types](https://wlaxhrl.tistory.com/82)
  
* [불투명한 타입 (Opaque Types)](https://bbiguduk.gitbook.io/swift/language-guide-1/opaque-types#differences-between-opaque-types-and-boxed-protocol-types)
  
* [Opaque Type vs Protocol Type](https://eunjin3786.tistory.com/490)

* [Swift 5.6의 Existential any](https://sujinnaljin.medium.com/swift-swift-5-6-의-existential-any-ef0ce6bc7bc2)
  
* [Type Erasure 이해하기](https://ios-development.tistory.com/1286)