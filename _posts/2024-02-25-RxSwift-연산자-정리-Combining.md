---
title: "RxSwift 연산자 정리 ④ - Combining"
date: 2024-2-25 22::00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## Combining 연산자

Transforming 연산자는 `옵저버블`이 방출하는 항목을 다른 항목으로 바꾸거나 새로운 항목으로 대체할 수 있는 연산자입니다. 이러한 연산자는 전달한 클로저에 따라 `옵저버블`이 방출하는 항목을 다른 항목으로 바꿀 수 있습니다. 대표적인 연산자로 `toArray`, `flatMap`, `concatMap`, `scan`, `reduce` 연산자가 있습니다.  

### startWith

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| startWith(elements:) | 이 연산자는 `옵저버블`이 방출하는 항목 앞에 새로운 항목을 추가합니다. <br>  | - |

 ```swift
let numbers = [4, 5, 6, 7, 8, 9]

Observable<Int>.from(numbers)
    .startWith(2, 3)
    .startWith(1)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 

### concat

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| concat(_ sequence:) | 이 연산자는 여러 개의 `옵저버블`을 순서대로 묶은 결과를 방출합니다. <br> 옵저버블의 타입이 서로 동일해야 합니다. | - |
| concat(_ second:) | 이 연선자는 `옵저버블`을 순서대로 묶은 결과를 방출합니다. <br> 옵저버블의 타입이 서로 동일해야 합니다. | - | 

 ```swift
let fruits = Observable.from(["🍏", "🍎", "🥝", "🍑", "🍋", "🍉"])
let animals = Observable.from(["🐶", "🐱", "🐹", "🐼", "🐯", "🐵"])

// 방법 ①
Observable<String>.concat([fruits, animals])
    .subscribe { print($0) }
    .disposed(by: disposeBag)

// 방법 ②
fruits
    .concat(animals)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 

### merge

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| merge() | 이 연산자는 여러 개의 `옵저버블`이 방출하는 항목을 하나로 묶은 결과를 방출합니다. <br> `concat` 연산자와는 다르게 순서를 보장하지 않습니다. | - |
| merge(maxConcurrent:) | 이 연산자는 여러 개의 `옵저버블`이 방출하는 항목을 하나로 묶은 결과를 방출합니다. <br> maxConcurrent 매개변수로 한 번에 합칠 수 있는 최대 `옵저버블`의 개수를 전달합니다. <br> 합친 `옵저버블`에서 `completed` 항목을 방출하면 새로운 `옵저버블`과 합친 결과를 반환합니다. | - |

 ```swift
let first = BehaviorSubject<Int>(value: 1)
let second = BehaviorSubject<Int>(value: 10)
let third = BehaviorSubject<Int>(value: 100)

let source = Observable.of(first, second, third)
source
    .merge(maxConcurrent: 2)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

first.onNext(2)
second.onNext(11)

first.onCompleted()
second.onCompleted()

third.onNext(101)
third.onCompleted()
 ``` 

### combineLatest

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| combineLatest(_ sequence:) | 이 연산자는 각 `옵저버블`이 마지막으로 방출한 항목을 하나로 묶은 결과를 방출합니다. <br> 어느 옵저버블이 항목을 방출한 적이 없다면 묶어진 항목을 방출하지 않습니다.  | - |

 ```swift
let greeting = PublishSubject<String>()
let language = PublishSubject<String>()

Observable<String>.combineLatest([greeting, language])
    .map { $0.joined(separator: ", ") }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

greeting.onNext("Hello")

language.onNext("Swift!")
language.onNext("UIKit!")

greeting.onNext("Good Bye")

greeting.onCompleted()
language.onCompleted()
 ``` 

### zip

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| zip(_ sequence:) | 이 연산자는 각 `옵저버블`이 방출하는 항목의 짝이 서로 맞으면 하나로 묶은 결과를 방출합니다.  | - |

 ```swift
let numbers = PublishSubject<Int>()
let strings = PublishSubject<String>()

Observable.zip(numbers, strings)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

numbers.onNext(1)
strings.onNext("One")

numbers.onNext(2)
strings.onNext("Two")

numbers.onNext(3)

numbers.onCompleted()
strings.onCompleted()
 ``` 

### withLatestFrom

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| withLatestFrom(_ second:) | 이 연산자는 `트리거 옵저버블`이 항목을 방출 할 때 `소스 옵저버블`이 마지막으로 방출한 항목과 하나로 묶은 결과를 방출합니다.  | - |

 ```swift
let source = PublishSubject<String>()

trigger.withLatestFrom(source) { "\($0)\($1)" }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

source.onNext("A")
trigger.onNext(1)

trigger.onNext(2)
source.onNext("B")

source.onCompleted()
trigger.onCompleted()
 ``` 

## sample

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| sample(_ sampler:) | 이 연산자는 `트리거 옵저버블`이 항목을 방출 할 때 `소스 옵저버블`이 마지막으로 방출한 항목과 하나로 묶은 결과를 방출합니다. <br> `withLatestFrom` 연산자와는 다르게 `트리거 옵저버블`이 동일한 항목을 방출한다면 새로운 항목을 방출하지 않습니다.  | - |

 ```swift
let trigger = PublishSubject<Void>()
let source = PublishSubject<String>()

source.sample(trigger)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

trigger.onNext(())

source.onNext("Swift")
trigger.onNext(())

trigger.onNext(())
source.onNext("RxSwift")

source.onCompleted()
trigger.onNext(())
 ``` 

### switchLatest

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| switchLateset() | 이 연산자는 가장 최근에 항목을 방출한 `옵저버블`이 방출하는 항목을 방출합니다.  | - |

 ```swift
let a = PublishSubject<String>()
let b = PublishSubject<String>()

let source = PublishSubject<Observable<String>>()

source
    .switchLatest()
    .subscribe { print($0) }
    .disposed(by: disposeBag)

source.onNext(a)

a.onNext("Two")
a.onNext("Three")

source.onNext(b)

a.onNext("Four")
b.onNext("Five")
b.onNext("Six")
 ``` 


## 참고 자료

* [ReactiveX 공식 문서](https://reactivex.io/documentation/operators.html)