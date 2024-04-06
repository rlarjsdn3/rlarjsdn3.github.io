---
title: "Schedulers(observeOn, subscribeOn) 알아보기"
date: 2024-04-25 22:00:00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## Schedulers

RxSwift가 가지는 강력한 기능 중 하나인 `Schedulers`는 특정 `Observable`이 항목을 방출하거나, 항목이 `Operator`를 거칠 때 어느 쓰레드(Thread)에서 이를 수행하게 할 지 결정하게 할 수 있습니다. 이미 Swift에서 이를 위해 `Grand Central Dispatch(GCD)`를 제공하고 있지만, 자칫하면 순환 참조(Circular Reference)가 발생할 위험을 높입니다. RxSwift의 `Schedulers`는 선언적인 형태로 쉽게 쓰레드를 지정하게 해줍니다. 덕분에 코드 가독성도 높아지는 효과도 얻을 수 있죠.

RxSwift의 `Schedulers`는 `GCD`와 완벽하게 대응됩니다. 아래 표는 이 같은 차이를 보여줍니다.

| GCD | Schedulers | Thread |
| :--| :-------- | :----: |
| `DispatchQueue.main` | `MainScheduler` | Main | 
| `DispatchQueue.global(label: "serialQueue")`[^footnote-1] | `SerialDispatchQueueScheduler` | Background |
| `DispatchQueue.global(label: "concurrentQueue", attributes: .concurrent)` | `ConcurrentDispatchQueueScheduler` | Background |

`Observable` 스트림에서 쓰레드를 지정하려면 `subscribe(on:)`과 `observe(on:)` 연산자를 사용하면 됩니다. 각 연산자는 **어느 시점에서 쓰레드를 지정할 지** 차이가 있습니다.

### SubscribeOn



```swift
let observable = Observable.just("Hello, RxSwift!")
```

`subscribe(on:)` 연산자를 알아보기 전, 중요한 사실 하나 짚어보아야 합니다. 위 예제와 같이 `Observable`이 하나 선언되어 있다면, 해당 `Observable`은 **언제** 항목을 생성하고 `Observer`에게 방출할까요? 바로 **`Observer`가 해당 `Observable`을 구독했을 때** 입니다. `Observer`가 해당 `Observable`을 구독하지 않는다면, 해당 `Observable`은 그저 방출할 항목을 정의해놓은 설계 도면에 불과합니다. 클래스(Class)는 인스턴스(Instance)를 만들기 위한 설계 도면이듯이, `Observable`도 마찬가지입니다.

```swift
observable // Subscription Code
    .subscribe { print($0) } 
    .disposed(by: disposeBag)
```

`Observable`이 항목을 생성하고 방출하는 영역을 `Subscription Code`라고 합니다. `subscribe(on:)` 연산자는 `Subscription Code` 영역이 어느 쓰레드에서 수행하게 할지 결정합니다. 즉, 항목을 방출할 때 메인 쓰레드나 백그라운드 쓰레드에서 수행하게 할 수 있습니다. 

`subscribe(on:)` 연산자는 `observe(on:)` 연산자와는 다르게, 순서가 중요하지 않습니다. `Observable` 스트림 아무데나 해당 연산자를 붙여주면, 항목을 특정 쓰레드에서 방출하도록 할 수 있습니다. 아래는 `subscribe(on:)` 연산자를 사용하는 방법을 보여줍니다.

```swift
let disposeBag = DisposeBag()

let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
Observable<Int>.from(Array(1...3))
    .subscribe(on: backgroundScheduler)
    .do { _ in print(Thread.isMainThread ? "= Main Thread" : "= Background Thread") }
    .map { $0 * 2 }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

// Console
// = Background Thread
// next(2)
// = Background Thread
// next(4)
// ...
```

`Observable`이 백그라운드 쓰레드에서 항목을 방출하고 있습니다. 한 가지 주의할 점은 `subscribe(on:)` 연산자는 항목을 생성・방출할 때만 쓰레드를 지정하지 않는다는 점입니다. 별도 `observe(on:)` 연산자를 작성해주지 않는다면, **다운 스트림(Down Stream) 끝까지 해당 쓰레드를 유지**합니다. 처음 스케줄러를 공부할 당시엔 `subscribe(on:)` 메서드는 `Subscription Code` 영역의 쓰레드만 변경하고, 나머지 다운 스트림은 다시 원래 쓰레드(메인 쓰레드)로 돌아오는 줄 알았는데, 그게 아니었습니다.

### ObserveOn

`Observable`이 항목을 생성하고 방출하는 영역을 `Subscription Code`라고 한다면, 방출된 항목을 관찰하는 영역을 `Observing Code`라고 합니다. 그 사이엔 항목을 가공하는 `Operator`가 있습니다. 

