---
title: "MVVM 패턴에 RxSwift 묻혀보기"
date: 2024-05-15 22:00:00 + 0900
categories: [개발 일기, RxSwift]
tags: [rxswift]
image: /assets/img/20231201/1.png
---

## MVVM 패턴이란?

프로그램을 개발할 때 디자인 패턴(Design Pattern, 이하 '패턴')을 올바르게 적용하는 건 개발 시간을 단축할 수 있을 뿐더러, 생산성을 향상시킬 수 있습니다. 디자인 패턴은 마치 **약속**과도 같습니다. 프로젝트 도중 새로운 개발자가 참여하더라도 빠르게 적응할 수 있도록 도와주며, 문제 해결 과정에서 원활한 커뮤니케이션(Communication)을 이끌도록 해줍니다. 프로그램 개발에 가장 대중적인 디자인 패턴은 `MVC`, `MVVM`과 `VIPER`가 있습니다.

![2](/assets/img/20240515/2.webp){: w="500" h="250" }

`MVVM(Model-View-ViewModel)` 패턴은 뷰(View)의 개발을 비즈니스 로직(Business Logic)과 모델(Model)로부터 분리해서, 뷰가 어느 특정한 계층에 종속되지 않도록 합니다. 뷰는 뷰-모델(ViewModel)을 알고 있지만, 뷰-모델과 모델(Model)은 뷰를 알지 못합니다. 그리고 뷰-모델은 모델을 알지 못하죠. 이런 구조는 테스트를 용이하게 만들어줍니다. 단순히 테스트하고픈 뷰-모델을 갈아 끼우기만 해도 전체 코드는 문제없이 작동합니다.

> **MVVM의 구성 요소** <br>
> **뷰(View):** `UILabel`, `UITextField`, `UISwitch`와 같은 사용자 인터페이스(UI)를 표시하고 사용자로부터 이벤트를 받습니다. 받은 이벤트는 모두 뷰-모델(ViewModel)에게 전달하고, 뷰-모델은 이를 처리해 다시 뷰에게 넘겨줍니다. 뷰는 UI를 업데이트하고 필요한 애니메이션 작업을 수행합니다. <br>
> **뷰-모델(ViewModel):** 뷰와 모델의 중간 계층에 위차한 뷰-모델은 뷰로부터 넘겨 받은 이벤트로 필요한 비즈니스 로직을 수행하고, 모델에 변화가 생기면 뷰가 사용하기 용이한 형태로 가공해 다시 넘겨줍니다. <br>
> **모델(Model):** 프로그램의 상태와 데이터를 표현합니다.
{: .prompt-info }
 
`MVVM` 패턴을 올바르게 적용하기 위해 꼭 기억해야 할 점은 로직이 **뷰 → 뷰-모델 → 모델 → 뷰-모델 → 뷰**로 흐르도록 해야 한다는 점입니다. 필요하다면 뷰-모델에서 네크워트 통신, DB 처리와 같은 사이드 이펙트(Side Effect)를 수행할 수 있습니다.

## Rx-MVVM 패턴 알아보기

그럼 이제 우리의 관심사에 집중해봅시다. 어떻게 하면 `MVVM` 패턴에 RxSwift를 묻힐 수 있을까요? 이벤트-기반 프로그래밍(Event-Driven Programming) 코드에 어떻게 하면 `MVVM` 패턴을 적용할 수 있을까요? 

### Input-Output

![3](/assets/img/20240515/3.jpg){: w="500" h="250" }

가장 널리 알려진 방식은 바로 뷰-모델을 `Input`과 `Output`으로 나누는 겁니다. `Input`은 사용자 인터페이스로부터 받는 이벤트를 나타내고, `Output`은 뷰-모델에서 넘겨 받은 이벤트로 필요한 비즈니스 로직을 수행한 결과를 의미합니다. 즉, 뷰에서 발생한 스트림이 `Input`을 거쳐 `transform(_:)` 메서드에서 필요한 사이드 이펙트를 수행하고 다시 `Output`으로 흘러가게 됩니다.

`transform(_:)`은 `Input`을 매개변수로 받아 `Output`을 반환하는 메서드입니다. 이 메서드에서 `map`, `reduce`, `combineLatest` 연산자를 활용해 전달받은 항목을 가공하거나, `flatMap`, `flatMapLateset` 연산자로 네트워크 통신, DB 처리와 같은 사이드 이펙트를 수행할 수 있습니다.

똑같은 `MVVM` 패턴이라 하더라도 그 방식은 차이가 날 수 있습니다. 가장 널리 알려진 방식으로 GitHub의 Repository를 검색한 결과를 출력하는 예제를 작성해보겠습니다. 사용한 라이브러리는 **RxSwift**, **RxCocoa**, **SnapKit**, **Then**입니다.

```swift
// ViewModelType.Swift
protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
```

```swift
// GitViewModel.swift

import Foundation

import RxSwift
import RxCocoa

final class GitViewModel: ViewModelType {
    
    // MARK: - Input
    struct Input {
        var inputText: Observable<String>
    }
    
    // MARK: - Output
    struct Output {
        var totalCount: Driver<Int>
        var repositories: Driver<[Item]>
    }
    
    // MARK: - Properties
    private let apiWorker = GitAPIWorker()
    
    // MARK: - Transform
    func transform(_ input: Input) -> Output {
        let repositories = input.inputText
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .flatMapLatest {
                self.apiWorker.fetchRepositorySearch($0)
            }
            .debug()
            .asDriver(onErrorJustReturn: [])
        
        let totalCount = repositories
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
        
        return Output(
            totalCount: totalCount,
            repositories: repositories
        )
    }
    
}
```

