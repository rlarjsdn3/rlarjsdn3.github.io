---
title: "RxSwift Traits(Single, Completable, Maybe) 알아보기"
date: 2024-04-20 22:00:00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## Traits

`Traits`은 `Observable`의 기능을 제한하거나 추가해 특정 목적에 사용이 용이하도록 래핑(Wrapping)한 `Observable`입니다. `Traits`은 `Subject`를 래핑한 `Relay` 마냥 `Observable`을 래핑한 모양을 띄고 있습니다. 따라서 `Traits`은 직관적인 코드를 작성하는 데 많은 도움을 줍니다. 개발자는 네트워크 통신, 디스크 I/O 등 여러 로직에 `Traits`을 선택적으로 적용할 수 있습니다. `Tratis`은 강제가 아니라 선택 사항이므로, 상황에 맞추어 적절하게 사용하면 가독성 높은 코드를 작성하는 데 많은 도움이 됩니다.

RxSwift에서 `Traits`은 크게 `Single`, `Completable`과 `Maybe`로 나뉩니다. 각 `Traits`의 특징은 **어떤 종류의 항목을 방출할 수 있냐**는 차이 밖에 없습니다.

### Single

`Single`은 단 하나의 `success` 혹은 `failure` 항목을 방출하는 `Traits`입니다. `next`와 `complete`을 합친 항목이 바로 `success`입니다. `failure`는 `error` 항목과 같습니다. 

네트워크 통신 결과 혹은 실패와 같은 항목을 전파하는 데 주로 사용되는 `Traits`입니다. 네트워크 통신에 성공한다면 그 결과를 `success` 항목과 함께 방출하고, 그렇지 않다면 `failure` 항목을 방출합니다. 아래는 `Single`로 네트워크 통신을 하는 방법을 보여줍니다.

```swift
typealias PostType = [[String: Any]]
func fetchPost() -> Single<PostType> {
    return Single<PostType>.create { single in
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                single(.failure(MyError.networkError))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                  let result = json as? PostType else {
                single(.failure(MyError.parsingError))
                return
            }
            
            single(.success(result))
        }
        
        task.resume()
        
        return Disposables.create()
    }
}

fetchPost()
    // ⭐️ event의 타입은 Result<PostType, Error>
    .subscribe { result in
        switch result {
        case let .success(post):
            print("Post Fetch Result: \(post)")
        case let .failure(error):
            print("Error: \(error)")
        }
    }
    .disposed(by: disposeBag)

```

해당 `Traits`은 네트워크 통신한 결과를 담은 `.success`와 에러를 담은 `.failure`가 포함된 `Result` 타입을 항목으로 방출합니다. 그리고 처음부터 `Single`을 반환하는 게 아닌 `asSingle()` 연산자로 기존 `Observable`을 `Single`로 변환하는 게 가능합니다. 


### Completable

`Completable`은 단 하나의 `completed` 혹은 `failure` 항목을 방출하는 `Traits`입니다. `Single`과는 다르게 어느 결과가 담긴 항목을 방출하지 않습니다. 오직 성공 혹은 실패와 같은 항목을 전파하는 데 주로 사용되는 `Traits`입니다.

성공 값을 방출하는 `Single`과는 다르게 오직 성공과 실패 여부만 알고 싶을 때 주로 사용되는 `Traits`입니다. 디스크에 이미지를 저장하는 데 성공했다면 별다른 성공 값을 받을 필요없이 성공했다는 사실만 전달받으면 됩니다. 이때 `Completable`을 사용할 수 있습니다. 아래는 `Completable`로 네트워크 통신을 하는 방법을 보여줍니다.

```swift
typealias PostType = [[String: Any]]
func fetchPost() -> Completable {
    return Completable.create { completable in
        // <...전략...>
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                completable(.error(MyError.networkError))
                return
            }
            
            completable(.completed)
        }
        // <...후략...>
    }
}

fetchPost()
    .subscribe{ result in
        switch result {
        case .completed:
            print("Post Fetch Completed")
        case let .error(error):
            print("Error: \(error)")
        }
    }
    .disposed(by: disposeBag)

```

### Maybe

`Maybe`는 `Single`과 `Completable`을 적절히 혼합한 형태의 `Traits`입니다. `Maybe`는 `success`, `completed` 혹은 `failure` 항목을 방출할 수 있습니다. 그래서 실직적인 값이 담긴 항목을 방출할 수도 있고, 하지 않을 수 있습니다. 

아래 예제는 `Maybe`가 방출하는 항목의 유형을 보여줍니다.

```swift
let disposeBag: DisposeBag = DisposeBag()

enum MyError: Error {
    case invaildString
}

func generateString(_ string: String) -> Maybe<String> {
    return Maybe<String>.create { maybe in
        switch string {
        case "Swift":
            maybe(.success(string))
        case "SwiftUI":
            maybe(.completed)
        default:
            maybe(.error(MyError.invaildString))
        }
        
        return Disposables.create()
    }
}

generateString("Swift")
    .subscribe { result in
        switch result {
        case let .success(string):
            print("String: \(string)")
        case .completed:
            print("Completed")
        case let .error(error):
            print("Error: \(error)")
        }
    }
    .disposed(by: disposeBag)
```

## 참고 자료

* [ReactiveX 공식 문서](https://reactivex.io/documentation/operators.html)

* [Traits가 뭘까? (Single, Maybe, Completable)](https://beenii.tistory.com/126)

* [Single Trait - 장단점](https://minsone.github.io/programming/rxswift-single-traits)