---
title: "삐삐의 핵심 뼈대인 ReactorKit 뿌셔보기"
date: 2024-04-05 22:00:00 + 0900
categories: [개발 일기, 디프만]
tags: [reactorKit, rxSwift, rxCocoa]
image: /assets/img/20240405/1.png
---

> 본 글은 [미디엄](https://medium.com/@55ing.team/삐삐의-핵심-뼈대인-reactorkit-뿌셔보기-8a819cd18c36)에 게시된 글을 그대로 옮겨온 글입니다.
{: .prompt-info }

안녕하세요. 디프만 14기의 삐삐팀으로 활동 중인 iOS 팀원 김건우입니다.

[삐삐(Bibbi)](https://github.com/bibbi-team)는 트렌드로 떠오르고 있는 반응형 프로그래밍(Reactive)을 기반으로 한 프로젝트입니다. 반응형 프로그래밍은 데이터의 흐름 및 변경 사항을 전파는 데 중점을 둔 프로그래밍 패러다임으로, 덕분에 Delegate 패턴이나 클로저를 전달하지 않고도 화면 간 데이터 흐름을 직관적으로 파악할 수 있게 되었습니다.

다음으로 우리 팀은 RxSwift를 프로젝트에 어떻게 적용할 지 고민에 빠졌습니다. 가장 보편적인 Input-Output 패턴으로 로직을 구현할 수 있겠지만, 조금 더 잘 규격화하기를 원했습니다. 프로젝트 규모가 커지더라도 (다른 팀원이 작성한 코드라도) 로직의 흐름이 한 눈에 보여 유지 보수를 용이하게 해주는 장치가 필요했습니다. 이때 기웃거리며 관심갖게 된 라이브러리가 바로 ReactorKit이었습니다.

## ReactorKit의 디자인 목표 

ReactorKit은 ReSwift와 Flux를 융합하여 만든 아키텍처입니다. ReactorKit은 로직을 단방향으로 흐르게 만들어 줍니다. 사용자가 만들어 낸 `Action`은 `Mutate`를 통해 `State`를 업데이트하고, 업데이트된 `State`를 UI에 반영합니다. ReSwift와 Flux 아키텍처와 크게 다르지 않습니다.

ReactorKit 공식 문서에 따르면 본 아키텍처의 디자인 목표를 아래와 같이 설명하고 있습니다.

* 테스트 용이: ReactorKit의 주요 목표는 뷰로부터 비즈니스 로직을 분리하는 것입니다. 이를 통해 테스트 용이한 코드를 작성할 수 있습니다. Reactor는 뷰에 아무런 의존성이 없으며, 그저 테스트 Reactor를 테스트 뷰에 바인딩시키면 됩니다. 자세한 내용은 [여기]()를 참조해주세요.
* 유연한 적용: ReactorKit은 전체 애플리케이션이 하나의 아키텍처를 따르게 할 필요가 없습니다. ReactorKit은 단일 또는 다중 뷰에 부분적으로 적용될 수 있습니다. 기존 프로젝트에서 모든 코드에 ReactorKit을 적용할 필요가 없습니다.
* 적은 타이핑: ReactorKit은 복잡함을 피하는 데 중점을 두었습니다. ReactorKit은 다른 아키텍처와 비교해 적은 코드를 필요로 합니다.

프로젝트를 하며 추가로 느낀 장점은 로직 흐름을 파악하기 쉽다는 점이었습니다. 불가피하게 다른 팀원이 작성한 코드를 수정해야 할 때가 있는데, 이러한 단방향 로직 흐름은 코드를 파악하기 휠씬 쉽게 만들어주었습니다. 

## ReactorKit은 어떻게 작동하나요?

Reactor는 네트워크 통신・디스크 I/O 등 뷰에 필요한 로직을 처리하고, UI를 업데이트시켜주는 레이어입니다. 즉, Reactor는 뷰로부터 제어 흐름(Control Flow)를 분리하고, 로직을 위임하는 역할을 합니다. 우리에게 익순한 MVVM패턴의 ViewModel을 대체하는 녀석입니다.

아래 그림은 Reactor의 제어 흐름이 어떻게 흐르는지 보여줍니다.

![2](/assets/img/20240405/2.png){: w="250" h="250" style="border:2px solid #eaeaea; border-radius: 14px; padding: 0px;" }

흐름은 매우 단순합니다. `Action`은 버튼 클릭과 같이 UI 반응을 나타냅니다. `State`는 뷰의 상태를 의미합니다. `Mutation`은 `Action`과 `State`를 이어주는 징검다리로 이어주는 역할을 합니다. `Mutation`에서 발생한 `Action`을 바탕으로 네트워크 통신・디스크 I/O 등 사이드 이펙트(Side Effect)를 수행해야 합니다.

![3](/assets/img/20240405/3.png){: w="250" h="250" style="border:2px solid #eaeaea; border-radius: 14px; padding: 0px;" }

아래 예제는 Reactor의 기본적인 제어 흐름을 보여줍니다.

### Mutate

사용자가 만들어 낸 `Action`은 `mutate(action:)` 메서드로 전달되어 `Observable<Mutate>`를 반환해야 합니다.

```swift
func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .didTapFollowButton(userId):
        return UserService.executeFollowUser(userId)
            .flatMap { success -> Observable<Mutation> in
                if success {
                    return Observable.concat(
                        Observable<Mutation>.just(.presentSuccessToastMessage),
                        Observable<Mutation>.just(.setFollowButtonTintColor(UIColor.Red))
                    )
                }
                return Observable<Mutation>.just(.presentFailureToastMessage)
            }
    }
}
```

위 예제는 팔로우 버튼 클릭 `Action`이 받게되면 흐르게 되는 로직을 보여줍니다. 팔로우 버튼을 클릭하면 전달된 userId를 바탕으로 서버와 통신을 하게 됩니다. 팔로우에 성공하면 성공 토스트 메시지(presentSuccessToastMessage)를 띄우고, 버튼의 색상을 빨강색으로(setFollowButtonTintColor) 바꿉니다. 팔로우에 실패하면 실패 토스트 메시지(presentFailureToastMessage)를 띄우게 됩니다.

 
### Reduce

그리고 `Mutation`은 `reduce(state:mutate:)` 메서드로 전달되어 `State`를 반환해야 합니다. 이렇게 업데이트된 `State`는 UI와 바인딩되어 UI를 업데이트합니다.

```swift
func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .setSuccessToastMessage:
        newState.shouldPresentSucessToastMessage = true
    case .setFailureToastMessage:
        newState.shouldPresentFailureToastMessage = true
    case let .setFollowButtonTintColor(color):
        newState.followButtonTintColor = color
    }
    return newState
}
```

ReactorKit을 처음 접할 무렵 `Mutation`의 필요성에 많은 의문이 들었습니다. `Action`과 `State`의 중간에 위치한 `Mutation`을 거치지 않고 곧바로 `State`로 향해도 별로 문제가 없어 보였습니다. 앞서 `Mutation` 예제 코드를 보시면 아시다피시, `Mutation`은 받은 `Action`을 토대로 해야 할 UI 업데이트를 쪼개주는 역할을 하고 있습니다. 코드의 중복을 줄이고, 유연함을 더하는 효과가 있습니다.

Reactor의 특징을 간략하게 살펴보았습니다. 이제 직접 Reactor를 작성해보며 조금 더 자세한 이야기를 해볼까 합니다.

## 직접 Reactor 작성해보기

텍스트 필드(TextField)에 소문자를 입력하면 대문자로 변환된 문자열과 문자열의 길이를 레이블(Label)에 출력하는 간단한 앱을 만들어 보겠습니다. 예제 프로젝트에 적용한 라이브러리는 `ReactorKit`, `RxSwift`, `RxCocoa`, `SnapKit`, `Then`입니다.

먼저 Reactor부터 작성하겠습니다. 뷰 컨트롤러(ViewController)에 바인딩되는 Reactor는 `Reactor` 프로토콜을 채택해야 합니다. `Reactor` 프로토콜은 `Action`, `Mutation`, `State` 엔터티와 `intialState` 프로퍼티를 가지고 있습니다.

```swift
public protocol Reactor: AnyObject {
  /// An action represents user actions.
  associatedtype Action

  /// A mutation represents state changes.
  associatedtype Mutation = Action

  /// A State represents the current state of a view.
  associatedtype State

  typealias Scheduler = ImmediateSchedulerType

  /// The action from the view. Bind user inputs to this subject.
  var action: ActionSubject<Action> { get }

  /// The initial state.
  var initialState: State { get }

  /// The current state. This value is changed just after the state stream emits a new state.
  var currentState: State { get }

  /// The state stream. Use this observable to observe the state changes.
  var state: Observable<State> { get }

  // <...이하 후략...>
}
```

우리가 작성할 Reactor는 텍스트 필드 입력 하나와 대문자로 변환된 문자열, 문자열의 길이라는 출력 두 개를 가집니다. 하나의 `Action`과 두 개의 `State`를 가지는 거죠.

```swift
// TextFieldViewReactor.swift

import UIKit

import ReactorKit
import RxSwift

final class TextFieldViewReactor: Reactor {
    // MARK: - Action
    enum Action {
        case inputField(String)
    }
    
    // MARK: - Mutation
    enum Mutation {
        case setLengthOfString(Int)
        case setCapitalizedString(String)
    }
    
    // MARK: - State
    struct State {
        var capitalizedString: String?
        var lengthOfString: Int?
    }
    
    // MARK: - Properties
    var initialState: State
    
    // MARK: - Intializer
    init() {
        self.initialState = State()
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .inputField(input):
            let lengthOfString = input.count
            let capitalizedString = input.uppercased()
            return Observable<Mutation>.concat(
                Observable.just(.setLengthOfString(lengthOfString)),
                Observable.just(.setCapitalizedString(capitalizedString))
            )
        }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLengthOfString(length):
            newState.lengthOfString = length
        case let .setCapitalizedString(string):
            newState.capitalizedString = string
        }
        return newState
    }
}
```

특정 Reactor와 바인딩하기 위해 뷰 컨트롤러는 `View` 프로토콜을 채택해야 합니다. `View` 프로토콜은 `reactor` 프로퍼티와 `bind(reactor:)` 메서드를 가지고 있습니다.

```swift
public protocol View: AnyObject {
  associatedtype Reactor: ReactorKit.Reactor

  /// A dispose bag. It is disposed each time the `reactor` is assigned.
  var disposeBag: DisposeBag { get set }

  /// A view's reactor. `bind(reactor:)` gets called when the new value is assigned to this property.
  var reactor: Reactor? { get set }

  /// Creates RxSwift bindings. This method is called each time the `reactor` is assigned.
  ///
  /// Here is a typical implementation example:
  ///
  /// ```
  /// func bind(reactor: MyReactor) {
  ///   // Action
  ///   increaseButton.rx.tap
  ///     .bind(to: Reactor.Action.increase)
  ///     .disposed(by: disposeBag)
  ///
  ///   // State
  ///   reactor.state.map { $0.count }
  ///     .bind(to: countLabel.rx.text)
  ///     .disposed(by: disposeBag)
  /// }
  /// ```
  ///
  /// - warning: It's not recommended to call this method directly.
  func bind(reactor: Reactor)
}
```

`reactor` 프로퍼티에 Reactor를 할당하거나 수정하면 `bind(reactor:)` 메서드가 자동으로 호출되면서 Reactor와 뷰 컨트롤러가 바인딩됩니다. 

```swift
// SceneDelegate.swift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(
      _ scene: UIScene, 
      willConnectTo session: UISceneSession, 
      options connectionOptions: UIScene.ConnectionOptions
      ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let reactor = TextFieldViewReactor()
        let textfieldViewController = TextFieldViewController(reactor: reactor)
        
        window?.windowScene = windowScene
        window?.rootViewController = UINavigationController(rootViewController: textfieldViewController)
        window?.makeKeyAndVisible()
    }
}
```

```swift
// TextFieldViewController.swift

