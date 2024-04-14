---
title: "RxCocoa Traits(Driver, Signal) 알아보기 ①"
date: 2024-05-10 22:00:00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## Traits

`Traits`은 `Observable`의 기능을 제한하거나 추가해 특정 목적에 사용이 용이하도록 래핑(Wrapping)한 `Observable`입니다. `Traits`은 `Subject`를 래핑한 `Relay` 마냥 `Observable`을 래핑한 모양을 띄고 있습니다. 따라서 `Traits`은 직관적인 코드를 작성하는 데 많은 도움을 줍니다. 개발자는 UI 바인딩 등 여러 로직에 `Traits`을 선택적으로 적용할 수 있습니다. `Tratis`은 강제가 아니라 선택 사항이므로, 상황에 맞추어 적절하게 사용하면 가독성 높은 코드를 작성하는 데 많은 도움이 됩니다.

RxCocoa에서 `Traits`은 크게 `Driver`와 `Signal`로 나뉩니다. 이 `Traits`은 `Binder`와 비교해보면서 특징과 필요성을 알아보겠습니다.

### Driver

`Driver`는 `Binder`와 유사한 특징을 지니고 있는 `Traits`입니다. 에러 항목을 방출할 수 없으며, 메인쓰레드에서 실행을 보장합니다. `Observable`은 에러 항목을 방출하게 되면 구독(Subscription)이 종료되어 UI를 업데이트하지 못하게 됩니다. 이런 불상사를 막기 위해선 UI 업데이트할 때는 `Binder`나 해당 `Traits`를 사용해야 합니다. 그리고 `observe(on:)`이나 `subscribe(on:)` 연산자를 사용하지 않더라도 항상 메인 쓰레드(Main Thread)에서 실행을 보장해 UI 업데이트를 백그라운드 쓰레드(Background Thread)에서 할 수 있는 실수를 미연에 방지해줍니다.

이런 특징 덕분에 `Driver`는 UI 업데이트에 적합한 `Traits`입니다. 그렇다면 `Driver`는 언제 사용하면 좋을까요? 바로 (성능 상 이유로) **스트림을 공유**해야 할 필요가 있을 때 입니다. 

`Observer`가 `Observable`을 구독하면 스트림이 생성됩니다. 다른 `Observer`가 동일한 `Observable`을 구독해 새로운 스트림을 생성하더라도 이전에 생성된 스트림은 완전히 별개로 취급됩니다. `Observable`이 동일한 항목을 서로 다른 `Observer`에게 방출하는 상황에선 굉장히 비효율적입니다. 더군다나 해당 스트림이 네트워크 통신이라도 한다면 중복된 스트림은 더욱 지양해야 하겠지요. 이 같은 문제를 해결하기 위한 `Traits`이 바로 `Driver`입니다. 

`Driver`는 내부적으로 `share(replay: 1, scope: .whileConnected)` 연산자를 적용하고 있기에, 구독이 하나라도 유지되어 있다면 새로운 `Observer`에게 버퍼에 저장된 항목을 그대로 방출합니다. 

```swift
public typealias Driver<Element> = SharedSequence<DriverSharingStrategy, Element>

public struct DriverSharingStrategy: SharingStrategyProtocol {
    public static var scheduler: SchedulerType { SharingScheduler.make() }
    public static func share<Element>(_ source: Observable<Element>) -> Observable<Element> {
        source.share(replay: 1, scope: .whileConnected)
    }
}
```

> Sharing 연산자에 대한 자세한 내용은 [여기](https://rlarjsdn3.github.io/posts/RxSwift-연산자-정리-Sharing/)를 참조하세요.
{: .prompt-info }

아래는 불러온 포스트를 `Binder`로 UI 업데이트를 할 때 발생하는 문제점을 보여줍니다.

```swift
typealias PostType = [[String: Any]]
func fetchPost() -> Observable<PostType> {
    return Observable<PostType>.create { observer in
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                single(.failure(PostError.networkError))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                  let result = json as? PostType else {
                single(.failure(PostError.parsingError))
                return
            }
            
            single(.success(result))
        }
        
        task.resume()
        
        return Disposables.create()
    }
}
```

```swift
let results = fetchPost()

results // 스트림 ①
    .map { "\($0.count)" }
    .bind(to: countLabel.rx.text)
    .disposed(by: disposeBag)

results // 스트림 ②
    .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { (_, post, cell) in
        cell.textLabel?.text = "\(post.body)"
    }
    .disposed(by: disposeBag)
```

위 예제 코드의 문제는 스트림 ①에 이어 스트림 ②에서도 불필요한 네트워크 통신이 추가로 일어난다는 점입니다. 네트워크 통신은 비용이 많이 드는 작업이므로, 가능한 적게 할 필요가 있습니다. 이 같은 문제를 해결하기 위해 `Driver`를 사용하면 한 번의 네트워크 통신으로 필요한 UI 업데이트를 모두 해줄 수 있습니다.

```swift
let results = fetchPost().asDriver(onErrorJustReturn: [])

results // 스트림 ①
    .map { "\($0.count)" }
    .drive(countLabel.rx.text)
    .disposed(by: disposeBag)

results // 스트림 ①
    .drive(tableView.rx.items(cellIdentifier: "Cell")) { (_, post, cell) in
        cell.textLabel?.text = "\(post.body)"
    }
    .disposed(by: disposeBag)
```

먼저 `asDriver(onErrorJustReturn:)` 메서드로 `Observable`을 `Driver`로 변환시킬 수 있습니다. 그리고 `bind(to:)`가 아닌 `drive` 메서드로 바인딩(Binding)을 해야 합니다.


### Signal

`Signal`은 `Driver`와 유사하지만, 한 가지 다른 점이 있습니다. 바로 버퍼를 유지하지 않아 새로운 `Observer`에게 항목을 방출하지 않는다는 점입니다. `Signal`은 내부적으로 `share(replay: 0, scope: .whileConnected)` 연산자를 적용하고 있습니다.

```swift
public typealias Signal<Element> = SharedSequence<SignalSharingStrategy, Element>

public struct SignalSharingStrategy: SharingStrategyProtocol {
    public static var scheduler: SchedulerType { SharingScheduler.make() }
    
    public static func share<Element>(_ source: Observable<Element>) -> Observable<Element> {
        source.share(scope: .whileConnected)
    }
}
```


## 참고 자료

* [ReactiveX 공식 문서](https://reactivex.io/documentation/operators.html)

* [Driver. Signal](https://inuplace.tistory.com/1102)