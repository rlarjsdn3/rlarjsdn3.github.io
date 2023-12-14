---
title: "RxSwift 연산자 정리 ② - Filtering"
date: 2023-12-10 22::00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## Filetering 연산자

Filtering 연산자는 `옵저버블`이 방출하는 이벤트를 선택적으로 걸러낼 수 있는 연산자입니다. 이러한 연산자는 특정 조건에 따라 `옵저버블`이 방출하는 이벤트를 무시하거나, 걸러내는 데 사용될 수 있습니다. 대표적인 연산자로 `take`, `skip`, `disinctUntilChanged`, `filter`, `throttle` 연산자가 있습니다.  

### ignoreElements

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| ignoreElements() | 이 연산자는 `옵저버블이`이 방출하는 모든 이벤트를 무시합니다. <br> `Completed`와 `Error` 이벤트만 방출합니다. | - |

 ```swift
Observable<String>.from(["🍏", "🍎", "🍋", "🍓", "🍇"])
    .ignoreElements()
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 

### elementAt

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| element(**at:**) | 이 연산자는 `옵저버블`이 방출하는 이벤트 중 특정 인덱스에 위치한 이벤트만 방출합니다. | - |

 ```swift
Observable<String>.from(["🍏", "🍎", "🍋", "🍓", "🍇"])
    .element(at: 1)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```

### filter

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| filter(**predicate:**) | 이 연산자는 `옵저버블`이 방출하는 이벤트를 필터링합니다. <br> 첫 번째 매개변수로 필터링 조건을 검사한 결과를 `Bool` 타입으로 반환하는 클로저를 전달해야 합니다. | - |

 ```swift
Observable<Int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    .filter { $0 > 3 }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```

### skip

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| skip(**count:**) | 이 연산자는 정해진 숫자만큼 `옵저버블`이 방출하는 이벤트를 생략하고, 이후 이벤트를 방출합니다. <br> 첫 번째 매개변수로 처음 생략할 이벤트의 수를 전달해야 합니다. | - |

 ```swift
Observable<Int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    .skip(5)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```

### skipWhile

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| skip(**while:**) | 이 연산자는 주어진 조건을 만족하는 동안에만 `옵저버블`이 방출하는 이벤트를 생략하고, 한번이라도 만족하지 않으면 이후 이벤트를 (검사하지 않고) 모두 방출합니다. <br> 첫 번째 매개변수로 필터링 조건을 검사한 결과를 `Bool` 타입으로 반환하는 클로저를 전달해야 합니다. | - |

 ```swift
Observable<Int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    .skip(while: { $0 % 2 == 1 })
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```

### skipUntil

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| skip(**until:**) | 이 연산자는 `트리거 옵저버블`이 하나의 이벤트를 방출할 때까지 `소스 옵저버블`이 방출하는 이벤트를 모두 생략합니다. <br> until 매개변수에 `트리거 옵저버블`을 전달해야 합니다. | - |

 ```swift
let subject = PublishSubject<Int>()
let trigger = PublishSubject<Void>()

subject
    .skip(until: trigger)
    .subscribe  { print($0) }
    .disposed(by: disposeBag)

subject.onNext(10)
trigger.onNext(())
subject.onNext(20)
subject.onNext(30)
subject.onCompleted()
 ```

### skipDuration

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| skip(**duration:scehdular:**) | 이 연산자는 지정한 시간 동안 `옵저버블`이 방출하는 이벤트를 생략합니다. <br> 첫 번째 매개변수로 `RxTimeInterval` 타입을 전달해야 합니다. <br> 일반적으로 `.millisecond(Int)`, `.second(Int)`를 전달합니다.| - |

 ```swift
Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .skip(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```

### take

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| take(**count:**) | 이 연산자는 정해진 숫자만큼 `옵저버블`이 방출하는 이벤트를 전달하고, 이후 이벤트를 생략합니다. <br> 첫 번째 매개변수로 전달할 이벤트의 수를 전달해야 합니다. | - |

 ```swift
Observable<Int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9])
    .take(5)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```

### takeWhile

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| take(**while:behavior:**) | 이 연산자는 주어진 조건을 만족하는 동안에만 `옵저버블`이 방출하는 이벤트를 전달하고, <br> 한번이라도 만족하지 않으면 이후 이벤트를 (검사하지 않고) 모두 생략합니다. <br> 첫 번째 매개변수로 필터링 조건을 검사한 결과를 `Bool` 타입으로 반환하는 클로저를 전달해야 합니다. <br> behavior 매개변수로 `TakeBehavior` 열거형을 전달해야 합니다. <br> `.exclusive`를 전달하면 마지막으로 검사한 요소를 이벤트로 전달하지 않고, <br> `.inclusive`를 전달하면 마지막으로 검사한 요소를 이벤트로 전달합니다. | - |

 ```swift
Observable<Int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9])
    .take(while: {
        !($0 % 4 == 0)
    }, behavior: .inclusive)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```

### takeUntil

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| take(**until:**) | 이 연산자는 `트리거 옵저버블`이 하나의 이벤트를 방출할 때까지 `소스 옵저버블`이 방출하는 이벤트를 모두 전달합니다. <br> until 매개변수에 `트리거 옵저버블`을 전달해야 합니다. | - |

 ```swift
let subject = PublishSubject<Int>()
let trigger = PublishSubject<Void>()

subject
    .take(until: trigger)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