import UIKit

import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa

final class TextFieldViewController: UIViewController, View {

    // MARK: - Typealias
    typealias Reactor = TextFieldViewReactor
    
    // MARK: - Views
    var textfield: UITextField = UITextField()
    var capitalizedStringLabel: UILabel = UILabel()
    var lengthOfStringLabel: UILabel = UILabel()
    
    var stackView: UIStackView = UIStackView()
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Intializer
    convenience init(reactor: TextFieldViewReactor) {
        self.init()
        self.reactor = reactor
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAutoLayout()
        setupAttributes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textfield.resignFirstResponder()
    }
    // MARK: - Reactor
    func bind(reactor: TextFieldViewReactor) {
        textfield.rx.text.orEmpty 
            .map { Reactor.Action.inputField($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.capitalizedString }
            .distinctUntilChanged()
            .bind(to: capitalizedStringLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.lengthOfString }
            .map { "\($0)" }
            .distinctUntilChanged()
            .bind(to: lengthOfStringLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Attributes
    func setupUI() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(capitalizedStringLabel)
        stackView.addArrangedSubview(lengthOfStringLabel)
        stackView.addArrangedSubview(textfield)
    }
    
    func setupAutoLayout() {
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(10)
        }
    }
    
    func setupAttributes() {
        view.backgroundColor = UIColor.white
        
        stackView.do { view in
            view.axis = .vertical
            view.alignment = .fill
            view.distribution = .fillProportionally
            view.spacing = 10
        }
        
        textfield.do { view in
            view.borderStyle = .bezel
        }
        textfield.becomeFirstResponder()
    }
}
```

![4](/assets/img/20240405/4.gif){: w="250" h="250" style="border:2px solid #eaeaea; border-radius: 14px; padding: 0px;" }

짜잔🎉 이렇게 앱 하나가 완성되었습니다. 이제 끝이라고 하고 싶지만, 그 전에 우리가 살펴보아야 할 중요한 포인트가 몇 가지 있습니다.

### Reactor는 intialState도 방출

Reactor는 뷰 컨트롤러에서 `bind(reactor:)` 메서드를 호출하면 곧바로 `intialState`를 방출합니다. 이를 통해 뷰가 보여질 때(viewIsAppearing) 최초 상태를 정할 수 있습니다. 아래 예제에서 `TextFieldViewController`의 배경 색상(BackgroundColor)을 변경하였습니다. 만약 바인딩 시 `initialState`가 방출되지 않기를 원한다면 `State`의 프로퍼티에 `nil`을 할당하거나, `skip` 연산자로 스트림을 한 번 무시해야 합니다.

```swift
// SceneDelegate.swift 

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // <...중략...>
        
