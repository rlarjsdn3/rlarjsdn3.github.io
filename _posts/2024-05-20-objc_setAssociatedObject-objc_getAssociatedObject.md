---
title: "objc_setAssociatedObject, objc_getAssociatedObject"
date: 2024-05-25 22:00:00 + 0900
categories: [개발 일기, Swift]
tags: [swift]
image: /assets/img/20231202/1.png
---

## AssocidatedObject

 `AssociatedObject`는 객체(Object)에 연관된 객체를 저장할 때 사용됩니다. 키(Key)-값(Value) 쌍으로 연관된 객체를 저장하며, 키를 통해 연관된 객체에 접근하거나 삭제할 수 있습니다. `AssocidatedObject`는 클래스(Class)를 상속하지 않더라도 확장을 통해 프로퍼티(Property) 등 속성을 추가로 정의하도록 도와줍니다. 그리고 프로토콜(Protocol) 기본 구현을 통해 계산 프로퍼티(Computed Property)의 기능을 미리 정의할 수도 있습니다.

아래 표는 `AssocidatedObject`를 처리하는 메서드를 보여줍니다.

| :-- | :-- |
| objc_setAssociatedObject(_:_:_:_:) | 이 메서드는 주어진 키로 `Any` 타입의 객체를 저장합니다. <br> 첫 번째 매개변수로 연관된 객체를 저장하려는 기존 객체를 전달해야 합니다. <br> 두 번째 매개변수로 연관된 객체를 가져오거나 삭제할 때 사용되는 고유 키를 `UnsafeRawPointer` 타입의 객체로 전달해야 합니다. <br> 세 번째 매개변수로 저장하려는 연관된 객체를 전달해야 합니다. <br> 네 번째 매개변수로 연관된 객체의 메모리 관리 정책을 전달해야 합니다. |
| objc_getAssociatedObject(_:_:) | 이 메서드는 주어진 키로 `Any?` 타입의 객체를 반환합니다. <br> 첫 번째 매개변수로 연관된 객체를 가져오고자 하는 기존 객체를 전달해야 합니다. <br> 두 번째 매개변수는 가져오고자 하는 연관된 객체의 키를 전달해야 합니다. |
| objc_remoteAssociatedObject(_:) | 이 메서드는 객체에 유지하는 연관된 객체를 삭제합니다. <br> 첫 번째 매개변수로 연관된 객체를 삭제하려는 기존 객체를 전달해야 합니다. |

연관된 객체를 저장할 때 메모리 관리 방식에 대한 정책(Policy)을 결정할 수 있습니다. 

| :--: | :-- |
| `OBJC_ASSOCIATION_ASSIGN` | |
| `OBJC_ASSOCIATION_RETAIN_NONATOMIC` | | 
| `OBJC_ASSOCIATION_COPY_NONATOMIC` | |
| `OBJC_ASSOCIATION_RETAIN` | |
| `OBJC_ASSOCIATION_COPY`| | 



OBJC_ASSOCIATION_ASSIGN: 연결된 객체를 assign(할당)합니다. 이는 연결된 객체의 라이프사이클을 관리하지 않습니다. 만약 연결된 객체가 메모리에서 해제되면, 연결된 객체에 대한 참조는 nil이 됩니다. 이는 보통 기본적인 숫자나 구조체와 같은 원시 데이터 타입에 사용됩니다.

OBJC_ASSOCIATION_RETAIN_NONATOMIC: 연결된 객체를 retain(보유)합니다. 이는 연결된 객체의 라이프사이클을 관리합니다. 연결된 객체의 retain count가 1 증가하며, 이는 해당 객체가 메모리에서 해제되지 않도록 보장합니다. 이 옵션은 멀티스레드 환경에서 atomic이 아니기 때문에 조심해서 사용해야 합니다.

OBJC_ASSOCIATION_COPY_NONATOMIC: 연결된 객체를 복사(copy)합니다. 이는 연결된 객체를 복사하여 새로운 객체를 생성하고, 그 새로운 객체에 대한 참조를 유지합니다. 이 옵션은 멀티스레드 환경에서 atomic이 아니기 때문에 조심해서 사용해야 합니다.

OBJC_ASSOCIATION_RETAIN: 연결된 객체를 retain(보유)합니다. 이 옵션은 OBJC_ASSOCIATION_RETAIN_NONATOMIC와 비슷하지만, atomic한 속성을 가집니다. 멀티스레드 환경에서 안전하게 사용할 수 있습니다.

OBJC_ASSOCIATION_COPY: 연결된 객체를 복사(copy)합니다. 이 옵션은 OBJC_ASSOCIATION_COPY_NONATOMIC와 비슷하지만, atomic한 속성을 가집니다. 멀티스레드 환경에서 안전하게 사용할 수 있습니다.


> **`Atomic` vs. `Non-Atomic`** <br>
> * `atomic` 속성은 멀티쓰레드 환경에서 일관성을 보장합니다. 여러 쓰레드가 동시에 해당 속성에 접근하려고 할 때, 하나의 쓰레드만 접근하도록 통제합니다. 이는 데이터에 대한 안전한 접근을 보장하지만, 성능은 더 낮습니다. <br>
> * `non-atomic` 속성은 멀티쓰레드 환경에서 일관성을 보장하지 않습니다. 여러 쓰레드가 해당 속성에 동시에 접근할 수 있으며, 하나의 쓰레드가 값을 가져오는 동안 다른 쓰레드가 값을 변경할 수도 있습니다. 이는 멀티쓰레드 환경에서 안전성을 떨어뜨리지만, 성능은 더 높습니다.
{: .prompt-tip }



## 언제 사용하나요?

 프로토콜(Protocol)에서 프로퍼티 기본 구현(Default Implementation)을   프로토콜 기본 구현(Default Implementation) 시 계산 프로퍼티(Computed Property)

AssociatedObject는 런타임시 기존 클래스에 SubClassing 없이 사용자 정의 속성을 연결(추가) 할 수 있습니다.

key-value 쌍으로 특정 값을 저장하여 사용
extension에서는 stored property를 지정하지 못하지만, 이 AssociatedObject를 사용하면 stored property처럼 따로 프로퍼티를 추가하고 접근도 가능







// 연관된 오브젝트에 대한 약한 참조를 지정합니다.
OBJC_ASSOCIATION_ASSIGN  

// 연관된 오브젝트가 복사되고 ATOMIC으로 설정합니다.
OBJC_ASSOCIATION_COPY  

// 연관된 오브젝트가 복사되고 NONATOMIC으로 설정합니다.
OBJC_ASSOCIATION_COPY_NONATOMIC  

// 연관된 오브젝트에 대한 강력한 참조를 지정하고 ATOMIC으로 설정합니다.
OBJC_ASSOCIATION_RETAIN  

// 연관된 오브젝트에 대한 강력한 참조를 지정하고 NONATOMIC으로 설정합니다.
OBJC_ASSOCIATION_RETAIN_NONATOMIC  


## 참고 자료

* [Swift에서 AssociatedObject를 사용해 보아요](https://lidium.tistory.com/54)

* [Associated Objects로 Delegate에서 Closure로 바꾸기](http://minsone.github.io/mac/ios/how-to-covert-delegate-to-closure-from-uialertview-using-associated-objects)

* [objc_getAssociatedObject, objc_setAssociatedObject 사용 방법](https://ios-development.tistory.com/1204)

* [Extension에 Stored Property 추가 방법 (objc_getAssociatedObject, objc_setAssociatedObject)](https://ios-development.tistory.com/1249)

* []()