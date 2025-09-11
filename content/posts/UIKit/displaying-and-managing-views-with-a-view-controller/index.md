---
date: '2024-08-15T23:11:08+09:00'
title: '[번역] UIKit / Displaying and managing views with a view controller (애플 공식 문서)'
description: "스토리보드에서 뷰 컨트롤러를 만들고, 커스텀 뷰를 설정한 다음, 각 뷰에 앱의 데이터를 채우세요."
tags: ["UIViewController", "UIStoryboard", "UITraitCollection"]
categories: ["UIKit"]
cover:
    image: images/docs_1.jpg
---

## Overview

Model-View-Controller(MVC) 디자인 패턴에서 뷰 컨트롤러는 화면에 정보를 보여주는 뷰 객체와 앱의 콘텐츠를 저장한 데이터 객체 사이에 위치하고 있습니다. 조금 더 구체적으로 말하자면, 뷰 컨트롤러는 뷰를 항상 최신 상태로 유지시키기 위해 필요한 상태 정보와 뷰 계층(View Hierarchy)을 관리하고 있습니다. 모든 UIKit 앱은 콘텐츠를 보여주기 위해 뷰 컨트롤러에 많은 의존을 하고 있고, 개발자는 앱의 뷰와 UI와 관련된 로직을 관리하기 위해 커스텀 뷰 컨트롤러를 정의하고 있습니다.

개발자가 생성하는 대부분의 커스텀 뷰 컨트롤러는 콘텐츠 뷰 컨트롤러(Content ViewController)입니다. 이는 뷰 컨트롤러가 모든 뷰를 가지며 해당 뷰와의 상호 작용을 관리한다는 걸 의미합니다. 콘텐츠 뷰 컨트롤러를 사용해 앱의 커스텀 콘텐츠를 보여주고, 뷰 컨트롤러 객체를 사용해 커스텀 뷰로 데이터를 보내거나 받도록 관리할 수 있습니다.

{{< figure src="media-3375402.png" width="450px" align="center" >}}


