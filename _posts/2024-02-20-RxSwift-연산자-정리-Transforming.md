---
title: "RxSwift 연산자 정리 ③ - Transforming"
date: 2024-2-20 22::00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## Transforming 연산자

Transforming 연산자는 `옵저버블`이 방출하는 항목을 다른 항목으로 바꾸거나 새로운 항목으로 대체할 수 있는 연산자입니다. 이러한 연산자는 전달한 클로저에 따라 `옵저버블`이 방출하는 항목을 다른 항목으로 바꿀 수 있습니다. 대표적인 연산자로 `toArray`, `flatMap`, `concatMap`, `scan`, `reduce` 연산자가 있습니다.

### toArray

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| toArray() | 이 연산자는 `옵저버블`이 방출하는 모든 항목을 배열로 묶은 결과를 방출합니다. <br> `completed` 항목이 방출될 때 묶어진 배열이 항목으로 방출됩니다. | - |

 ```swift
let subject = PublishSubject<String>()

subject
    .toArray()
    .subscribe { print($0) }
    .disposed(by: disposeBag)

subject.onNext("⭐️")
subject.onNext("✈️")
subject.onNext("✏️")
subject.onCompleted()
 ``` 

### map

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| map(_ transform:) | 이 연산자는 `옵저버블`이 방출하는 항목을 대상으로 새로운 항목으로 변환한 결과를 반환합니다. <br> 첫 번째 매개변수로 새롭게 변환한 항목의 타입을 반환하는 클로저를 전달해야 합니다. | - |

 ```swift
let skills = ["Swift", "SwiftUI", "UIKit", "RxSwift"]

Observable<String>.from(skills)
    .map { $0.count }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 


### compactMap

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| compactMap(_ transform:) | 이 연산자는 `옵저버블`이 방출하는 항목이 nil이라면 무시하고, 아니라면 옵셔널 해제한 항목을 반환합니다. <br> 첫 번째 매개변수로 새롭게 변환한 항목의 타입을 반환하는 클로저를 전달해야 합니다. | - |

 ```swift
let subject = PublishSubject<String?>()
subject
    .compactMap { $0 }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .map { _ in Bool.random() ? "⭐️" : nil }
    .subscribe { subject.onNext($0) }
    .disposed(by: disposeBag)

 ``` 


### flatMap

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| flatMap(_ selector:) | 이 연산자는 `옵저버블`이 방출하는 항목을 대상으로 새로운 `이너 옵져버블`을 만들고, 방출하는 항목을 `결과 옵저버블`에 모두 합쳐 평면화(flatten)시킵니다. <br> `이너 옵저버블`이 방출하는 항목은 순서를 보장하지 않습니다. <br> 첫 번째 매개변수로 새롭게 만든 `이너 옵저버블`을 반환하는 클로저를 전달해야 합니다.  | - |

 ```swift
let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