`Input`과 `Output`을 통해 사용자로부터 받을 이벤트와 UI 상태를 정의하였습니다. 우리 앱은 뷰로부터 텍스트 필드 입력을 이벤트로 받으므로, `Observable<String>` 타입의 `inputText` 프로퍼티 하나를 정의해주었습니다. 그리고 `transform(_:)` 메서드를 통해 리포지토리를 검색한 결과와 검색 개수를 `Output`에 담아 다시 뷰로 항목을 방출(emit)하고 있습니다. 

> 한 가지 주의할 점은 **스트림은 끊겨서는 아니돤다**입니다. 뷰-모델이나 사이드 이펙트에서 `Input`을 구독하고, 다시 새로운 스트림을 생성하는 건 이벤트-기반 프로그래밍이 가지는 장점을 퇴색시킵니다. (가능하면) 뷰에서 발생한 스트림은 끊기지 않고, 그대로 다시 되돌아와 뷰에서 구독해 필요한 UI 업데이트를 수행해야 합니다.
{: .prompt-warning }

```swift
// ViewControllerType.swift

import Foundation

import RxSwift

private struct AssociatedKeys {
    static var viewModel = "viewModel"
}

protocol ViewControllerType: AnyObject {
    associatedtype ViewModel: ViewModelType
    
    var disposeBag: DisposeBag { get set }
    
    var viewModel: ViewModel? { get set }
    
    func bind(viewModel: ViewModel)
}

extension ViewControllerType {
    private var underlyingViewModel: ViewModel? {
        get {
            return objc_getAssociatedObject(
                self,
                &AssociatedKeys.viewModel
            ) as? ViewModel
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.viewModel,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    var viewModel: ViewModel? {
        get {
            guard let viewModel = underlyingViewModel else {
                fatalError("ViewModel has not been set")
            }
            return viewModel
        }
        set {
            disposeBag = DisposeBag()
            if let vm = newValue {
                bind(viewModel: vm)
            }
            underlyingViewModel = newValue
        }
    }
}

```

`ViewControllerType` 프로토콜에서는 `disposeBag`, 뷰 컨트롤러가 가질 `viewModel` 프로퍼티와 바인딩에 필요한 `bind(viewModel:)` 메서드를 정의합니다. `viewModel` 프로퍼티를 프로토콜 확장을 통해서 기본 구현을 제공하고 있습니다. `ViewControllerType` 프로토콜을 준수하는 뷰 컨트롤러의 `viewModel` 프로퍼티에 `ViewModelType` 프로토콜을 준수하는 객체(Object)를 할당하면 자동으로 `bind(viewModel:)` 메서드가 호출됩니다. 뷰 컨트롤러에서 `bind(viewModel:)` 메서드를 호출할 수고를 덜 수 있습니다.

```swift
// SceneDelegate.swift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let vm = GitViewModel()
        let vc = GitViewController(viewModel: vm) // 자동으로 bind(viewModel:) 메서드가 호출됨
        window?.rootViewController = UINavigationController(rootViewController: vc)
        window?.makeKeyAndVisible()
    }

}
```

```swift
// ViewController.swift

import UIKit

import RxCocoa
import RxSwift
import Then
import SnapKit

final class GitViewController: UIViewController, ViewControllerType {

    // MARK: - Typealias
    typealias ViewModel = GitViewModel

    // MARK: - Views
    private var searchController = UISearchController()
    private var tableView = UITableView()
    private var totalCountLabel = UILabel()
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Intializer
    convenience init(viewModel: GitViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupAttributes()
    }

    // MARK: - Bind
    func bind(viewModel: GitViewModel) {        
        let input = GitViewModel.Input(
            inputText: searchController.searchBar.rx.text.orEmpty.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        output.repositories
            .drive(tableView.rx.items(cellIdentifier: TableViewCell.reuseId)) { index, item, cell in
                var config = cell.defaultContentConfiguration()
                config.text = item.fullName
                cell.contentConfiguration = config
            }
            .disposed(by: disposeBag)
        
        output.totalCount
            .map { "검색 리포지토리 수: \($0)" }
            .drive(totalCountLabel.rx.text)
            .disposed(by: disposeBag)
    }

    // <...하략...>
}
```

![4](/assets/img/20240515/4.gif){: w="300" h="250" }

짜잔🎉 이렇게 앱 하나가 완성되었습니다.

`bind(viewModel:)` 메서드에서는 `Input` 객체를 통해 사용자로부터 받을 이벤트를 정의하고, 이후 뷰 모델의 `transform(_:)` 메서드를 호출해 `Output` 객체을 반환받게 됩니다. 이렇게 반환된 `Output` 객체의 프로퍼티를 구독해 UI 업데이트에 필요한 작업을 수행할 수 있습니다.

> 자세한 코드는 [여기](https://github.com/rlarjsdn3/ex-rxmvvm-uikit-project)를 참조하세요.
{: .prompt-info }

## 참고 자료

* [Rx-MVVM의 올바른 사용법](https://velog.io/@dawn_dancer/iOS-Rx-MVVM의-올바른-사용법-saebyuckchoom)

* [RxSwift + MVVM 패턴 iOS에 적용해보기](https://mcflynn.tistory.com/25)