---
date: '2024-10-30T22:34:21+09:00'
draft: false
title: "[번역] You don't (always) need [weak self] (Besher AI Meleh)"
description: ""
tags: ["Closure", "Capture List", "[Weak self]"]
categories: ["Articles"]
cover:
    image: cover.webp
    hiddenInList: false
---

사이클.. 아니, 위 그림에 보이는 그런 사이클이 아닙니다. 강한 순환 참조(strong reference cycles)를 의미하며, iOS 앱에서 뷰 컨트롤러가 메모리 누수를 유발하는 원인이 됩니다. 더 구체적으로, 참조 사이클을 피하기 위해 Swift 클로저 내부에서 `[weak self]`의 사용법과 **self**를 약하게 캡처(capture)하는 게 필요하거나 필요없는 경우에 대해 살펴보고자 합니다.

이 글에서 다루는 주제는 애플 공식 문서, 다양한 [블로그](https://www.avanderlee.com/swift/weak-self/) [포스트](https://www.objc.io/blog/2018/04/03/caputure-lists/)와 [튜토리얼](https://www.swiftbysundell.com/articles/capturing-objects-in-swift-closures/)을 읽고, 시행착오와 실험을 통해 배웠습니다. 어딘가 실수가 있다고 생각이 되면, 자유롭게 댓글이나 [트위터](https://twitter.com/BesherMaleh)로 알려주세요.

또한, 메모리 누수가 일어나는 다양한 시나리오와 어디서 `[weak self]`를 불필요하게 사용하는지 보여주는 작은 앱도 첨부합니다.

[almaleg/weak-self](https://github.com/almaleh/weak-self?source=post_page-----a778bec505ef--------------------------------)

## Automatic Reference Counting

Swift에서 메모리 관리는 [ARC(Automatic Reference Counting)](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/)로 처리되며, 더 이상 필요로 하지 않는 클래스 인스턴스가 점유한 메모리 공간을 자동으로 해제합니다. ARC는 대부분 자동으로 작동하지만, 가끔 객체 간 관계를 명확하게 해주어야 한다면 추가 정보를 제공해야 할 수도 있습니다.

예를 들어, 프로퍼티에 상위 뷰 컨트롤러의 참조를 저장하는 하위 뷰 컨트롤러가 있다면, 해당 프로퍼티는 순환 참조를 막기 위해 `weak` 키워드를 붙일 필요가 있습니다.

메모리 누수가 의심된다면:

* 객체가 해제된 후 [디이니셜라이저 콜백(deinitializer callback)](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/deinitialization/) 호출을 확인하세요. 해당 콜백이 호출되지 않는다면, 메모리 누수가 발생한 겁니다.

* 옵셔널 객체가 있다면, 해제된 후에 해당 객체가 nil인지 확인하세요.

* 앱의 메모리 사용량이 가파르게 증가하는지 확인하세요.

* 누수와 할당 인스트루먼트(instruments)를 사용하세요.

클로저와 관련하여, 아래 코드를 살펴봅시다.

```swift
let changeColorToRed = DispatchWorkItem { [weak self] in
	self?.view.backgroundColor = .red
}
```

이 클로저에서 `self`가 약하게 캡처되었고, 이후 `self`가 클로저의 본문에서 옵셔널로 변환되었습니다.

여기서 정말로 `[weak self]`가 필요할까요? 사용하지 않는다면, 메모리 누수가 발생할까요? 🤔

곧 알게 되겠지만, "상황에 따라 다르다"입니다. 먼저 간단한 배경에 대해 설명드리겠습니다.

## Unowned, Weak, and the Strong-Weak Dance

클로저는 정의된 문맥(context)에서 상수나 변수를 강하게 캡처하거나 포착할 수 있습니다. 예를 들어, 클로저 내부에 `self`를 사용하면, 클로저 범위는 _범위의 생명주기_ 동안 `self`에 대한 강한 참조를 유지합니다. 

또한, `self`가 (미래의 어느 시점에 이 클로저를 호출하기 위해) 해당 클로저에 대한 참조를 유지한다면, 강한 순환 참조가 발생하게 됩니다.

다행히도, 이러한 순환 참조를 피하게 해주는 `unowned`와 `weak` 키워드와 같은 도구(아래에서 다룰 다른 도구에 더해)가 있습니다.

제가 Swift를 처음 배울 당시, 모든 클로저에 `[unowned self]`를 붙였습니다. 나중에(그리고 여러번의 크래시를 겪고 나서야😅), 이것이 `self`를 강제 언래핑하는 것과 동일하며, 해제된 후에도 해당 컨텐츠에 접근하려고 시도한다는 걸 발견했습니다. 다르게 말하면, 이것은 매우 안전하지 않은 방식입니다! 

`[weak self]`는 더 안전한 방식으로 (참조 사이클을 방지하는) 동일한 작업을 수행하며, 이 과정에서 `self`를 옵셔널로 변환합니다. 이 옵셔널을 처리하려면, `self?.`를 접두사로 붙여 옵셔널 체이닝으로 호출할 수 있습니다. 그러나, 더 보편적인 접근법은 클로저의 시작 부분에 `guard let` 구문을 사용하여 `self`에 대한 일시적인 강한 참조를 생성하는 겁니다.

Swift 언어의 초기 버전에서는, 아래 코드처럼 `self`를 일시적인 비-옵셔널 상수인 `strongSelf`에 할당하는, 이른바 Strong-Weak 댄스라 알려진 방식이 일반적이었습니다.

```swift
let changeColorToRed = DispatchWorkItem { [weak self] in 
	guard let strongSelf = self else { return }
    strongSelf.view.backgroundColor = .red
}
```

그리고, 나중에, 사람들은 코드를 더 단순하게 만들고자 역따옴표(`)를 활용하여 컴파일러 버그를 사용(또는 악용😛)하기 시작했습니다.

```swift
let changeColorToRed = DispatchWorkItem { [weak self] in
	guard let `self` = self else { return }
    self.view.backgroundColor = .red
}
```

결국 Swift 4.2에서, `guard let self = self` 구문에 대한 공식적인 지원이 추가되면서, 아래와 같은 코드가 가능해졌습니다.

```swift
let changeColorToRed = DispatchWorkItem { [weak self] in 
	guard let self = self else { return }
    self.view.backgroundColor = .red
}
```

[Erica Sadun](https://twitter.com/ericasadun)은 그녀의 저서 [Swift Style, Second Edition](https://pragprog.com/search/?q=s)에서 `guard let self = self` 패턴을 지지했으며, 이 패턴을 안전하게 사용할 수 있다고 생각합니다😃

옵셔널 처리를 피하기 위해 `weak`보다 `unowned`를 사용하는 경향이 있으나, 일반적인 상황에서는 클로저가 실행되는 동안 절대로 참조가 nil이 될 수 없다고 확신할 수 있을 때만 `unowned`를 제한적으로 사용하세요. 다시 강조하면, `unowned`는 옵셔널 강제 언래핑이라서, nil이 되면 크래시가 발생합니다. `[weak self]`가 더 안전한 대안입니다.

아래 그림은`unowned`에 의해 유발된 크래시를 보여줍니다:

{{< figure src="weak-self-1.webp" width="650px" align="center" >}}

이제 `[weak self]`의 이점을 알았으니, 모든 클로저에서 이를 사용해야 한다는 의미일까요?

한동안 저는 거의 이런 상태였죠:

{{< figure src="weak-self-2.webp" width="350px" align="center" >}}

그러나 결국, 정말로 필요하지 않는 많은 코드에서 불필요한 옵셔널 처리를 도입하고 있었습니다. 그 이유는 제가 다루는 클로저의 특성에 있었습니다.


## Escaping vs non-escaping closures

클로저에는 비-탈출 클로저와 탈출 클로저라는 두 가지 종류가 있습니다. 비-탈출 클로저는 해당 범위에서 실행됩니다. 코드를 즉시 실행하며, 다른 프로퍼티에 저장하거나 실행을 미룰 수 없습니다. 그 반면에, 탈출 클로저는 다른 프로퍼티에 저장되거나 다른 클로저로 전달될 수 있으며, 미래의 어느 시점에 실행될 수 있습니다.

**비-탈출 클로저**(compactMap과 같은 고차 함수처럼)는 순환 참조를 일으킬 위험이 없으므로, `weak`이나 `unonwed`의 사용이 필요하지 않습니다.

**탈출 클로저**는 `weak`이나 `unowned`를 사용하지 않으면 순환 참조를 일으킬 수 있으며, 아래 두 조건을 모두 충족하는 경우 발생합니다:

* 클로저가 프로퍼티에 저장되거나 다른 클로저에 전달되는 경우

* (`self`처럼) 클로저 내부의 객체가 해당 클로저(또는 해당 클로저에 전달된 다른 클로저)에 대한 강한 참조를 유지하고 있는 경우

아래 그림은 개념을 설명하기 위한 플로우 차트입니다:

{{< figure src="weak-self-3.webp" width="650px" align="center" >}}

{{< figure src="weak-self-4.jpeg" width="650px" align="center" >}}

## Delayed Deallocation

플로우 차트 왼쪽에서 할당 해제가 지연될 수 있다는 내용을 언급하는 상자를 주목하세요. 이는 탈출 클로저와 비-탈출 클로저 모두에서 발생할 수 있는 부수 효과(side effect)입니다. 엄밀히 말하면 메모리 누수는 아니지만, 예상치 못한 동작(e.g. 뷰 컨트롤러를 닫았지만, 클로저가 작업을 완료할 때까지 해당 뷰 컨트롤러가 메모리에서 해제되지 않는 상태)으로 이어질 수 있습니다.

클로저는 기본적으로 본문에서 참조되는 객체를 강하게 캡처하기에, 클로저 본문이 실행되는 동안, 해당 객체들이 메모리에서 사라지지 않게 방해한다는 의미입니다.

클로저 범위의 생명 주기는 짧게는 밀리초에서부터 길게는 몇 분이 될 수 있습니다.

클로저를 계속 실행시키게 하는 여러 시나리오가 있습니다:

1. 클로저(탈출 혹은 비-탈출)가 비용이 많이 드는 일련의 작업을 수행할 수 있으며, 이로 인해 모든 작업이 완료될 때까지 클로저의 소멸이 지연될 수 있습니다.

2. 클로저(탈출 혹은 비-탈출)는 ([DispatchSemaphore](https://developer.apple.com/documentation/dispatch/dispatchsemaphore)처럼) 쓰레드 블록킹 메커니즘을 필요로 할 수 있으며, 이로 인해 클로저의 소멸이 지연되거나 막힐 수 있습니다. 

3. 탈출 클로저는 일정 시간 지연 후에 실행되도록 할 수 있습니다. (e.g. `DispatchQueue.asyncAfter` 혹은 `UIViewPropertyAnimator.startAnimation(afterDelay:)`)

4. 탈출 클로저는 긴 타임아웃을 가진 콜백을 기다릴 수 있습니다. (e.g. URLSesion `timeoutIntervalForResource`)

아마도 제가 놓친 다른 경우가 있을 수 있지만, 적어도 어떤 일이 일어나는지 이해하는 데 도움이 될 겁니다. 아래 URLSession이 할당 해제를 지연시키는 걸 보여주는 [데모 앱](https://github.com/almaleh/weak-self)의 예제 코드가 있습니다.

```swift
func delayedAllocAsyncCall() {
    let url = URL(string: "https://www.google.com:81")!
    
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = 999.0
    sessionConfig.timeoutIntervalForResource = 999.0
    let session = URLSession(configuration: sessionConfig)
    
   	let task = session.downloadTask(with: url) { localURL, _, error in
    	guard let loadURL = loadURL else { return }
    	let contents = (try? String(contentsOf: localURL)) ?? "No contents"
    	print(contents)
    	print(self.view.description)
    }
    task.resume()
}
```

위 예제 코드를 한번 톺아봅시다:

* 타임아웃 요청을 시뮬레이션하기 위해 일부러 차단된 포트 81에 요청을 보냅니다.

* 요청은 999초 타임아웃 간격을 가집니다.

* `weak` 혹은 `unowned` 키워드가 사용되지 않습니다.

* 작업 클로저 내부에 `self`가 참조됩니다.

* 작업은 어디에도 저장되지 않으며, 즉시 실행됩니다.

위의 마지막 요점에 따르면, 이 작업은 강한 순환 참조를 유발하지 않습니다. 그러나, 위의 시나리오로 데모 앱을 실행하고, 다운로드 작업을 취소하지 않고 뷰 컨트롤러를 닫으면, 뷰 컨트롤러 메모리가 해제되지 않았다는 알림을 받게 됩니다.

**여기서 정확히 어떤 일이 일어나는 걸까요?**

우리는 앞서 언급한 목록의 시나리오 #4에 해당하는 상황에 직면한 겁니다. 즉, 긴 타임아웃 간격으로 설정한 탈출 클로저가 콜백을 기다리고 있는 상황입니다. 이 클로저는 그 안에서 참조되는 객체들(이 경우 self)에 대한 강한 참조를 유지하며, 이 참조는 클로저가 호출되거나 타임아웃에 도달하거나, 작업이 취소될 때까지 유지됩니다.

_(URLSession이 내부적으로 어떻게 동작하는지 확신할 수 없지만, 요청이 실행되거나, 취소 혹은 데드라인에 도달할 때까지 작업에 대한 강한 참조를 유지한다고 추측합니다.)_

여기서는 강한 순환 참조가 발생하지 않지만, 이 클로저는 필요로 하는 동안 `self`에 대한 참조를 유지하므로, 다운로드 작업이 여전히 진행 중인 상황에서 뷰 컨트롤러를 닫으면 잠재적으로 `self`의 할당 해제가 지연될 수 있습니다.

(옵셔널 체이닝이나 guard let 구문과 함께) `[weak self]`를 사용하면 `self`가 즉시 할당 해제되어 지연을 막을 수 있습니다. 그 반면에, `[unowned self]`를 사용하면 크래시가 발생합니다.


## `guard let self = self vs Optional Chaining`

`[weak self]`를 사용할 때, `self?.` 옵셔널 체이닝 구문을 사용하여 `self`에 접근하는 대신 `guard let self = self`를 사용하면 잠재적인 부작용(side effect)이 발생할 수 있습니다.

비용이 많이 드는 일련의 작업이나 세마포어와 같은 쓰레드 블록킹 메커니즘 때문에 할당 해제 지연이 일어날 수 있는 클로저(앞서 언급한 시나리오 #1과 #2)에서, 클로저 시작 부분에 `guard let self = self else { return }`을 사용하면 할당 해제가 지연될 수 있습니다.

이해를 돕기 위해, UIImage에 여러 비용이 많이 드는 작업을 수행하는 클로저가 있다고 가정해보겠습니다.

```swift
func process(image: UIImage, completion: @escaping (UIImage?) -> Void) {
	DispatchQueue.global(qos: .userInteractive).async { [weak self] in
    	guard let self = self else { return }
        // perform expensive sequential work on the image
        let rotated = self.rotate(image: image)
        let cropped = self.crop(image: rotated)
        let scaled = self.scale(image: cropped)
        let processedImage = self.filter(image: scaled)
        completion(processedImage)
    }
}
```

클로저의 시작 부분에 `guard let` 구문과 함께 `[weak self]`를 사용하고 있습니다. `guard let` 구문은 `self`가 `nil`인지 확인한 후, `nil`이 아니면 범위가 유지되는 동안 `self`에 대한 일시적인 강한 참조를 생성합니다.

비용이 많이 드는 작업(5번째 줄 이후)에 도달할 때쯤에는, 이미 `self`에 대한 강한 참조가 생성된 상태이므로, 클로저 범위가 끝날 때까지 `self`가 해제되지 않게 합니다. 다르게 말하면, `guard let`은 클로저가 실행되는 동안 `self`가 유지하는 걸 보장합니다.

`guard let` 구문을 사용하지 않고, `self?.`를 사용한 옵셔널 체이닝을 통해 `self`의 메서드에 접근하면, 클로저의 시작 부분에 강한 참조를 생성하는 대신 `self`에 대한 nil 검사가 모든 메서드 호출마다 이뤄집니다. 이는 클로저가 실행되는 도중 어느 시점에 `self`가 `nil`이 될 수 있다는 의미이며, 해당 메서드는 조용히 건너뛰고 다음 줄로 넘어가게 됩니다.

```swift
func process(image: UIImage, completion: @escaping (UIImage?) -> Void) {
	DispatchQueue.global(qos: .userInteractive).async { [weak self] in
    	// perform expensive sequential work on the image
        let rotated = self?.rotate(image: image)
        let cropped = self?.crop(image: rotated)
        let scaled = self?.scale(image: cropped)
        let processedImage = self?.filter(image: scaled)
        completion(processedImage)
    }
}
```

이 차이는 다소 미묘합니다. 뷰 컨트롤러가 해제된 후에도 불필요한 작업을 피하고자 할 때는 `self?.`를 사용한 옵셔널 체이닝이 유용합니다. 반면, 객체가 해제되기 전에 모든 작업이 완료되도록 보장해야 할 경우(예: 데이터 손상을 방지하기 위해)에는 `guard let`을 사용하여 강한 참조를 유지하는 것이 적절합니다.


## Examples

[데모 앱](https://github.com/almaleh/weak-self)의 예제 코드를 통해 `[weak self]`가 필요하거나 필요하지 않은 일반적인 상황을 살펴봅시다.

### Grand Central Dispatch

GCD 호출은 일반적으로 순환 참조의 위험이 없지만, 나중에 실행되도록 저장된 경우에는 위험이 있을 수 있습니다.

예를 들어, 이들 호출은 곧바로 실행되기에 `[weak self]`가 없더라도 메모리 누수를 유발하지 않습니다. 

```swift
func nonLeakyDispatchQueue() {
	DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    	self.view.backgroundColor = .red
    }
    
    DispatchQueue.main.async {
    	self.view.backgroundColor = .red
    }
    
    DispatchQueue.global(qos: .background).async {
    	print(self.navigationItem.description)
    }
}
```

그러나, 아래 DispatchWorkItem은 해당 객체를 로컬 프로퍼티에 저장하고, 클로저 내부에 `[weak self]` 키워드 없이 `self`를 참조하고 있기에 메모리 누수를 유발합니다.

```swift
func leakyDispatchQueue() {
	let workItem = DispatchWorkItem { self.view.backgroundColor = .red }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    self.workItem = workItem
}
```

### UIView.Animate and UIViewPropertyAnimator

GCD와 비슷하게, 애니메이션 호출은 일반적으로 순환 참조의 위험이 없지만, UIViewPropertyAnimator가 프로퍼티에 저장된 경우에는 위험이 있을 수 있습니다. 

예를 들어, 아래 호출은 안전합니다.

```swift
func animateToRed() {
	UIView.animate(withDuration: 3.0) {
    	self.view.backgroundColor = .red
    }
}
```

```swift
func setupAnimation() {
	let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
    	self.view.backgroundColor = .red
    }
    anim.addCompletion { _ in
    	self.view.backgroundColor = .white
    }
    anim.startAnimation()
}
```

반면에, 아레 메서드는 나중에 사용하고자 애니메이션을 `[weak self]`없이 저장하기에 강한 순환 참조를 유발합니다. 

```swift
func setupAnimation() {
	let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
    	self.view.backgroundColor = .red
    }
    anim.addCompletion { _ in
    	self.view.backgroundColor = .white
    }
    self.animationStorage = anim
}
```

### Storing a function in a property

아래 예제는 눈에 잘 띄지 않고 교묘하게 발생할 수 있는 메모리 누수를 보여줍니다. 

클로저나 함수들을 한 객체에서 다른 객체로 전달하여 프로퍼티에 저장하는 것은 유용할 수 있습니다. 예를 들어, 객체 A가 객체 B에 직접 노출되지 않고, 객체 B의 메서드를 익명으로 호출하고 싶다고 가정해 봅시다. 이는 델리게이트 패턴에 대한 가벼운 대안으로 생각할 수 있습니다. 

예를 들어, 여기 프로퍼티에 클로저를 저장하는 프리젠티드 컨트롤러(presented controller)있습니다.

```swift
class PresentedController: UIViewController {
	var closure: (() -> Void)?
}
```

(위의 뷰 컨트롤러를 가지는) 메인 컨트롤러(main controller)가 있으며, 메인 컨트롤러의 메서드 중 하나를 프리젠티드 컨트롤러의 클로저로 전달하고자 합니다.  

```swift
class MainViewController: UIViewController {
	