`observe(on:)` 연산자는 `Operator`나 `Observing Code` 영역이 어느 쓰레드에서 수행하게 할지 결정합니다. 순서가 중요하지 않는 `subscribe(on:)` 연산자와는 다르게, **`observe(on:)` 연산자는 순서가 매우 중요합니다.** `observe(on:)` 연산자는 이어지는 다운 스트림이 어느 쓰레드에서 수행할 지 결정하기 때문입니다. 아래는 `observe(on:)` 연산자를 사용하는 방법을 보여줍니다.

```swift
let mainScheduler = MainScheduler.instance
let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
Observable<Int>.from(Array(1...3))
    .subscribe(on: backgroundScheduler)
    .do { _ in print(Thread.isMainThread ? "= Main Thread" : "= Background Thread") }
    .observe(on: mainScheduler)
    .do { _ in print(Thread.isMainThread ? "= Main Thread" : "= Background Thread") }
    .map { $0 * 2 }
    .observe(on: backgroundScheduler)
    .subscribe { print($0, Thread.isMainThread ? "= Main Thread" : "= Background Thread") }
    .disposed(by: disposeBag)

// Console
// = Background Thread
// = Background Thread
// = Background Thread
// = Main Thread
// = Main Thread
// next(2) = Background Thread
// = Main Thread
// next(4) = Background Thread
// ...
```

## 빌트-인 Scheduler

RxSwift는 자주 사용되는 `Scheduler`를 미리 정의해놓아 간편하게 사용할 수 있습니다. 

### CurrentThreadScheduler (Serial)

현재 쓰레드에서 작업을 수행하도록 하는 스케줄러입니다. `Operator`가 항목을 내보내는 쓰레드입니다. 해당 쓰레드는 `Trampoline Scheduler`라고도 부릅니다. 

### MainScheduler (Serial)

메인 쓰레드에서 작업을 수행하도록 하는 스케줄러입니다. UI 작업에 적합한 스케줄러입니다. 메인 쓰레드에서 해당 쓰레드를 사용하도록 하는 경우, 별도 스케줄링을 수행하지 않습니다.

### SerialDispatchQueueScheduler (Serial)

백그라운드 쓰레드에서 작업을 직렬(Serial)로 수행하도록 하는 스케줄러입니다. 동시 큐(Concurrent Dispatch Queue)를 전달하더라도 직렬로 수행하는 걸 보장합니다. `observe(on:)` 연산자는 직렬 스케줄러에 최적화되어 있습니다.

### ConcurrentDispatchQueueScheduler (Concurrent)

백그라운드 쓰레드에서 작업을 동시(Concurrent)로 수행하도록 하는 스케줄러입니다. 직렬 큐(Serial Dispatch Queue)를 전달하더라도 동시로 수행하는 걸 보장합니다. 작업을 백그라운드 쓰레드에서 수행해야 하는 데 적합한 스케줄러입니다. 


## 참고 자료

* [ReactiveX 공식 문서](https://reactivex.io/documentation/operators.html)

* [RxSwift의 Scheduler 이해하기 (#GCD와 Scheduler 차이점)](https://ios-development.tistory.com/1461)

* [Schedular란 (subscribeOn, observeOn)](https://jouureee.tistory.com/169)

* [Scheduler는 무엇인가?](https://jcsoohwancho.github.io/2019-10-20-Scheduler는-무엇인가/)


RxSwift에서 '비동기 이벤트'란 일반적으로 비동기적으로 발생하는 이벤트를 의미합니다. 이는 이벤트가 언제 발생할지 확실하지 않거나, 이벤트를 받는 측이 이벤트를 동기적으로 기다리지 않고, 비동기적으로 처리해야 할 때 발생합니다.

예를 들어, 네트워크 요청을 보내고 그에 대한 응답을 기다리는 동안에도 프로그램은 계속 실행될 수 있습니다. 이 때 네트워크 응답은 비동기적으로 발생하는 이벤트로 처리됩니다. RxSwift에서는 Observable을 사용하여 비동기 이벤트를 다룰 수 있습니다. Observable은 비동기적으로 이벤트를 생성하고, 해당 이벤트를 Observer에게 비동기적으로 전달합니다.

따라서 RxSwift에서 '비동기 이벤트'는 이벤트를 비동기적으로 생성하고 전달하는 것을 의미하며, 이를 통해 비동기적인 작업을 조율하고 처리할 수 있습니다.


[^footnote-1]: 사용자 지정 큐(Queue)는 기본적으로 직렬(Serial)로 작업을 처리합니다.