        let reactor = TextFieldViewReactor(backgroundColor: UIColor.systemTeal)
        let textfieldViewController = TextFieldViewController(reactor: reactor)
        
        window?.windowScene = windowScene
        window?.rootViewController = UINavigationController(rootViewController: textfieldViewController)
        window?.makeKeyAndVisible()
    }
}
```

```swift
// TextFieldViewController.swift

final class TextFieldViewController: UIViewController, View {

    // <...전략...>
    
    // MARK: - Reactor
    func bind(reactor: TextFieldViewReactor) {
        // <...중략...>
        
        // ⭐️
        reactor.state.map { $0.backgroundColor }
            .distinctUntilChanged()
            .bind(to: view.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    // <...후략...>
}

```

![5](/assets/img/20240405/5.png){: w="250" h="250" style="border:2px solid #eaeaea; border-radius: 14px; padding: 0px;" }

### DistinctUntilChanged 연산자

위 예제를 보면 모든 스트림에 `distinctUntilChanged` 연산자가 붙어있습니다. `distinctUntilChanged` 연산자는 방출하고자 하는 항목이 이전에 방출한 항목과 동일하다면 스트림을 막는 연산자입니다. 이러한 연산자가 붙어있는 이유는 Reactor의 독특한 특성에 기인합니다. Reactor는 `State`의 프로퍼티 중 하나라도 값이 재할당되면 다른 프로퍼티의 값 할당 유무에 상관없이 전체 `State`를 항목으로 방출(`Observable<State>`)합니다. 즉, 위 예제에서 `capitalizedString` 프로퍼티에만 값이 재할당되더라도, 이와 상관없는 `lengthOfString` 프로퍼티도 함께 전체 `State` 항목으로 방출됩니다.

즉, 새로운 값이 할당되지 않은 `State`는 굳이 UI를 업데이트해 줄 필요가 없기 때문에, 불필요한 스트림을 막기 위해 `distinctUntilChanged` 연산자를 사용합니다.

하지만, 무조건 값이 바뀌어야만 UI를 업데이트해야 할까요? 세상일이 으레 그렇듯이 꼭 그래야만 하는 법은 없습니다. 


## Reactor 흐름을 제어하는 @Pulse 키워드

`@Pulse`는 Reactor의 흐름을 제어할 수 있는 프로퍼티 래퍼(Property Wrapper)입니다. `@Pulse` 프로퍼티 래퍼로 선언된 `State`의 프로퍼티는 새로운 값이 (심지어 동일한 값이더라도) 할당될 때만 해당 프로퍼티를 항목으로 방출합니다.

앞서 예제에서 텍스트 필드에 영문자가 아닌 숫자가 입력되면 경고창(Alert)을 띄우도록 기능을 추가해보겠습니다.

```swift
// TextFieldViewReactor.swift

final class TextFieldViewReactor: Reactor {
    // <...전략...>
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .inputField(input):
            // ⭐️
            if input.isNumber {
                return Observable<Mutation>.just(.showAlertMessage("소문자를 입력할 수 없습니다."))
            } else {
                let lengthOfString = input.count
                let capitalizedString = input.uppercased()
                return Observable<Mutation>.concat(
                    Observable.just(.setCapitalizedString(capitalizedString)),
                    Observable.just(.setLengthOfString(lengthOfString))
                )
            }
        }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setCapitalizedString(string):
            newState.capitalizedString = string
        case let .setLengthOfString(length):
            newState.lengthOfString = length
        // ⭐️
        case let .showAlertMessage(message):
            newState.alertMessage = message
        }
        return newState
    }
}

