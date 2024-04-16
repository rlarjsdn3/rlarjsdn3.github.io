---
title: "objc_setAssociatedObject, objc_getAssociatedObject"
date: 2024-04-10 22:00:00 + 0900
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
| objc_removeAssociatedObject(_:) | 이 메서드는 객체에 유지하는 연관된 객체를 삭제합니다. <br> 첫 번째 매개변수로 연관된 객체를 삭제하려는 기존 객체를 전달해야 합니다. |

연관된 객체를 저장할 때 메모리 관리 방식에 대한 정책(Policy)을 결정할 수 있습니다. 메모리 관리 정책은 Objective-C의 개념을 따릅니다.

| :--: | :-- |
| `OBJC_ASSOCIATION_ASSIGN` | ■ 연관된 객체를 할당(Assign)합니다. 연관된 객체를 약하게 참조(unowned)하며, 메모리에서 해제(nil)되면 여전히 해제된 객체를 참조하므로 주의해야 합니다.  |
| `OBJC_ASSOCIATION_RETAIN_NONATOMIC` | ■ 연관된 객체를 보유(Retain)합니다. 연관된 객체를 강하게 참조(strong)하며, 참조 횟수를 1 증가시킵니다. 멀티 쓰레드 환경에서 일관성을 보장하지 않습니다. | 
| `OBJC_ASSOCIATION_RETAIN` | ■ 연관된 객체를 보유(Retain)합니다. 이 옵션은 `OBJC_ASSOCIATION_RETAIN_NONATOMIC`과 유사합니다. 멀티 쓰레드 환경에서 일관성을 보장합니다. | 
| `OBJC_ASSOCIATION_COPY_NONATOMIC` | ■ 연관된 객체를 복사(Copy)합니다. 연관된 객체를 복사하여 새로운 객체를 생성하고, 그 새로운 객체를 참조합니다. 멀티 쓰레드 환경에서 일관성을 보장하지 않습니다.   |
| `OBJC_ASSOCIATION_COPY`| ■ 연관된 객체를 복사(Copy)합니다. 이 옵션은 `OBJC_ASSOCIATION_COPY_NONATOMIC`과 유사합니다. 멀티 쓰레드 환경에서 일관성을 보장합니다. | 

> **`Assign` vs. `Retain`** <br>
> * 이는 Objective-C의 개념입니다. Swift는 메모리를 ARC(Automatic Reference Counting)로 객체의 참조 횟수를 추적하여 관리하므로 `Assign`과 `Retain`의 개념이 존재하지 않습니다.
> * `Assign(할당)`은 Swift의 `unowned` 참조와 유사합니다. 객체를 참조할 때 참조 카운트(Reference Count)를 증가시키지 않지만, 참조하던 객체가 해제(nil)되는 경우, 여전히 해제된 객체를 참조하므로 주의해야 합니다.
> * `Retain(보유)`는 Swift의 `strong` 참조와 유사합니다. 객체를 참조할 때 참조 카운트가 증가합니다. 
{: .prompt-tip }

> **`Atomic` vs. `Non-Atomic`** <br>
> * `atomic` 속성은 멀티쓰레드 환경에서 일관성을 보장합니다. 여러 쓰레드가 동시에 해당 속성에 접근하려고 할 때, 하나의 쓰레드만 접근하도록 통제합니다. 이는 데이터에 대한 안전한 접근을 보장하지만, 성능이 낮아집니다. <br>
> * `non-atomic` 속성은 멀티쓰레드 환경에서 일관성을 보장하지 않습니다. 여러 쓰레드가 해당 속성에 동시에 접근할 수 있으며, 하나의 쓰레드가 값을 가져오는 동안 다른 쓰레드가 값을 변경할 수도 있습니다. 이는 멀티쓰레드 환경에서 안전성을 떨어뜨리지만, 성능을 높입니다. <br>
> * Swift는 쓰레드 안전(Thread-Safe)을 고려하지 않으므로 프로퍼티가 `non-atomic`하게 동작합니다.
{: .prompt-tip }

## 언제 사용하나요?

