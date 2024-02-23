---
title: "RxSwift 연산자 정리 ⑦ - Sharing"
date: 2024-03-25 22:00:00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## Sharing 연산자

Sharing 연산자는 `옵저버블`이 방출하는 항목을 다른 `옵저버`와 공유할 수 있는 연산자입니다. 즉, `유니캐스트`로 동작하는 `옵저버블`을 `멀티캐스트`로 바꿔줍니다. 불필요한 스트림 낭비를 막고, 메모리 성능을 향상시키기 위해 적재적소에 스트림을 공유하는 게 좋습니다. 대표적인 연산자로 `share` 연산자가 있습니다.

### multicast

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| multicast(_ subject:) | 이 연산자는 `옵저버블`이 방출하는 항목을 다른 `옵저버`와 공유할 수 있습니다. <br> `옵저버블`이 방출하는 항목은 `옵저버`가 아닌 첫 번째 매개변수로 전달하는 `서브젝트`에 전달됩니다. <br> 이렇게 `서브젝트`로 전달된 항목이 다시 여러 `옵저버`에게 방출됩니다. <br> 모든 `옵저버`를 추가한 이후 `connect()` 메서드를 호출해주어야 `옵저버블`이 항목을 방출합니다. <br> 첫 번째 매개변수로 `서브젝트`를 전달해야 합니다. | - |

 ```swift
let publishSubject = PublishSubject<Int>()

let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(5)
    .multicast(publishSubject)

source
    .subscribe { print("⭐️: ", $0) }
    .disposed(by: disposeBag)

source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("✈️: ", $0) }
    .disposed(by: disposeBag)

source.connect()
 ``` 

### publish

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| publish() | 이 연산자는 `옵저버블`이 방출하는 항목을 다른 `옵저버`와 공유할 수 있습니다. <br> `multicast` 연산자에서는 직접 `서브젝트`를 만들어 넘겨주어야 했다면, 이 연산자는 자체적으로 `PublishSubject`를 만들어 `multicast` 연산자의 매개변수로 전달합니다. | - |

 ```swift
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(5)
    .publish()

source
    .subscribe { print("⭐️: ", $0) }
    .disposed(by: disposeBag)

source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("✈️: ", $0) }
    .disposed(by: disposeBag)
 ``` 

### replay

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| replay(_ bufferSize:) | 이 연산자는 `옵저버블`이 방출하는 항목을 다른 `옵저버`와 공유할 수 있습니다. <br> `multicast` 연산자에서는 직접 `서브젝트`를 만들어 넘겨주어야 했다면, 이 연산자는 자체적으로 `ReplaySubject`를 만들어 `multicast` 연산자의 매개변수로 전달합니다. <br> 새로운 `옵저버`가 구독을 하게 되면 `버퍼`에 저장된 항목을 모두 방출합니다. <br> 첫 번째 매개변수로 버퍼 사이즈를 전달합니다. (버퍼 사이즈가 0이라면 `PublishSubject`처럼 동작합니다) | - |

 ```swift
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(5)
    .replay(2)

source
    .subscribe { print("⭐️: ", $0) }
    .disposed(by: disposeBag)

source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("✈️: ", $0) }
    .disposed(by: disposeBag)

source.connect()
 ``` 

### refCount

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| refCount() | 이 연산자는 새로운 `옵저버`가 추가되는 시점에 자동으로 `connect()` 메서드를 호출합니다.  | - |

 ```swift
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(5)
    .publish()
    .refCount()

source.subscribe { print("✈️: ", $0) }
 ``` 

### share

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| share(replay:scope:) | 이 연산자는 `옵저버블`이 방출하는 항목을 다른 `옵저버`와 공유하 수 있습니다.  <br> 앞서 살펴본 연산자를 모두 합쳐 편리하게 사용하도록 도와줍니다. <br> 첫 번째 매개변수로 버퍼 사이즈를 전달합니다. (버퍼 사이즈가 0이라면 `PublishSubject`처럼 동작합니다) <br> scope 매개변수로 `SubjectLifeTimeScope` 타입의 버퍼의 생명 주기를 전달합니다. <br> `.whileConnected`와 `.forever` 중 하나를 전달해야 합니다. <br> `whileConnected`는 하나 이상의 `옵저버`가 존재하는 동안에만 버퍼를 유지합니다. <br> `forever`는 `옵저버`가 하나도 남아있지 않더라도 버퍼를 유지합니다. | - |

 ```swift
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .share(replay: 5, scope: .forever)

let ob1 = source
    .subscribe { print("🛠️", $0) }

let ob2 = source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("✏️", $0) }

DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    ob1.dispose()
    ob2.dispose()
}

DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
    let ob3 = source.subscribe { print("⭐️", $0) }
    let ob4 = source.subscribe { print("🐬", $0) }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        ob3.dispose()
        ob4.dispose()
    }
}
 ``` 

## 참고 자료

* [ReactiveX 공식 문서](https://reactivex.io/documentation/operators.html)

* [[RxSwift] Share(replay:)](https://jusung.github.io/shareReplay/)