// ⭐️
extension String {
    var isNumber: Bool {
        return self.range(
            of: ".*[0-9]+.*",
            options: .regularExpression) != nil
    }
}

```

```swift
// TextFieldViewController.swift

final class TextFieldViewController: UIViewController, View {

    // <...전략...>
    
    // MARK: - Mutation
    enum Mutation {
        case setCapitalizedString(String)
        case setLengthOfString(Int)
        
        // ⭐️
        case showAlertMessage(String)
    }
    
    // MARK: - State
    struct State {
        var backgroundColor: UIColor?
        
        var lengthOfString: Int?
        var capitalizedString: String?
        
        // ⭐️
        @Pulse var alertMessage: String?
    }

    // <...중략...>

    // MARK: - Reactor
    func bind(reactor: TextFieldViewReactor) {
        // <...중략...>
        
        // ⭐️
        reactor.pulse(\.$alertMessage)
            .compactMap { $0 }
            .bind(with: self) {
                $0.showWarningAlert($1)
            }
            .disposed(by: disposeBag)
        
        // <...중략...>
    }
    
    // <...후략...>
}

// MARK: - Extensions
extension TextFieldViewController {
    // ⭐️
    func showWarningAlert(_ message: String) {
        // Clear all field and labels
        textfield.text?.removeAll()
        lengthOfStringLabel.text = "0"
        capitalizedStringLabel.text?.removeAll()
        
        // Show warning alert
        let alert = UIAlertController(
            title: "입력 오류",
            message: message,
            preferredStyle: .alert
        )
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
}

```

![6](/assets/img/20240405/6.gif){: w="250" h="250" style="border:2px solid #eaeaea; border-radius: 14px; padding: 0px;" }

짜잔🎉 잘 작동하죠?

그렇다면 앞서 예제에서 ⌜`distinctUntilChanged` 연산자만 삭제하면 비슷하지 않으냐⌟고 의문이 드실 수도 있습니다. 앞서 말씀드렸다시피, Reactor는 `State`의 프로퍼티 중 하나라도 값이 재할당되면 다른 프로퍼티의 값 할당 유무에 상관없이 전체 `State`를 항목으로 방출(`Observable<State>`)합니다. 즉, `@Pulse` 프로퍼티 래퍼로 `alertMessage` 프로퍼티를 선언하지 않고 `distinctUntilChanged` 연산자를 붙여주지 않는다면, `capitalizedString` 프로퍼티에만 값이 재할당되더라도, 이와 상관없는 `alertMessage` 프로퍼티도 함께 전체 `State` 항목으로 방출되어 경고창이 뜨게 됩니다. 텍스트 필드에 입력할 때마다 경고창이 뜨게 되는 거죠. 그렇다고 `@Pulse` 프로퍼티 래퍼는 빼버리고 `distinctUntilChanged` 연산자만 붙이면 동일한 `alertMessage`를 스트림으로 받지 못하게 되겠죠.

뷰 컨트롤러에서 `@Pulse` 프로퍼티 래퍼로 선언된 `State`의 프로퍼티를 바인딩할 때, `pulse(_:)` 메서드를 사용해야 합니다. 이는 `pulse(_:)` 메서드의 코드를 살펴보면 쉽게 이해할 수 있습니다.

```swift
@propertyWrapper
public struct Pulse<Value> {