최근 유용하게 적용한 예제가 바로 [RxMVVM](https://github.com/rlarjsdn3/ex-rxmvvm-uikit-project/blob/main/ExRxMVVM/ExRxMVVM/Views/GitViewController.swift) 디자인 패턴을 연습할 때였습니다. 

구현 목표 중 하나가 뷰 컨트롤러의 이니셜라이저에 `ViewModel`을 넘겨주면 `bind(viewModel:)` 메서드가 자동으로 호출되어 편리하게 바인딩(Binding)을 시켜주는 것이었습니다. 이를 위해 뷰 컨트롤러가 특정 프로퍼티나 메서드를 구현하도록 프로토콜 요구 사항 정의를 해주었으며, 프로토콜 기본 구현을 통해 목표를 달성하고자 하였습니다. 그런데, 한 가지 걸림돌은 **확장에 저장 프로퍼티(Stored Property) 구현이 안된다**는 점이었습니다. 어쩔 수 없이 계산 프로퍼티의 getter와 setter를 홯용했는데, 여기서 문제가 발생하였습니다.

```swift
// ViewControllerType.swfit

protocol ViewControllerType: AnyObject {
    associatedtype ViewModel: ViewModelType
    
    var viewModel: ViewModel? { get set }
    var disposeBag: DisposeBag { get set }
    
    func bind(viewModel: ViewModel)
}

extension ViewControllerType {
    var viewModel: ViewModel? {
        get {
            self.viewModel // 재귀 호출이 일어나는 원인 코드
        }
        set {
            disposeBag = DisposeBag()
            if let vm = newValue {
                bind(viewModel: vm)
            }
        }
    }
}

```

문제가 보이시나요? 바로 `viewModel` 프로퍼티에 접근할 때, 계산 프로퍼티의 getter에서 재귀 호출(Recursive Call)이 발생한다는 점입니다. 뷰 컨트롤러에서 `viewModel` 계산 프로퍼티의 값을 가져오려고(getter) 할 때, 다시 동일한 계산 프로퍼티의 getter가 무한정 처음부터 불리게 됩니다. 이 문제를 피하기 위해 계산 프로퍼티는 자기 자신에게 접근하면 안됩니다. 

```swift
// ViewControllerType.swfit

extension ViewControllerType {
    private var underlyingViewModel: ViewModel? {
        get {
            return objc_getAssociatedObject(
                self,
                &AssociatedKeys.viewModel
            ) as? ViewModel
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.viewModel,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    var viewModel: ViewModel? {
        get {
            guard let viewModel = underlyingViewModel else {
                fatalError("ViewModel has not been set")
            }
            return viewModel
        }
        set {
            disposeBag = DisposeBag()
            if let vm = newValue {
                bind(viewModel: vm)
            }
            underlyingViewModel = newValue
        }
    }
}
```

이 문제를 해결하기 위해 계산 프로퍼티가 다른 프로퍼티에 접근하도록 해야 합니다. 그런데 확장에는 저장 프로퍼티를 정의할 수 없죠? 그래서 `AssociatedObject`를 저장하는 `underlyingViewModel` 계산 프로퍼티를 따로 정의해두고, `viewModel`이 해당 프로퍼티를 통해 객체를 불러오게(getter) 구현하면 됩니다. 반대로 `viewModel` 프로퍼티에 새로운 객체를 할당할 때는 `underlyingViewModel` 계산 프로퍼티를 통해 새로운 객체를 `AssociatedObject`에 저장하도록(setter) 구현하면 됩니다. 

이렇듯, `AssocidatedObject`는 별도 클래스를 정의하지 않고도 확장에서 계산 프로퍼티를 저장 프로퍼티로 사용하게 도와줍니다.

## 참고 자료

* [Swift에서 AssociatedObject를 사용해 보아요](https://lidium.tistory.com/54)

* [Associated Objects로 Delegate에서 Closure로 바꾸기](http://minsone.github.io/mac/ios/how-to-covert-delegate-to-closure-from-uialertview-using-associated-objects)

* [objc_getAssociatedObject, objc_setAssociatedObject 사용 방법](https://ios-development.tistory.com/1204)

* [Extension에 Stored Property 추가 방법 (objc_getAssociatedObject, objc_setAssociatedObject)](https://ios-development.tistory.com/1249)

* [속성(Attribute)](https://babbab2.tistory.com/75)