Observable<String>.from([redCircle, greenCircle, blueCircle])
    .flatMap { circle -> Observable<String> in
        switch circle {
        case redCircle:
            return Observable<String>.repeatElement(redHeart).take(5)
        case greenCircle:
            return Observable<String>.repeatElement(greenHeart).take(5)
        case blueCircle:
            return Observable<String>.repeatElement(blueHeart).take(5)
        default:
            return Observable.empty()
        }
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 


### flatMapFirst

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| flatMapFirst(_ selector) | 이 연산자는 `옵저버블`이 방출하는 항목을 대상으로 새로운 `이너 옵저버블`을 만들고, 해당 옵저버블이 방출하는 항목을 `결과 옵저버블`에 모두 합쳐 평면화(flatten)시킵니다. <br> 이때, 가장 먼저 항목을 방출하는 `이너 옵저버블`만 `결과 옵저버블`에 전달되며, 이후 생성된 `이너 옵저버블`은 앞서 `이너 옵저버블`이 모든 항목을 방출할 때까지 무시됩니다. <br> 첫 번째 매개변수로 새롭게 만든 `이너 옵저버블`을 반환하는 클로저를 전달해야 합니다. | - |

 ```swift
let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

Observable<String>.from([redCircle, greenCircle, blueCircle])
    .flatMapFirst { circle -> Observable<String> in
        switch circle {
        case redCircle:
            return Observable<String>.repeatElement(redHeart).take(5)
        case greenCircle:
            return Observable<String>.repeatElement(greenHeart).take(5)
        case blueCircle:
            return Observable<String>.repeatElement(blueHeart).take(5)
        default:
            return Observable.empty()
        }
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 


### flatMapLatest

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| flatMapLatest(_ selector:) | 이 연산자는 `옵저버블`이 방출하는 항목을 대상으로 새로운 `이너 옵저버블`을 만들고, 해당 옵저버블이 방출하는 항목을 `결과 옵저버블`에 모두 합쳐 평면화(flatten)시킵니다. <br> 이때, 가장 나중에 항목을 방출하는 `이너 옵저버블`만 `결과 옵저버블`에 전달되며, 이전에 생성된 `이너 옵저버블`은 무시됩니다. <br> 첫 번째 매개변수로 새롭게 만든 `이너 옵저버블`을 반환하는 클로저를 전달해야 합니다.  | - |

 ```swift
let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

Observable<String>.from([redCircle, greenCircle, blueCircle])
    .flatMapLatest { circle -> Observable<String> in
        switch circle {
        case redCircle:
            return Observable<String>.repeatElement(redHeart).take(5)
        case greenCircle:
            return Observable<String>.repeatElement(greenHeart).take(5)
        case blueCircle:
            return Observable<String>.repeatElement(blueHeart).take(5)
        default:
            return Observable.empty()
        }
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 


### concapMap

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| concatMap(_ selector:) | 이 연산자는 `옵저버블`이 방출하는 항목을 대상으로 새로운 `이너 옵져버블`을 만들고, 방출하는 항목을 `결과 옵저버블`에 모두 합쳐 평면화(flatten)시킵니다. <br> `flatMap` 연산자와는 다르게 `이너 옵저버블`이 방출하는 항목은 순서를 보장합니다. <br> 첫 번째 매개변수로 새롭게 만든 `이너 옵저버블`을 반환하는 클로저를 전달해야 합니다.  | - |

 ```swift
let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

Observable<String>.from([redCircle, greenCircle, blueCircle])
    .concatMap { circle -> Observable<String> in
        switch circle {
        case redCircle:
            return Observable<String>.repeatElement(redHeart).take(5)
        case greenCircle:
            return Observable<String>.repeatElement(greenHeart).take(5)
        case blueCircle:
            return Observable<String>.repeatElement(blueHeart).take(5)
        default:
            return Observable.empty()
        }
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 


### scan

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| scan(_ seed:accumulator:) | 이 연산자는 `옵저버블`이 방출하는 항목과 이전 항목(초기 항목)을 연산한 결과를 방출합니다. | - |

 ```swift
Observable<Int>.range(start: 1, count: 9)
    .scan(0) { $0 + $1 }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 


### reduce

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| toArray() | 이 연산자는 `옵저버블`이 방출하는 항목과 이전 항목(초기 항목)을 연산한 결과를 방출합니다. <br> `scan` 연산자와는 다르게 최종 결과만 방출합니다. | - |

 ```swift
Observable<Int>.range(start: 1, count: 9)
    .reduce(0) { $0 + $1 }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 


### buffer

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| buffer(timeSpan:count:scheduler:) | 이 연산자는 `옵저버블`이 방출하는 항목을 일정 주기 동안 수집하고, 배열로 묶은 결과를 방출합니다. <br> 일정 주기가 지나거나, 최대 버퍼 카운트에 도달하면 곧바로 묶어진 배열을 방출합니다.  | - |

 ```swift
Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .buffer(timeSpan: .seconds(3), count: 5, scheduler: MainScheduler.instance)
    .take(5)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 


### window

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| window(timeSpan:count:scheduler:) | 이 연산자는 `옵저버블`이 방출하는 항목을 일정 주기 동안 수집하고, (배열이 아닌) `이너 옵저버블`을 방출합니다. <br> 일정 주기가 지나거나, 최대 버퍼 카운트에 도달하면 곧바로 `이너 옵저버블`을 방출합니다.  | - |

 ```swift
Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .window(timeSpan: .seconds(3), count: 5, scheduler: MainScheduler.instance)
    .take(5)
    .subscribe {
        if let observable = $0.element {
            observable
                .subscribe { print("Inner Observable - \($0)") }
        }
    }
    .disposed(by: disposeBag)
 ``` 


### groupBy

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| groupBy(_ keySelector:) | 이 연산자는 `옵저버블`이 방출하는 항목을 조건에 따라 그룹핑(grouping)한 결과를 `이너 옵저버블`로 방출합니다.  | - |

 ```swift
let words = ["Apple", "Banana", "Orange", "Book", "City", "Axe"]

Observable<String>.from(words)
    .groupBy { $0.first ?? Character("") }
    .flatMap { $0.toArray() }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 

## 참고 자료

* [ReactiveX 공식 문서](https://reactivex.io/documentation/operators.html)