subject.onNext(10)
subject.onNext(20)
trigger.onNext(())
subject.onNext(30)
 ```

### takeLast

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| takeLast(**count:**) | 이 연산자는 정해진 숫자만큼 `옵저버블`이 마지막으로 방출한 이벤트를 버퍼에 저장해두었다가, <br> `completed` 이벤트를 방출하는 시점에 버퍼에 저장된 이벤트를 방출합니다. <br> 첫 번째 매개변수로 버퍼에 저장할 이벤트의 수를 전달해야 합니다. | - |

 ```swift
let subject = PublishSubject<Int>()

subject
    .takeLast(3)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

subject.onNext(10)
subject.onNext(20)
subject.onNext(30)
subject.onNext(40)
subject.onNext(50)
subject.onCompleted()
 ```

### takeFor

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| take(**for:scheduler:**) | 이 연산자는 지정한 시간 동안 `옵저버블`이 방출하는 이벤트를 전달합니다. <br> 첫 번째 매개변수로 `RxTimeInterval` 타입을 전달해야 합니다. <br> 일반적으로 `.millisecond(Int)`, `.second(Int)`를 전달합니다. | - |

 ```swift
Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(for: .seconds(5), scheduler: MainScheduler.instance)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```

### distinctUntilChanged

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| distinctUntilChanged() | 이 연산자는 `옵저버블`이 방출하는 이벤트와 직전에 방출한 이벤트가 동일하다면 생략하고, 그렇지 않다면 전달합니다. | - |
| distinctUntilChanged(**comparer:**) | 이 연산자는 `옵저버블`이 방출하는 이벤트와 직전에 방출한 이벤트가 동일하다면 생략하고, 그렇지 않다면 전달합니다. <br> 첫 번째 매개변수로 `옵저버블`이 방출한 이벤트의 요소와 직전에 방출한 이벤트의 요소가 동일한지 검사한 결과를 `Bool` 타입으로 반환하는 클로저를 전달해야 합니다.  | - |
| distinctUntilChanged(**keySelector:**) | 이 연산자는 `옵저버블`이 방출하는 이벤트와 직전에 방출한 이벤트가 동일하다면 생략하고, 그렇지 않다면 전달합니다. <br> 첫 번째 매개변수로 `옵저버블`이 방출한 이벤트의 요소와 직전에 방출한 이벤트의 요소의 (`Equatable` 프로토콜을 준수하는) 비교 기준을 반환하는 클로저를 전달해야 합니다.  | - |
| distinctUntilChanged(**keyPath:**) | 이 연선자는 `옵저버블`이 방출하는 이벤트와 직전에 방출한 이벤트가 동일하다면 생략하고, 그렇지 않다면 전달합니다. <br> keyPath 매개변수로 키패스(KeyPath)를 전달해야 합니다. | - |

 ```swift
let numbers = [1, 1, 3, 2, 2, 3, 1, 5, 5, 7, 7, 7]
let tuples = [
    (1, "하나"), (1, "둘"), (2, "셋"), (2, "넷")
]
let persons = [
    Person(name: "김건우", age: 26),
    Person(name: "김문어", age: 15),
    Person(name: "김흰둥", age: 5),
    Person(name: "김지지", age: 5)
]

Observable<Int>.from(numbers)
    .distinctUntilChanged()
    .subscribe { print($0) }
    .disposed(by: disposeBag)

Observable<(Int, String)>.from(tuples)
    .distinctUntilChanged {
        return $0.0
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

Observable<(Int, String)>.from(tuples)
    .distinctUntilChanged {
        return $0.0 != $1.0
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

Observable<Person>.from(persons)
    .distinctUntilChanged(at: \.age)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```
 
### debounce

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| debounce(**dueTime:scheduler:**) | 이 연산자는 지정한 시간 동안 `옵저버블`에서 새로운 이벤트를 방출하지 않으면, 최근에 방출한 이벤트를 전달합니다. <br> 첫 번째 매개변수로 `RxTimeInterval` 타입을 전달해야 합니다. <br> 일반적으로 `.millisecond(Int)`, `.second(Int)`를 전달합니다. | - |

 ```swift
Observable<String>.create { observer in
    DispatchQueue.global().async {
        for i in 1...10 {
            observer.onNext("Next - \(i)")
            Thread.sleep(forTimeInterval: 0.3)
        }
        
        Thread.sleep(forTimeInterval: 1.0)
        
        for i in 11...20 {
            observer.onNext("Next - \(i)")
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        observer.onCompleted()
    }
    
    return Disposables.create()
}
.debounce(.milliseconds(400), scheduler: MainScheduler.instance)
.subscribe { print($0) }
.disposed(by: disposeBag)
 ```

### throttle

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| throttle(dueTime:latest:scheduler:) | 이 연산자는 지정한 주기 동안 `옵저버블`이 최근 방출한 이벤트를 전달합니다. <br> 첫 번째 매개변수로 `RxTimeInterval` 타입을 전달해야 합니다. <br> 일반적으로 `.millisecond(Int)`, `.second(Int)`를 전달합니다. <br> latest 매개변수로 `Bool` 타입을 전달해야 합니다. `true`를 전달하면 주기를 정확하게 지키고, `false`를 전달하면 주기를 유하게 지킵니다. | - |

 ```swift
Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .throttle(.seconds(2), latest: true, scheduler: MainScheduler.instance)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ```

## 참고 자료

* [ReactiveX 공식 문서](https://reactivex.io/documentation/operators.html)