  public var value: Value {
    didSet {
      riseValueUpdatedCount()
    }
  }

  public internal(set) var valueUpdatedCount = UInt.min

  public init(wrappedValue: Value) {
    self.value = wrappedValue
  }

  public var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }

  public var projectedValue: Pulse<Value> {
    self
  }

  private mutating func riseValueUpdatedCount() {
    valueUpdatedCount &+= 1
  }
}
```

```swift
extension Reactor {
  /// Returns an observable sequence that emits the value of the pulse only when its valueUpdatedCount changes.
  ///
  /// - seealso: [Pulse document](https://github.com/ReactorKit/ReactorKit/blob/master/Documentation/Contents/Pulse.md)
  /// - seealso: [The official document introduction](https://github.com/ReactorKit/ReactorKit#pulse)
  ///
  /// - parameter transformToPulse: A transform function to apply to the current state of the reactor
  /// to produce a pulse.
  /// - returns: An observable that emits the value of the pulse whenever its valueUpdatedCount changes.
  public func pulse<Result>(_ transformToPulse: @escaping (State) throws -> Pulse<Result>) -> Observable<Result> {
    state.map(transformToPulse).distinctUntilChanged(\.valueUpdatedCount).map(\.value)
  }
}
```

`@Pulse` 프로퍼티 래퍼의 코드를 살펴보면 `valueUpdatedCount` 프로퍼티가 있습니다. 해당 프로퍼티에 새로운 값이 할당될 때마다 `riseValueUpdatedCount()` 메서드에 의해 `valueUpdatedCount` 프로퍼티에 1 증가된 값이 할당됩니다. 그리고 아래 예제 코드에서 `pulse(_:)` 메서드는 해당 프로퍼티의 `valueUpdatedCount` 값이 바뀐 경우에만 항목을 방출하도록 하고 있습니다. 복잡해보이는 키워드지만, 알고보면 굉장히 단순한 원리가 숨어있답니다.


## 다른 뷰에 이벤트를 전달하는 GlobalState

ReactorKit을 처음 접하며 제일 난감했던 점 중 하나는 ⌜뷰 컨트롤러 간 이벤트 전달을 어떻게 처리할 지⌟였습니다. 다행히도 ReactorKit은 `transform(_:)` 메서드를 통해 다른 뷰 컨트롤러에서 방출하는 이벤트를 받아 손쉽게 UI를 업데이트할 수 있습니다.

GlobalState는 어느 Reactor에도 종속되지 않은 독립적인 전역 객체로, `PublishSubject`나 `BehaviorSubject`를 통해 서로 항목을 주고 받아 하위 뷰 컨트롤러가 상위 뷰 컨트롤러에게 필요한 로직을 처리하게 지시할 수 있습니다.

앞서 예제에서 `SettingsViewController`를 추가하고, 해당 뷰 컨트롤러에서 `TextFieldViewController`의 배경 색상을 무작위로 바꾸는 기능을 추가해 보겠습니다. 

```swift
// ServiceProvider.swift