    var presented = PresentedController()
    
    func setupClosure() {
    	presented.closure = printer
    }
    
    func printer() {
    	print(self.view.description)
    }
}
```

`printer()`는 메인 컨트롤러의 함수이며, 이 함수를 closure 프로퍼티에 할당했습니다. 6번째 줄에 괄호 ()를 포함하지 않은 것에 주목하세요. 이는 함수의 반환값이 아니라 함수 자체를 할당하고자 하기 때문입니다. 프리젠티드 컨트롤러 내부에서 클로저를 호출하면 메인 컨트롤러의 description이 출력됩니다.

이 코드는 교묘하게도 강한 순환 참조를 유발합니다. 비록 우리가 명시적으로 `self`를 사용하지 않았지만, `self`는 암묵적으로 포함되어 있습니다 (`self.printer`처럼 생각할 수 있습니다). 따라서, 클로저는 `self.printer`에 대한 강한 참조를 유지하며, `self`는 프리젠티드 컨트롤러를 가지며, 이 컨트롤러는 클로저를 가집니다.

순환 참조를 끊기 위해서, `[weak self]`를 포함하도록 setupClosure 함수를 수정해야 합니다.

```swift
func setupClosure() {
	self.presented.closure = { [weak self] in
    	self?.printer()
    }
}
```

이번에는 `printer` 함수 뒤에 괄호를 포함하고 있는데, 이는 해당 범위 내에서 함수를 호출하고자 하기 때문입니다.


### Timers

타이머는 흥미롭게도, 프로퍼티에 타이머를 저장하지 않더라도 문제를 유발할 수 있습니다. 예를 들어, 아래와 같은 타이머를 살펴보겠습니다.

```swift
func leakyTimer() {
	let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
    	let currentColor = self.view.backgroundColor
        self.view.backgroundColor = currentColor == .red ? .blue : .red
    }
    timer.tolerance = 0.1
    RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
}
```

1. 이 타이머는 반복됩니다.

2. `self`는 `[weak self]`없이 클로저에서 참조됩니다.

이 두 가지 조건을 만족하는 한, 타이머는 참조된 컨트롤러/객체가 할당 해제되는 걸 막습니다. 기술적으로, 이는 메모리 누수라기보다는 할당 해제를 지연시키는 것에 가깝습니다. 그러나, 이러한 지연이 무기한으로 지속될 수 있습니다. 

참조된 객체가 무기한으로 유지되는 걸 피하기 위해 더 이상 필요로 하지 않는 타이머는 반드시 해제해주어야 하며, 참조된 객체가 타이머에 강한 참조를 유지해야 한다면 `[weak self]`를 사용하여 강한 순환 참조를 방지하는 걸 잊지 마세요.

## Demo App

[데모 앱](https://github.com/almaleh/weak-self)에 다른 예제가 많지만, 이 글로도 이미 충분하기에 모두 다루지는 않겠습니다. 데모 앱을 클론하여 Xcode에서 열고, PresentedController.swift에 있는 다양한 메모리 누수 시나리오를 확인해보세요 (각 시나리오에 대한 설명이 주석으로 추가되어 있습니다). 앱에서 누수 시나리오를 실행하면, 컨트롤러를 표시하고 사라지게 할 때 메모리 사용량이 급격하게 증가하는 것을 확인할 수 있습니다. 

{{< figure src="weak-self-5.webp" width="650px" center="align" >}}

## Alternatives to [weak self]

결론을 내기 전에, `[weak self]`를 다루기 원하지 않는다면 사용할 수 있는 두 가지 트릭을 알려드리고자 합니다 (이 내용은 [obj.c](https://www.objc.io/blog/2018/04/03/caputure-lists/)와 [swiftbysundell](https://www.swiftbysundell.com/articles/capturing-objects-in-swift-closures/)의 훌륭한 글들에서 배웠습니다).

클로저에 직접 `self`를 전달하고 `[weak self]`로 처리하는 대신, `self`에서 접근하고자 하는 프로퍼티에 대한 참조를 생성하고, 해당 참조를 클로저에 전달할 수 있습니다.

예를 들어, 애니메이션 클로저 내부에서 `self`의 `view` 프로퍼티에 접근하고 싶다고 가정해 봅시다. 이를 다음과 같이 작성할 수 있습니다.

```swift
func setupAnimator() {
	let view = self.view // create a reference to self's view property
    let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
    	view?.backgroundColor = .red // no reference to self inside the closure
    }
    anim.addCompletion { _ in
    	view?.backgroundColor = .white
    }
    self.animationStorage = anim
}
```

우리는 2번째 줄에서 `view` 프로퍼티에 대한 참조를 생성하고, 4번째와 7번째 줄의 클로저 내부에서 `self` 대신 해당 참조를 사용합니다. 9번째 줄에서는 애니메이션이 `self`의 프로퍼티에 저장되지만, `view` 객체는 애니메이션에 대한 강한 참조를 가지지 않으므로, 순환 참조가 발생하지 않습니다.

_(옮긴이 주: 클로저는 **self**가 아닌 **view** 상수를 참조 캡처하고 있습니다. 따라서, 순환 참조가 발생하지 않습니다.)_

클로저에서 `self`의 여러 프로퍼티를 참조하고 싶다면, 이들을 모두 튜플(컨텍스트라 부를 수 있습니다)로 묶어 클로저에 전달할 수 있습니다.

```swift
func setupAnimator() {

	let context = (view: self.view,
    			   navigationItem: self.navigationItem,
    			   parent: self.parent
    			   )
          
	let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
    	context.view?.backgroundColor = .red
        context.navigationItem.rightBarButtonItems?.removeAll()
        context.parent?.view.backgroundColor = .blue
    }
    self.animationStorage = anim
}
```

## Conclusion

여기까지 읽어주셔서 감사합니다! 예상보다 훨씬 길 글이 되어 버렸네요 😅

여기 주요 내용을 정리해보겠습니다.

* `[unowned self]`는 거의 항상 좋은 선택이 아닙니다.

* 비-탈출 클로저는 할당 해제를 지연시키지 않는 한, `[weak self]`를 필요로 하지 않습니다. _(옮긴이 주: 할당 해제를 지연시키고 싶으면 `[weak self]`를 사용하지 마세요.)_

* 탈출 클로저는 어딘가 저장되거나 다른 클로저에 전달될 때, 그리고 그 내부의 객체가 클로저를 참조하는 경우 `[weak self]`를 필요로 합니다.

* `guard let self = self`는 경우에 따라 할당 해제 지연을 야기하며, 이는 의도에 따라 긍정적일 수도, 부정적일 수도 있습니다. 

* GCD와 애니메이션 호출은 나중에 사용하기 위해 프로퍼티에 저장하지 않는 한 `[weak self]`를 필요로 하지 않습니다.

* 타이머는 주의해서 사용하세요!

* 확신이 없다면, [deinit](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/deinitialization/)과 인스트루먼트가 도움이 될 겁니다.

앞서 보여드린 [플로우 차트](https://cdn-images-1.medium.com/v2/resize:fit:1400/1*yHX-8dJrQpH7R2hfM_21MQ.png)가 `[weak self]`의 사용 시점을 되짚는 데 도움이 되리라 생각합니다.

**업데이트:** Swift의 중첩된 클로저에서 `[weak self]`에 대한 주제는 [새로운 글](https://medium.com/flawless-app-stories/the-nested-closure-trap-356a0145b6d)에서 다시 다루었습니다.

 ---
 
 **제가 작성한 다른 글도 읽어보세요:** 

* [Fireworks - A visual particles editor for Swift](https://medium.com/@almalehdev/fireworks-a-visual-particles-editor-for-swift-618e76347798?source=post_page-----a778bec505ef--------------------------------)

* [Concurrency Visualized - Part 1: Sync vs Async](https://medium.com/@almalehdev/concurrency-visualized-part-1-sync-vs-async-c433ff7b3ebe?source=post_page-----a778bec505ef--------------------------------)


**이 글에서 참고한 자료:**

* [Automatic Reference Counting = The Swift Programming Language (Swift 5.1)](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html?source=post_page-----a778bec505ef--------------------------------)

* [Swift Style, Second Edition: An Opinionated Guide to an Opinionated Language by Eria Sadun](https://pragprog.com/book/esswift2/swift-style-second-edition?source=post_page-----a778bec505ef--------------------------------)

* [Swift Tip: Capture Lists](https://www.objc.io/blog/2018/04/03/caputure-lists/?source=post_page-----a778bec505ef--------------------------------)

* [Weak self and unowned self explained in Swift - SwiftLee](https://www.avanderlee.com/swift/weak-self/?source=post_page-----a778bec505ef--------------------------------)

* [Capturing objects in Swift closures](https://www.swiftbysundell.com/posts/capturing-objects-in-swift-closures?source=post_page-----a778bec505ef--------------------------------)

* [Capturing Self with Swift 4.2](https://benscheirman.com/2018/09/capturing-self-with-swift-4-2/?source=post_page-----a778bec505ef--------------------------------)

**데모 앱:**

* [almaleh/weak-self](https://github.com/almaleh/weak-self?source=post_page-----a778bec505ef--------------------------------)