> **Note**:
> 콘텐츠 뷰 컨트롤러와 반대로, 컨테이너 뷰 컨트롤러(Container ViewController)는 뷰 계층 구조 상에서 다른 뷰 컨트롤러의 콘텐츠를 포함하도록 할 수 있습니다. [UINavigationController](https://developer.apple.com/documentation/uikit/uinavigationcontroller)가 컨테이너 뷰 컨트롤러의 대표적인 예입니다. 컨테이너 뷰 컨트롤러를 구현하는 방법은 [Implementing a Custom Container ViewController](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/ImplementingaContainerViewController.html#//apple_ref/doc/uid/TP40007457-CH11-SW12)를 참고하세요.

콘텐츠 뷰 컨트롤러를 정의하려면 [UIViewController](https://developer.apple.com/documentation/uikit/uiviewcontroller)를 서브클래싱해야 합니다. 만약 인터페이스에 테이블 뷰나 컬렉션 뷰가 포함되어 있다면, [UITableViewController](https://developer.apple.com/documentation/uikit/uitableviewcontroller)나 [UICollectionViewController](https://developer.apple.com/documentation/uikit/uicollectionviewcontroller)를 대신 서브클래싱해야 합니다. 새로운 Xcode 프로젝트에는 개발자가 수정할 수 있는 하나 또는 그 이상의 콘텐츠 뷰 컨트롤러를 포함하고 있으며, 필요하다면 추가도 할 수 있습니다.

## Add views to your view controller

[UIViewController](https://developer.apple.com/documentation/uikit/uiviewcontroller)는 [view](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621460-view) 프로퍼티로 접근할 수 있는 콘텐츠 뷰(Content View)를 포함하고 있습니다. 해당 뷰는 뷰 계층 구조 상에서 최상위 뷰의 역할을 합니다. 해당 뷰에서 개발자는 인터페이스로 보여주고 싶은 커스텀 뷰를 추가해야 합니다. 스토리보드에서는 뷰 컨트롤러 씬(scene)으로 드래깅을 함으로써 커스텀 뷰를 추가할 수 있습니다. 예를 들어, 아래 그림은 뷰 컨트롤러가 이미지 뷰와 버튼을 포함하고 있는 모습을 보여주고 있습니다.

{{< figure src="media-3375403.png" width="250px" align="center" >}}


뷰 컨트롤러에 뷰를 추가한 후, 항상 오토 레이아웃(AutoLayout)을 추가해 해당 뷰의 크기와 위치를 정해주어야 합니다. 제약(Constraints)은 해당 뷰가 상위 뷰나 동일 계층 뷰 대비 상대적인 크기와 위치를 구체화시켜 해당 뷰가 다양한 환경과 기기에 알맞게 맞추어줍니다. 더 자세한 정보는 [View layout](https://developer.apple.com/documentation/uikit/view_layout)을 참고하세요.

## Store references to important views

실행 중에 개발자는 뷰 컨트롤러의 코드에서 뷰에 접근해야 할 필요가 있을 수 있습니다. 예를 들어, 텍스트 뷰에서 텍스트를 가져오거나, 이미지 뷰에서 이미지를 바꾸는 경우가 있을 수 있습니다. 이를 위해, 뷰 계층 구조에서 뷰에 대한 참조가 필요합니다. 이러한 참조는 아웃렛(outlet)으로 생성할 수 있습니다.

아웃렛은 뷰 컨트롤러에서 *IBOutlet* 키워드로 명시되어 있는 프로퍼티입니다. 해당 키워드가 있다면 Xcode가 스토리보드의 속성을 드러내라고 지시합니다. 아래 예제 코드는 두 개의 아웃렛을 정의하는 방법을 보여줍니다. Swift에서는 뷰 컨트롤러가 뷰 계층에서 기인하는 첫 번째 강한 참조 외에도 뷰에 대한 두 번째 강한 참조를 방지하기 위해 *weak* 키워드를 포함하고 있습니다.

```swift
@IBOutlet weak var imageView: UIImageView?
@IBOutlet weak var button: UIButton?
```

스토리보드에서 각 아웃렛은 [Add an outlet connection to send a message to a UI object](https://help.apple.com/xcode/mac/current/#/devc06f7ee11)에서 설명한 바와 같이, 연관된 뷰와 연결됩니다. 개발자는 뷰 계층 구조 상 모든 뷰의 참조를 가질 필요가 없으며, 추후 개발자에 의해 수정될 뷰의 참조만 저장하면 됩니다. 

뷰 컨트롤러를 인스턴스화할 때, UIKit은 스토리보드에서 구성한 모든 아웃렛을 다시 연결합니다. UIKit은 아웃렛을 뷰 컨트롤러의 [viewDidLoad()](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) 메서드가 호출되기 전에 연결하므로, 해당 메서드에서 모든 객체에 접근할 수 있습니다. 만약 개발자가 어떠한 뷰를 코드로 생성한다면, 개발자는 해당 뷰를 명시적으로 뷰 컨트롤러의 적절한 프로퍼티에 할당해주어야 합니다.

## Handle events occurring in views and controls

컨트롤(controls)은 타겟-액션(target-action) 디자인 패턴으로 사용자 상호작용을 알리고, 일부 뷰는 변경에 대한 응답으로 노티피케이션(Notification)을 게시하거나, 델리게이트 메서드를 호출합니다. 뷰 컨트롤러는 뷰를 업데이트하기 위해 이러한 상호작용을 잘 알 필요가 있으며, 아래는 이를 위한 다양한 방법을 보여줍니다. 

* 뷰 컨트롤러에 델리게이트와 액션 메서드를 구현합니다. 이러한 방법은 간단하고 쉽게 구현할 수 있지만, 이러한 코드는 낮은 유연성 그리고 테스트와 검증을 어렵게 만듭니다.
* 뷰 컨트롤러의 익스텐션에 델리게이트와 액션 메서드를 구현합니다. 이러한 방법은 이벤트-핸들링 코드를 뷰 컨트롤러의 나머지 코드와 분리시켜서 테스트와 검증을 쉽게 만들어 줍니다.
* 특정 객체에 델리게이트와 액션 메서드를 구현하고, 관련 정보를 뷰 컨트롤러로 전달합니다. 이러한 방법은 가장 유연하고 재사용 가능하며, 유닛 테스트 작성을 쉽게 만들어 줍니다.

컨트롤이 사용자 상호작용에 반응하려면 아래 예제 코드 리스트 중 하나를 정의해야 합니다. 메서드를 정의할 때, 개발자는 일반적인 [UIControl](https://developer.apple.com/documentation/uikit/uicontrol)에 참조를 더 구체적인 컨트롤 클래스로 바꿀 수 있습니다. 

```swift
@IBAction func doSomething()
@IBAction func doSomething(sender: UIControl)
@IBAction func doSomething(sender: UIControl, forEvent event: UIEvent)
```

타겟-액션 디자인 패턴과 이벤트와 연관된 컨트롤을 다루는 자세한 방법은 [UIControl](https://developer.apple.com/documentation/uikit/uicontrol)을 참고하세요.

## Prepare your views to appear onscreen

UIKit은 뷰 컨트롤러와 뷰가 화면에 보이기 전에 구성될 수 있도록 하기 위해 일부 단계를 제공하고 있습니다. 스토리보드로부터 뷰 컨트롤러를 인스턴스화할 때, UIKit은 해당 뷰 컨트롤러의 [init(coder:)](https://developer.apple.com/documentation/oslog/oslogentry/init(coder:)) 생성자를 사용합니다.

> **Note**:
> 만약 뷰 컨트롤러가 코더(Coder) 객체를 제공하는 걸 넘어서 커스텀 이니셜라이저가 필요하다면, *UIStoryboard*의 [instantiateIntialViewController(creator:)](https://developer.apple.com/documentation/uikit/uistoryboard/3213988-instantiateinitialviewcontroller) 메서드를 사용해 인스턴스화할 수 있습니다. 해당 메서드는 UIKit에서 제공하는 코더 객체와 블록에서 직접 뷰 컨트롤러를 생성하도록 도와줍니다. 이 옵션을 사용하면 뷰 컨트롤러에 필요한 커스텀 데이터를 초기화하면서도, 스토리보드에 있는 뷰와 다른 객체들의 구성을 그대로 복원할 수 있습니다.

뷰 컨트롤러가 화면에 나타날 때, UIKit은 아래 일련의 과정을 거쳐 먼저 연관된 뷰를 로드하고 구성합니다.

1. `init(coder:)` 메서드를 호출해 뷰를 생성합니다.

2. 뷰 컨트롤러의 뷰를 연관된 액션과 아웃렛에 연결합니다.

3. 각 뷰와 뷰 컨트롤러의 [awakenFromNib()](https://developer.apple.com/documentation/objectivec/nsobject/1402907-awakefromnib) 메서드를 호출합니다.

4. 뷰 컨트롤러의 [view](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621460-view) 프로퍼티에 뷰 계층을 할당합니다.

5. 뷰 컨트롤러의 [viewDidLoad()](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) 메서드를 호출합니다.

로드 시에 뷰 컨트롤러를 사용할 준비를 위한 단계는 한번만 수행됩니다. 로드를 할 때는 스토리보드의 일부로 포함되지 않은 추가 뷰를 만들거나 구성하도록 할 수 있습니다. 뷰 컨트롤러가 화면에 보여질 때마다 발생하는 작업은 수행하면 안됩니다. 예를 들어, 애니메이션을 시작하거나 뷰의 값을 업데이트하면 안됩니다.

이제 뷰가 화면에 처음으로 보여질 때 수행되어야 하는 마지막 작업을 수행해야 합니다. UIKit은 뷰 컨트롤러의 뷰가 화면에 나타날 때, 뷰 컨트롤러에 알림을 보내어 현재 환경에 맞게 해당 뷰의 레이아웃을 업데이트하도록 합니다.

1. 트랜지션이 시작되면 [viewWillAppear(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621510-viewwillappear)를 호출합니다.

2. 뷰를 뷰 계층 구조에 추가합니다.

3. 뷰 컨트롤러와 뷰의 트레잇 컬렉션(Trait Collection)을 업데이트합니다.

4. 상위 뷰 내에서 뷰의 크기와 위치를 포함하여 뷰의 지오메트리를 업데이트합니다. 마진과 안전 영역 레이아웃을 업데이트하며, 필요하다면 [viewLayoutMarginsDidChange()](https://developer.apple.com/documentation/uikit/uiviewcontroller/2891114-viewlayoutmarginsdidchange)와 [viewSafeAreaInsetsDidChange()](https://developer.apple.com/documentation/uikit/uiviewcontroller/2891116-viewsafeareainsetsdidchange) 메서드를 호출합니다.

5. 뷰 컨트롤러의 뷰가 화면에 보여지고 있다는 걸 알리기 위해 [viewIsAppering(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/4195485-viewisappearing) 메서드를 호출합니다.

6. [viewWillLayoutSubviews()](https://developer.apple.com/documentation/uikit/view_controllers/displaying_and_managing_views_with_a_view_controller) 메서드를 호출합니다.

7. 레이아웃과 뷰 계층 구조를 업데이트합니다.

8. [viewDidLayoutSubviews()](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621398-viewdidlayoutsubviews) 메서드를 호출합니다.

9. 뷰를 화면에 보여줍니다.

10. 애니메이션이 완료된 후, 뷰 컨트롤러의 [viewDidAppear(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621398-viewdidlayoutsubviews) 메서드를 호출합니다.

뷰 컨트롤러의 [viewIsAppearing(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/4195485-viewisappearing) 메서드에서 뷰의 콘텐츠를 업데이트하세요. 시스템이 해당 메서드를 호출하면, 뷰가 이미 뷰 계층 구조에 추가 되어 있으며, 프레임, 바운즈, 마진과 인셋이 정의되어 있습니다. 시스템이 [viewIsAppearing(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/4195485-viewisappearing)에 추가한 콘텐츠는 뷰가 화면에 처음 나타날 때 표시됩니다.

시스템은 뷰가 레이아웃을 수행할 때마다 [viewWillAppear(_:)](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621510-viewwillappear)와 [viewDidLayoutSubviews()](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621398-viewdidlayoutsubviews) 메서드를 호출합니다. 이는 뷰가 나타나는 동안에 언제든지 호출될 수 있습니다. 시스템은 각 화면 전환 과정에서 *viewIsAppering(_:)* 메서드를 한번만 호출하기 때문에, 이 메서드에서 수항한 변경 사항은 뷰가 레이아웃을 다시 할 때마다 해당 반복해서 호출되지 않습니다.

시스템이 *viewIsAppering(_:)* 메서드를 호출할 때, 뷰 컨트롤러와 뷰의 트레잇 컬렉션이 업데이트됩니다. 현재 환경에서 디스플레이 사이즈나 수직이나 수평 사이즈 클래스 같은 정보에 접근하기 위해 뷰 컨트롤러의 [traitCollection](https://developer.apple.com/documentation/uikit/uitraitenvironment/1623514-traitcollection) 프로퍼티에 접근할 수 있습니다. 사용 가능한 트레잇에 대한 자세한 정보는 [UITraitCollection](https://developer.apple.com/documentation/uikit/uitraitcollection)을 참고하세요.