import UIKit

import RxSwift

class BaseService {
    unowned let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
}

enum SettingEvent {
    case setBackgroundColor(UIColor?)
}

protocol SettingServiceProtocol {
    var event: PublishSubject<SettingEvent> { get }
    
    @discardableResult
    func setBackgroundColor(_ color: UIColor?) -> Observable<UIColor?>
}

final class SettingService: BaseService, SettingServiceProtocol {
    var event: PublishSubject<SettingEvent> = PublishSubject<SettingEvent>()
    
    func setBackgroundColor(_ color: UIColor?) -> Observable<UIColor?> {
        event.onNext(.setBackgroundColor(color))
        return Observable<UIColor?>.just(color)
    }
}


protocol ServiceProviderProtocol: AnyObject {
    var settings: SettingServiceProtocol { get }
}

final class ServiceProvider: ServiceProviderProtocol {
    lazy var settings: SettingServiceProtocol = SettingService(provider: self)
}

```

```swift
// SettingsViewReactor.swift

import UIKit

import ReactorKit
import RxSwift

final class SettingViewReactor: Reactor {
    // MARK: - Action
    enum Action {
        case didTapButton
    }
    
    // MARK: - Mutation
    enum Mutation {
        case setBackgroundColor(UIColor?)
    }
    
    // MARK: - State
    struct State {
        var backgroundColor: UIColor?
    }
    
