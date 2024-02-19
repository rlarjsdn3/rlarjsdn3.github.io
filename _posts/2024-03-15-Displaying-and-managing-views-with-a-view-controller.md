---
title: "[번역] Displaying and managing views with a view controller (애플 공식 문서)"
date: 2024-03-15 22:00:00 + 0900
categories: [개발 일기, UIKit]
tags: [uikit]
image: /assets/img/20240315/1.png
---

> 본 글은 [Displaying and managing views with a view controller (애플 공식 문서)](https://developer.apple.com/documentation/uikit/view_controllers/displaying_and_managing_views_with_a_view_controller)를 한국어로 번역하여 옮긴 글입니다.
{: .prompt-info }

스토리보드(Storyboard)로 뷰 컨트롤러를 빌드하고, 뷰 컨트롤러와 함께 커스텀 뷰를 구성하고, 해당 뷰에 앱의 데이터를 채워넣으세요.

## Overview

Model-View-Controller(MVC) 디자인 패턴에서 뷰 컨트롤러는 화면에 정보를 보여주는 뷰 객체와 앱의 컨텐츠를 저장한 데이터 객체 사이에 위치하고 있습니다. 조금 더 구체적으로 말하자면, 뷰 컨트롤러는 뷰를 항상 최신 상태로 유지시키기 위해 필요한 상태 정보와 뷰 계층 구조(View Hierarchy)를 관리하고 있습니다. 모든 UIKit 앱은 컨텐츠를 보여주기 위해 뷰 컨트롤러에 많은 의존을 하고 있고, 개발자는 앱의 뷰와 UI와 관련된 로직을 관리하기 위해 커스텀 뷰 컨트롤러를 정의하고 있습니다.

개발자가 생성하는 대부분의 커스텀 뷰 컨트롤러는 컨텐츠 뷰 컨트롤러(Content ViewController)입니다. 이는 뷰 컨트롤러가 모든 뷰를 가지며 해당 뷰와의 상호 작용을 관리한다는 걸 의미합니다. 컨텐츠 뷰 컨트롤러를 사용해 앱의 커스텀 컨텐츠를 보여주고, 뷰 컨트롤러 객체를 사용해 커스텀 뷰로 데이터를 보내거나 받도록 관리할 수 있습니다.

 ![2](/assets/img/20240315/2.png){: w="500" h="250" }

> **Note** <br>
> 컨텐츠 뷰 컨트롤러와 반대로, 컨테이너 뷰 컨트롤러(Container ViewController)는 뷰 계층 구조 상에서 다른 뷰 컨트롤러의 컨텐츠를 포함하도록 할 수 있습니다. [UINavigationController](https://developer.apple.com/documentation/uikit/uinavigationcontroller)가 컨테이너 뷰 컨트롤러의 대표적인 예입니다. 컨테이너 뷰 컨트롤러를 구현하는 방법은 [Implementing a Custom Container ViewController](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/ImplementingaContainerViewController.html#//apple_ref/doc/uid/TP40007457-CH11-SW12)를 참조하시기 바랍니다.
{: .prompt-tip }

컨텐츠 뷰 컨트롤러를 정의하려면 [UIViewController](https://developer.apple.com/documentation/uikit/uiviewcontroller)를 서브클래싱을 해야 합니다. 만약 인터페이스에 테이블 뷰나 컬렉션 뷰가 포함되어 있다면, [UITableViewController](https://developer.apple.com/documentation/uikit/uitableviewcontroller)나 [UICollectionViewController](https://developer.apple.com/documentation/uikit/uicollectionviewcontroller)를 대신 서브클래싱을 해야 합니다. 새로운 Xcode 프로젝트에는 개발자가 수정할 수 있는 하나 또는 그 이상의 컨텐츠 뷰 컨트롤러를 포함하고 있으며, 필요하다면 추가도 할 수 있습니다.

## Add views to your view controller

[UIViewController](https://developer.apple.com/documentation/uikit/uiviewcontroller)는 [view](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621460-view) 프로퍼티로 접근할 수 있는 컨텐츠 뷰(Content View)를 포함하고 있습니다. 해당 뷰는 뷰 계층 구조 상에서 루트 뷰(Root View)의 역할을 합니다. 해당 뷰에서 개발자는 인터페이스로 보여주고 싶은 커스텀 뷰를 추가해야 합니다. 스토리보드에서는 (라이브러리에서) 뷰 컨트롤러 씬(Scene)으로 드래깅을 함으로써 커스텀 뷰를 추가할 수 있습니다. 예를 들어, 아래 그림은 뷰 컨트롤러가 이미지 뷰와 버튼을 포함하고 있는 모습을 보여주고 있습니다.

 ![3](/assets/img/20240315/3.png){: w="500" h="250" }

뷰 컨트롤러에 뷰를 추가한 후, 항상 오토 레이아웃(AutoLayout)을 추가해 해당 뷰의 크기와 위치를 정해주어야 합니다. 제약(Constraints)은 해당 뷰가 상위 뷰나 동일 계층 뷰 대비 상대적인 크기와 위치를 구체화시켜 해당 뷰가 다양한 환경과 기기에 알맞게 맞추어줍니다. 더 자세한 정보는 [View layout](https://developer.apple.com/documentation/uikit/view_layout)을 참조하시기 바랍니다.

## Store referecences to important views

실행 중에 개발자는 뷰 컨트롤러의 코드에서 뷰에 접근해야 할 필요가 있을 수 있습니다. 예를 들어, 텍스트 뷰에서 텍스트를 가져오거나, 이미지 뷰에서 이미지를 바꾸는 경우가 있겠죠. 이를 위해, 뷰 계층 구조에서 뷰에 대한 참조가 필요합니다. 이러한 참조는 아웃렛(outlet)으로 생성할 수 있습니다.

아웃렛은 뷰 컨트롤러에서 `IBOutlet` 키워드로 명시되어 있는 프로퍼티입니다. 해당 키워드가 있다면 Xcode가 스토리보드의 속성(Property)을 드러내라고 지시합니다. 아래 예제 코드는 두 개의 아웃렛을 정의하는 방법을 보여줍니다. Swift에서는 뷰 컨트롤러가 뷰 게층 구조에서 기인하는 첫 번째 강한 참조 외에도 뷰에 대한 두 번째 강한 참조를 방지하기 위해 `weak` 키워드를 포함하고 있습니다.

```swift
@IBOutlet weak var imageView: UIImageView?
@IBOutlet weak var button: UIButton?
```

스토리보드에서 각 아웃렛은 [Add an outlet connection to send a message to a UI object](https://help.apple.com/xcode/mac/current/#/devc06f7ee11)에서 설명한 바와 같이, 연관된 뷰와 연결됩니다. 개발자는 뷰 계층 구조 상 모든 뷰의 참조를 가질 필요가 없으며, 추후 개발자에 의해 수정될 뷰의 참조만 저장하면 됩니다. 

뷰 컨트롤러를 인스턴스화할 때, UIKit은 스토리보드에서 구성한 모든 아웃렛을 다시 연결합니다. UIKit은 아웃렛을 뷰 컨트롤러의 [viewDidLoad()](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) 메서드가 호출되기 전에 다시 연결하므로, 해당 메서드에서 해당 객체에 접근할 수 있습니다. 만약 개발자가 어떠한 뷰를 코드로 생성한다면, 개발자는 해당 뷰는 명시적으로 뷰 컨트롤러의 적절한 프로퍼티에 할당해주어야 합니다.

## Handle events occurring in views and controls

컨트롤(Controls)은 타겟-액션(Target-Action) 디자인 패턴으로 사용자 상호 작용을 알리고, 일부 뷰는 변경에 대한 응답으로 노티피케이션(Notification)을 게시(Post)하거나, 델리게이트(Delegate) 메서드를 호출합니다. 뷰 컨트롤러는 뷰를 업데이트하기 위해 이러한 상호 작용을 잘 알 필요가 있으며, 아래는 이를 위한 다양한 방법을 보여줍니다. 

* 뷰 컨트롤러에 델리게이트와 액션 메서드를 구현합니다. 이러한 방법은 간단하고 쉽게 구현할 수 있지만, 이러한 코드는 낮은 유연성 그리고 테스트와 검증을 어렵게 만듭니다.
* 뷰 컨트롤러의 익스텐션(Extension)에 델리게이트와 액션 메서드를 구현합니다. 이러한 방법은 이벤트-핸들링 코드를 뷰 컨트롤러의 나머지 코드와 분리시켜서 테스트와 검증을 쉽게 만들어 줍니다.
* 특정 객체에 델리게이트와 액션 메서드를 구현하고, 관련 정보를 뷰 컨트롤러로 전달합니다. 이러한 방법은 가장 유연하고 재사용 가능하며, 유닛 테스트 작성을 쉽게 만들어 줍니다.

컨트롤이 사용자 상호 작용에 반응하려면 아래 예제 코드 리스트 중 하나를 정의해야 합니다. 메서드를 정의할 때, 개발자는 일반적인 [UIControl](https://developer.apple.com/documentation/uikit/uicontrol)에 참조를 더 구체적인 컨트롤 클래스로 바꿀 수 있습니다. 

```swift
@IBAction func doSomething()
@IBAction func doSomething(sender: UIControl)
@IBAction func doSomething(sender: UIControl, forEvent event: UIEvent)
```

타겟-액션 디자인 패턴과 이벤트와 연관된 컨트롤을 다루는 자세한 방법은 [UIControl](https://developer.apple.com/documentation/uikit/uicontrol)을 참조하시기 바랍니다.

## Prepare your views to appear onscreen

UIKit은 뷰 컨트롤러와 뷰가 화면에 보이기 전에 구성될 수 있도록 하기 위해 일부 단계를 제공하고 있습니다. 스토리보드로부터 뷰 컨트롤러를 인스턴스화할 때, UIKit은 해당 뷰 컨트롤러의 [init(coder:)](https://developer.apple.com/documentation/oslog/oslogentry/init(coder:)) 메서드를 사용합니다.

> **Note** <br>
> 만약 뷰 컨트롤러가 코더(Coder) 객체를 제공하는 걸 넘어서 커스텀 이니셜라이저가 필요하다면, UIStoryboard의 [instantiateIntialViewController(creator:)](https://developer.apple.com/documentation/uikit/uistoryboard/3213988-instantiateinitialviewcontroller) 메서드를 사용해 인스턴스화할 수 있습니다. 해당 메서드는 UIKit에서 제공하는 코더 객체와 블록(Block)에서 직접 뷰 컨트롤러를 생성하도록 도와줍니다. 이러한 방법은 뷰 컨트롤러가 요구하는 어떠한 커스텀 데이터로 초기화할 수 있도록 해주며, 여전히 스토리보드에서 뷰나 다른 객체의 설정을 복구할 수 있습니다.
{: .prompt-tip }

뷰 컨트롤러가 화면에 나타날 때, UIKit은 아래 일련의 과정을 거쳐 먼저 연관된 뷰를 로드(Load)하고 구성해야 합니다.

1. `init(coder:)` 메서드를 호출해 뷰를 생성합니다.

2. 뷰 컨트롤러의 뷰를 연관된 액션과 아웃렛에 연결합니다.

3. 각 뷰와 뷰 컨트롤러의 [awakenFromNib()](https://developer.apple.com/documentation/objectivec/nsobject/1402907-awakefromnib) 메서드를 호출합니다.

4. 뷰 컨트롤러의 [view](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621460-view) 프로퍼티에 뷰 계층을 할당합니다.

5. 뷰 컨트롤러의 [viewDidLoad()](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) 메서드를 호출합니다.

로드 시에 뷰 컨트롤러를 사용할 준비를 위한 단계는 한번만 수행됩니다. 로드를 할 때는 스토리보드의 일부로 포함되지 않은 추가 뷰를 만들거나 구성하도록 할 수 있습니다. 뷰 컨트롤러가 화면에 보여질 때마다 발생하는 작업은 수행하면 안됩니다. 예를 들어, 애니메이션을 시작하거나 뷰의 값을 업데이트하면 안됩니다.

이제 뷰가 화면에 처음으로 보여질 때 수행되어야 하는 마지막 작업을 수행해야 합니다. UIKit은 뷰 컨트롤러의 뷰가 화면에 나타날 때, 뷰 컨트롤러에 알림을 보내어 현재 환경에 맞게 해당 뷰의 레이아웃을 업데이트하도록 합니다.

1. 전환(transition)이 시작되면 [viewWillAppear(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621510-viewwillappear)를 호출합니다.

2. 뷰를 뷰 계층 구조에 추가합니다.

3. 뷰 컨트롤러와 뷰의 트레잇 컬렉션(Trait Collection)[^footnote-1]을 업데이트합니다.

4. 상위 뷰 내에서 뷰의 크기와 위치를 포함하여 뷰의 지오메트리(Geometry)를 업데이트합니다. 마진(Margins)과 안전 영역(Safe Area) 레이아웃을 업데이트하며, 필요하다면 [viewLayoutMarginsDidChange()](https://developer.apple.com/documentation/uikit/uiviewcontroller/2891114-viewlayoutmarginsdidchange)와 [viewSafeAreaInsetsDidChange()](https://developer.apple.com/documentation/uikit/uiviewcontroller/2891116-viewsafeareainsetsdidchange) 메서드를 호출합니다.

5. 뷰 컨트롤러의 뷰가 화면에 보여지고 있다는 걸 알리기 위해 [viewIsAppering(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/4195485-viewisappearing) 메서드를 호출합니다.

6. [viewWillLayoutSubviews()](https://developer.apple.com/documentation/uikit/view_controllers/displaying_and_managing_views_with_a_view_controller) 메서드를 호출합니다.

7. 레이아웃과 뷰 계층 구조를 업데이트합니다.

8. [viewDidLayoutSubviews()](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621398-viewdidlayoutsubviews) 메서드를 호출합니다.

9. 뷰를 화면에 보여줍니다.

10. 애니메이션이 완료된 후, 뷰 컨트롤러의 [viewDidAppear(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621398-viewdidlayoutsubviews) 메서드를 호출합니다.

뷰 컨트롤러의 [viewIsAppearing(_:)] 메서들에서 뷰의 컨텐츠를 업데이트하세요. 시스템이 해당 메서드를 호출하면, 뷰가 이미 뷰 계층 구조에 추가 되어 있으며, 프레임(Frame), 바운즈(Bounds), 마진(Margins)과 인셋(insets)이 정의되어 있습니다. 시스템이 [viewIsAppearing(_:)]에 추가한 컨텐츠는 뷰가 화면에 처음 나타날 때 표시됩니다.

시스템은 뷰가 레이아웃을 수행할 때마다 [viewWillAppear(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621510-viewwillappear)와 [viewDidLayoutSubviews()](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621398-viewdidlayoutsubviews) 메서드를 호출[^footnote-2]합니다. 이는 뷰가 나타나는 동안에 언제든지 호출될 수 있습니다. 시스템은 전환 과정 중 [viewIsAppering(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/4195485-viewisappearing) 메서드를 한번만 호출하기 때문에, 뷰가 레이아웃을 수행할 때매다 해당 메서드가 반복해서 호출되지 않습니다.

시스템이 [viewIsAppering(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/4195485-viewisappearing)을 호출할 때, 뷰 컨트럴러와 뷰의 트레잇 컬렉션(Trait Collection)이 업데이트됩니다. 현재 환경에서 디스플레이 사이즈나 수직이나 수평 사이즈 클래스(Size Class)와 같은 정보에 접근하기 위해 뷰 컨트롤러의 [traitCollection](https://developer.apple.com/documentation/uikit/uitraitenvironment/1623514-traitcollection)에 접근할 수 있습니다. 사용 가능한 트레잇에 대한 자세한 정보는 [UITraitCollection](https://developer.apple.com/documentation/uikit/uitraitcollection)을 참조하시기 바랍니다.

<br>

[^footnote-1]: 이 클래스는 기기의 화면 크기, 테마 등 사용자 인터페이스의 특성과 관련된 정보를 캡슐화합니다. 화면이나 기기의 특성에 맞게 자동으로 업데이트되며, 이를 통해 앱이 현재 환경에 맞춰 인터페이스에 변화를 줄 수 있습니다.

[^footnote-2]: `layoutSubviews`라는 `UIView`의 메서드는 `View`와 자식 `View`들의 위치와 크기를 재조정합니다. 이는 현재 뷰와 모든 자식 뷰의 위치와 크기를 제공합니다. 이 메서드는 재귀적으로 모든 자식 뷰의 `layoutSubviews`까지 호출해야 하기 때문에 실행 시에 부하가 큰 메서드입니다. 시스템은 `layoutSubviews`를 뷰의 `frame`을 다시 계산해야 할 때 호출하기 때문에 우리는 `layoutSubviews`를 오버라이딩해서 `frame`이나 특정한 위치와 크기를 조절할 수 있습니다. 그러나 레이아웃을 업데이트해야 할 때 `layoutSubviews`를 직접 호출하는 것은 금지되어 있습니다. (출처: [[번역] iOS 레이아웃의 미스터리를 파헤치다](https://medium.com/mj-studio/번역-ios-레이아웃의-미스터리를-파헤치다-2cfa99e942f9))