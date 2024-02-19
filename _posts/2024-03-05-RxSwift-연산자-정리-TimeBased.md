---
title: "RxSwift 연산자 정리 ⑤ - TimeBased"
date: 2024-03-05 22:00:00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## TimeBased 연산자

TimeBased 연산자는 `옵저버블`이 시간의 흐름에 따라 특정 항목을 방출하게 하거나, 지연시킬 수 있는 연산자입니다. 대표적인 연산자로 `interval`, `timeout`, `delay` 연산자가 있습니다.  

### interval

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| interval(_ preiod:scheduler:) | 이 연산자는 `옵저버블`이 일정 주기마다 정수를 방출하도록 합니다. <br> `take` 연산자로 방출하는 항목을 제한하지 않는다면 무한정 방출하므로 주의가 필요합니다. <br> 첫 번째 매개변수로 새로운 항목을 방출하게 할 `RxTimeInterval` 타입의 주기를 전달해야 합니다. | - |

 ```swift
Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 

### timer

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| timer(_ dueTime:preiod:scheduler:) | 이 연산자는 `옵저버블`이 일정 시간 지연 후 일정 주기마다 정수를 방출하도록 합니다. <br> `take` 연산자로 방출하는 항목을 제한하지 않는다면 무한정 방출하므로 주의가 필요합니다. <br> 첫 번째 매개변수로 새로운 항목을 방출하기 전 `RxTimeInterval` 타입의 지연 시간을 전달해야 합니다. <br> 두 번째 매개변수로 새로운 항목을 방출하게 할 `RxTimeInterval` 타입의 주기를 전달해야 합니다. | - |

 ```swift
Observable<Int>.timer(.seconds(2), period: .seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
 ``` 

### timeout

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| timeout(_ dueTime:other:scheduler:) | 이 연산자는 `옵저버블`이 마지막으로 항목을 방출한 후 일정 주기 동안 아무런 항목을 방출하지 않는다면 `다른 옵저버블`에서 방출하는 항목을 방출합니다. <br> 첫 번째 매개변수로 `RxTimeInterval` 타입의 주기를 전달해야 합니다. <br> 두 번째 매개변수로 타임아웃이 발생할 경우 대신 방출할 `다른 옵저버블`을 전달해야 합니다.  | - |

 ```swift
let subject = PublishSubject<Int>()
let otherSource = Observable<Int>.just(-1)

subject
    .timeout(.seconds(3), other: otherSource, scheduler: MainScheduler.instance)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

Observable<Int>.timer(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe { subject.onNext($0) }
    .disposed(by: disposeBag)
 ```

 ### delay

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| delay(_ dueTime:scheduler:) | 이 연산자는 `옵저버블`이 항목을 방출하는 시간을 지연시킵니다. <br> 첫 번째 매개변수로 `RxTimeInterval` 타입의 지연 시간를 전달해야 합니다. | - |

 ```swift
var currentTimeString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter.string(from: Date())
}

Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .debug()
    .delay(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe { print(currentTimeString, $0) }
    .disposed(by: disposeBag)
 ```  

 ### delaySubscription

| 메서드               | 설명                 | 비고 |
|:-----------------: | :------------------ | :-- |
| delaySubscription(_ dueTime:other:scheduler:) | 이 연산자는 `옵저버블`이 `옵저버`를 구독하는 시점을 지연시킵니다. <br> 첫 번째 매개변수로 `RxTimeInterval` 타입의 지연 시간를 전달해야 합니다. | - |

 ```swift
Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .debug()
    .delaySubscription(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe { print(currentTimeString, $0) }
    .disposed(by: disposeBag)
 ``` 

## 참고 자료

* [ReactiveX 공식 문서](https://reactivex.io/documentation/operators.html)