    // MARK: - Properties
    var initialState: State
    var provider: ServiceProviderProtocol
    
    let colors: [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemTeal, .systemGreen]
    
    // MARK: - Intializer
    init(
        backgroundColor color: UIColor? = nil,
        service provider: ServiceProviderProtocol
    ) {
        self.initialState = State(
            backgroundColor: color
        )
        self.provider = provider
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapButton:
            let color = colors.randomElement()
            provider.settings.setBackgroundColor(color) // ⭐️
            return Observable<Mutation>.just(.setBackgroundColor(color))
        }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setBackgroundColor(color):
            newState.backgroundColor = color
        }
        return newState
    }
}
```

```swift
// SettingsViewController.swift

import UIKit

import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa

final class SettingViewController: UIViewController, View {

    // MARK: - Typealias
    typealias Reactor = SettingViewReactor
    
    // MARK: - Views
    var button: UIButton = UIButton(configuration: .borderedProminent())
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Intializer
    convenience init(reactor: SettingViewReactor) {
        self.init()
        self.reactor = reactor
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAutoLayout()
        setupAttributes()
    }
    
    // MARK: - Reactor
    func bind(reactor: SettingViewReactor) {
        button.rx.tap
            .map { Reactor.Action.didTapButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.backgroundColor }
            .distinctUntilChanged()
            .bind(to: view.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Attributes
    func setupUI() {
        view.addSubview(button)
    }
    
    func setupAutoLayout() {
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setupAttributes() {
        button.do {
            $0.setTitle("색상 바꾸기", for: .normal)
        }
    }
}
```

```swift
// TextFieldViewReactor.swift

final class TextFieldViewReactor: Reactor {
    // MARK: - Action
    enum Action {
        case inputField(String)
        case didTapSettingButton // ⭐️
    }
    
    // MARK: - Mutation
    enum Mutation {
        case setBackgroundColor(UIColor?)
        
        case setCapitalizedString(String)
        case setLengthOfString(Int)
        
        case showAlertMessage(String)
        case pushSettingViewController(UIViewController?) // ⭐️
    }
    
    // MARK: - State
    struct State {
        var backgroundColor: UIColor?
        
        var lengthOfString: Int?
        var capitalizedString: String?
        
        @Pulse var alertMessage: String?
        @Pulse var settingViewController: UIViewController? // ⭐️
    }
    
    // MARK: - Properties
    var initialState: State
    var provider: ServiceProviderProtocol // ⭐️
    
    // MARK: - Intializer
    init(
        backgroundColor color: UIColor? = nil,
        service provider: ServiceProviderProtocol // ⭐️
    ) {
        self.initialState = State(
            backgroundColor: color
        )
        self.provider = provider
    }
    
    // MARK: - Transform
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        // ⭐️
        let eventMutation = provider.settings.event
            .flatMap { event in
                switch event {
                case let .setBackgroundColor(color):
                    return Observable<Mutation>.just(.setBackgroundColor(color))
                }
            }
        
        return Observable<Mutation>.merge(mutation, eventMutation)
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .inputField(input):
            if input.isNumber {
                return Observable<Mutation>.just(.showAlertMessage("소문자를 입력할 수 없습니다."))
            } else {
                let lengthOfString = input.count
                let capitalizedString = input.uppercased()
                return Observable<Mutation>.concat(
                    Observable.just(.setCapitalizedString(capitalizedString)),
                    Observable.just(.setLengthOfString(lengthOfString))
                )
            }
        // ⭐️
        case .didTapSettingButton:
            let reactor = SettingViewReactor(
                backgroundColor: currentState.backgroundColor,
                service: provider
            )
            let viewController = SettingViewController(reactor: reactor)
            return Observable<Mutation>.just(.pushSettingViewController(viewController))
        }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setBackgroundColor(color):
            newState.backgroundColor = color
        case let .setCapitalizedString(string):
            newState.capitalizedString = string
        case let .setLengthOfString(length):
            newState.lengthOfString = length
        case let .showAlertMessage(message):
            newState.alertMessage = message
        // ⭐️
        case let .pushSettingViewController(vc):
            newState.settingViewController = vc
        }
        return newState
    }
}

