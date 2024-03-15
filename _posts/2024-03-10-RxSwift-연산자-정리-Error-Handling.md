---
title: "RxSwift 연산자 정리 ⑥ - Error Handling"
date: 2024-03-10 22:00:00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## Error Handling 연산자

RxSwift에서 `옵저버블`이 `Error` 항목을 방출할 경우, `옵저버`는 더 이상 `옵저버블`로부터 항목을 전달받지 못합니다. 그래서 이를 처리해줄 수 있는 여러 예외 연산자가 존재합니다. Error Handling 연산자는 `옵저버블`이 `Error` 항목을 방출하면 `다른 옵저버블`의 항목이나 기본 값을 방출하게 하거나, 정해진 횟수만큼 재시도(retry)를 하게 만들 수 있습니다. 대표적인 연산자로 `catch`, `catchAndReturn`, `retry` 연산자가 있습니다.  

### catch

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| catch(_ handler:) | 이 연산자는 `옵저버블`이 `Error` 항목을 방출하게 된다면 `옵저버블`과 구독을 종료하고, `다른 옵저버블`의 항목을 방출합니다. <br> 첫 번째 매개변수로 대체할 `옵저버블`을 반환하는 클로저를 전달해야 합니다. | - |

 ```swift
enum MyError: Error {
    case error
}

let subject = PublishSubject<Int>()
subject
    .catch { _ in Observable<Int>.of(-1, -2, -3) }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

subject.onNext(10)
subject.onNext(20)
subject.onNext(30)

subject.onError(MyError.error)
 ``` 

### catchAndReturn

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| interval(_ preiod:scheduler:) | 이 연산자는 `옵저버블`이 `Error` 항목을 방출하게 된다면 `옵저버블`과 구독을 종료하고, 기본 값을 대신 방출합니다. <br> 첫 번째 매개변수로 `옵저버블` 타입과 동일한 기본 값을 전달해야 합니다. | - |

 ```swift
let subject = PublishSubject<Int>()
subject
    .catchAndReturn(-1)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

subject.onNext(10)
subject.onNext(20)
subject.onNext(30)

subject.onError(MyError.error)
 ``` 

### retry

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| retry(_ maxAttempts:) | 이 연산자는 `옵저버블`이 `Error` 항목을 방출하게 된다면 `옵저버블`과 구독을 종료하고, 새롭게 다시 구독합니다(시퀀스를 재시작). <br> 첫 번째 매개변수로 최대 얼마나 시퀀스를 재시작할지 값을 전달해야 합니다. | - |

 ```swift
var attempts = 1

let source = Observable<Int>.create { observer in
    let currentAttempts = attempts
    print("- #\(currentAttempts) START")
    
    if attempts < 3 {
        observer.onError(MyError.error)
        attempts += 1
    }
    
    observer.onNext(10)
    observer.onNext(20)
    observer.onCompleted()
    
    return Disposables.create {
        print("- #\(currentAttempts) END")
    }
}

source
    .retry(7)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 

### retryWhen

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| retry(when:) | 이 연산자는 `옵저버블`이 `Error` 항목을 방출하게 된다면 `옵저버블`과 구독을 종료하고, `트리거 옵저버블`이 항목을 방출할 때, 새롭게 다시 구독합니다(시퀀스를 재시작). <br> 첫 번째 매개변수로 `트리거 옵저버블`을 전달해야 합니다. | - |

 ```swift
var attempts = 1
let trigger = PublishSubject<Int>()

let source = Observable<Int>.create { observer in
    let currentAttempts = attempts
    print("- #\(currentAttempts) START")
    
    if attempts < 3 {
        observer.onError(MyError.error)
        attempts += 1
    }
    
    observer.onNext(10)
    observer.onNext(20)
    observer.onCompleted()
    
    return Disposables.create {
        print("- #\(currentAttempts) END")
    }
}

source
    .retry { _ in trigger }
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 

## 참고 자료

* [ReactiveX 공식 문서](https://reactivex.io/documentation/operators.html)