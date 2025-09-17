---
date: '2024-11-05T22:34:21+09:00'
draft: false
title: "[번역] The Nested Closure Trap (Besher AI Maleh)"
description: ""
tags: ["Closure", "Capture List", "[Weak self]"]
categories: ["Articles"]
cover:
    image: cover.webp
    hiddenInList: false
---

_DispatchWorkItem_ 내부에 중첩된 애니메이션 클로저를 실행하는 코드가 있다고 가정해보겠습니다.

여기 세 가지 버전의 코드가 있습니다. 어느 코드가 순환 참조(retained cycle)를 유발하는지 말해주실 수 있나요?

```swift
class ViewControllerA: UIViewController {
	
    var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
    	let workItem = DispatchWorkItem {
        	UIView.animate(withDuration: 1.0) {
            	self.view.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }
    
}
```

```swift
class ViewControllerB: UIViewController {

	var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
    	let view = self.view
        let workItem = DispatchWorkItem {
        	UIView.animte(withDuration: 1.0) { [weak self] in
            	view?.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }

}
```

```swift
class ViewControllerC: UIViewController {

	var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
   		let workItem = DispatchWorkItem {
        	UIView.animate(withDuration: 1.0) { [weak self] in
            	self?.view.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }

}
```

정답은 세 가지 버전 모두입니다! 심지어 클로저 바깥에서 _view_에 대한 참조를 생성하는 버전 B도 순환 참조를 유발합니다.

[이전 글에서](https://medium.com/flawless-app-stories/you-dont-always-need-weak-self-a778bec505ef), `[weak self]`에 대해 자세하게 탐구하고 항상 필요로 하지 않는다는 사실을 다뤘습니다. 그러나 다중으로 중첩된 클로저가 있는 경우는 다루지 않았습니다.

아마도 중첩된 클로저를 사용하다가 순환 참조를 방지하기 위해 `[weak self]`를 사용해야 하는 상황을 경험했을 겁니다. 이 상황에서, 중첩된 클로저 각각에서 `[weak self]`를 사용해야 할까요? 아니며 가장 안쪽이나 바깥쪽 클로저에만 `[weak self]`를 사용해야 할까요?

다시 위의 예제로 되돌아가서 두 개의 서로 다른 클로저를 살펴보겠습니다.

```swift
let workItem = DispatchWorkItem { // <-- first closure
	UIView.animate(withDuration: 1.0) { // <-- second closure
    	self.view.backgroundColor = .red
    }
self.workItem = workItem
```

처음 추정하기로는 `[weak self]`를 가장 안쪽의 _UIView.animate_ 클로저에 붙여야 한다고 생각했습니다. 결국에는, 해당 클로저가 `self`를 사용하여 _view_ 프로퍼티에 접근하고 있으므로, 해당 클로저에 `[weak self]`를 사용하는 게 합리적으로 보입니다. 그렇죠?

이는 순환 참조를 유발하며, `[weak self]`를 _Dispatch Work Item_ 클로저로, 즉 한 단계 위로 옮겨야 합니다.

이 예제의 _work Item_ 프로퍼티는 관심 있는 클로저(closure of interest)를 포함하며, `self`는 _work Item_ 클로저에 대해 강한 참조를 가집니다(6번째 줄: `self.workItem = workItem`). 반면에, 클로저도 마찬가지로 `self`에 대한 강한 참조를 가집니다.

`self`에 대한 강한 참조는 중첩된 클로저 내부에서 `[weak self]` 표현을 사용하여 `self`를 참조하는 버전 B에서도 동일하게 일어납니다. 단순히 `[weak self]`를 추가하는 것만으로도 의도치 않게 `self`에 대한 강한 참조가 생성되어 순환 참조로 이어지게 되었습니다.

```swift
class ViewControllerB: UIViewController {

	var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
    	let view = self.view
        let workItem = DispatchWorkItem {
        	UIView.animte(withDuration: 1.0) { [weak self] in // this leaks
            	view?.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }

}
```

## Conclusion

중첩된 클로저 중 어느 하나가 `[weak self]`를 필요로 한다면([이전 글에서 나온 다이어그램에 따라](https://miro.medium.com/v2/resize:fit:3080/1*yHX-8dJrQpH7R2hfM_21MQ.png)), 관심 있는 해당 클로저의 레벨(또는 그보다 상위 레벨)에 `[weak self]`를 추가하세요. 하위 레벨에 `[weak self]`를 추가하면, 메모리 누수가 발생합니다.

아래는 순환 참조가 없는 예제입니다.

```swift
let workItem - DispatchWorkItem { [weak self] in
	UIView.animte(withDuration: 1.0) {
    	self?.view.backgroundColor = .red
    }
}
self.workItem = workItem
```

대안으로, (버전 B처럼) 클로저 외부에서 _view_에 대한 참조를 생성하여 `[weak self]`를 사용하는 걸 피할 수 있습니다.

```swift
let view = self.view
let workItem = DispatchWorkItem {
	UIView.animate(withDuration: 1.0) { // adding [weak self] here will introduce a cycle
    	view?.backgroundColor = .red
    }
}
```

중첩된 클로저를 다루는 추가 예제를 포함하는 _weak self_ 앱을 업데이트했습니다. [여기](https://github.com/almaleh/weak-self)에서 앱을 다운로드할 수 있습니다.

이 글은 여기까지입니다. 꽤 짧은 글이었죠! 아직 보지 않으셨다면 [[weak self]에 대해 더 깊게 다룬 글](https://medium.com/flawless-app-stories/you-dont-always-need-weak-self-a778bec505ef)도 확인해보세요. 항상 그렇듯이, 의견이 있으시면 여기나 Twitter로 알려주세요!