// <...후략...>
```

```swift
// TextFieldViewController.swift


final class TextFieldViewController: UIViewController, View {

    // <...전략...>

    // MARK: - Views
    var settingButton: UIButton = UIButton(configuration: .borderedProminent())
    
    var stackView: UIStackView = UIStackView()

    // <...중략...>
    
    // MARK: - Reactor
    func bind(reactor: TextFieldViewReactor) {
        textfield.rx.text.orEmpty
            .map { Reactor.Action.inputField($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // ⭐️
        settingButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapSettingButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // ⭐️
        reactor.pulse(\.$settingViewController)
            .compactMap { $0 }
            .bind(with: self) { owner, vc in
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // <...후략...>
}
```

![7](/assets/img/20240405/7.gif){: w="250" h="250" style="border:2px solid #eaeaea; border-radius: 14px; padding: 0px;" }

짜잔🎉 이제 정말로 끝났습니다. 코드가 꽤 복잡해 보이지만, 한번 잘 만들어 놓으면 정말 편하게 사용할 수 있습니다.

> `transform(_:)` 메서드에 대한 자세한 내용은 [여기](https://github.com/ReactorKit/ReactorKit/blob/master/Sources/ReactorKit/Reactor.swift)를 참조해주세요.
{: .prompt-info }

## 마무리

ReactorKit은 Rewift와 Flux를 융합하여 만든 아키텍처로, 단방향 데이터 흐름을 제공하여 뷰와 비즈니스 로직을 분리하고 테스트 용이성을 높입니다. 유연하게 적용할 수 있으며, 코드 작성량을 줄이고 로직 흐름을 명확하게 파악할 수 있습니다. 이는 팀 내 협업을 용이하게 하고, 코드 유지 보수성을 향상시킵니다. 따라서 ReactorKit은 애플리케이션 개발에 매우 유용한 아키텍처입니다.


## 참고 자료 

* [ReactorKit](https://github.com/ReactorKit)
* [@Pulse](https://phillip5094.tistory.com/106)
* [ReactorKit - Pulse](https://kickbell.github.io/ReactorKit-Pulse-KR/)
* [iOS ReactorKit 톺아보기](https://oliveyoung.tech/blog/2023-05-20/OliveYoung-iOS-ReactorKit/)
* [ReactorKit으로 단방향 반응형 앱 만들기](https://www.youtube.com/watch?v=ASwBnMJNUK4&t=5s)