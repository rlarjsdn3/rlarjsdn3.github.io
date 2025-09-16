---
date: '2025-10-15T18:51:59+09:00'
draft: false
title: '[번역] UNUserNotifications / Customizing the Appearance of Notifications (애플 공식 문서)'
description: "iOS 앱의 알림 경고창 UI를 사용자화하려면 콘텐츠 앱 익스텐션을 사용하세요."
tags: ["UNNotificationContentExtension"]
categories: ["UNUserNotifications"]
cover:
    image: images/docs_1.jpg
---

## Overview

iOS 기기가 알림을 수신하면 시스템은 두 단계로 알림의 내용을 표시합니다. 먼저, 제목과 부제목, 그리고 본문 텍스트 두세 줄에서 네 줄 정도가 포함된 축약된 배너(abbreviated banner)를 보여줍니다.사용자가 축약된 배너를 누르면, iOS는 알림과 관련된 액션까지 포함된 전체 알림 인터페이스를 표시합니다. 시스템은 축약된 배너 인터페이스를 제공하지만, *Notification Content App Extension*을 사용해 전체 인터페이스를 사용자화할 수 있습니다.

{{< figure src="customizing-the-appearance-of-notifications-1.png" width="650px" align="center" >}}

*Notification Content App Extension*은 사용자 정의 알림 인터페이스를 표시하는 뷰 컨트롤러를 관리합니다. 이 뷰 컨트롤러는 알림에 대해 기본적으로 제공되는 시스템 인터페이스를 보완하거나 교체할 수 있습니다. 이를 통해 아래와 같은 작업을 할 수 있습니다:

* 알림의 제목, 부제목, 본문 텍스트를 포함한 항목의 배치를 사용자화할 수 있습니다. 

* 인터페이스 요소에 다른 폰트나 스타일링을 적용할 수 있습니다.

* 알림 페이로드의 앱 전용 키(app-specific keys)에 저장된 앱 고유의 데이터를 표시할 수 있습니다.

* 맞춤 이미지나 브랜딩 요소를 포함할 수 있습니다.

앱 익스텐션은 알림의 내용이나 앱 익스텐션 번들에 포함된 파일처럼 즉시 사용할 수 있는 데이터를 이용해 뷰 컨트롤러를 구성해야 합니다. 앱과 앱 익스텐션 간에 데이터를 공유하기 위해 앱 그룹을 사용하는 경우, 앱 그룹에 있는 파일도 활용할 수 있습니다. 알림이 제때 표시되도록 보장하려면 뷰 구성을 가능한 한 빠르게 처리해야 하며, 네트워크를 통한 데이터 가져오기 같은 장시간 작업은 수행하지 않아야 합니다.

> **Note**:
> 콘텐츠 앱 익스텐션은 iOS 앱에서만 지원됩니다. watchOS에서 알림 UI를 사용자화하는 방법에 대해서는 [App Programming Guiude for watchOS]()를 참고하세요.


## Add the Notification Content App Extension to Your Project

앱에 이 익스텐션을 추가하려면 아래 단계를 따르세요:

1. Xcode에서 File > New > Target을 선택합니다.

2. iOS > Application 섹션에서 *Notification Content App Extension*을 선택합니다.

3. Next를 선택합니다.

4. 앱 익스텐션의 이름과 기타 세부 정보를 지정합니다.

5. Finish를 선택합니다.

> **Note**:
> 프로젝트에 하나 이상의 *Notification Content App Extension*을 추가할 수 있지만, 각 익스텐션은 고유한 알림 카테고리 집합을 지원해야 합니다. 지원할 카테고리는 *Info.plist* 파일에서 지정해야 하며, 자세한 내용은 [Declare the Supported Notification Types]()을 참고하세요.


## Add Views to Your View Controller

Xcode에서 제공하는 템플릿에는 개발자가 구성할 수 있는 스토리보드와 뷰 컨트롤러가 포함되어 있습니다. 뷰 컨트롤러에 뷰를 추가하여 사용자 정의 알림 인터페이스를 구성하면 됩니다. 예를 들어, 레이블을 사용해 알림의 제목, 부제목, 본문 텍스트를 표시할 수 있습니다. 이미지 뷰나 상호작용이 필요 없는 콘텐츠를 표시하는 뷰도 추가할 수 있습니다. 뷰에 초기 콘텐츠를 제공할 필요는 없습니다. 

iOS 12 이상에서는 버튼이나 스위치 같은 상호작용이 가능한 컨트롤을 추가할 수 있습니다. 자세한 내용은 *Support Interactive Controls*를 참고하세요.

> **Important**:
> 앱 익스텐션이나 스토리보드 파일에 뷰 컨트롤러를 추가로 넣어서는 안 됩니다. 앱 익스턴션에는 정확히 하나의 뷰 컨트롤러만 포함되어야 합니다. 


## Configure Your View Controller

뷰 컨트롤러의 [didReceive(_:)]() 메서드를 사용해 레이블이나 다른 뷰를 업데이트합니다. 알림 페이로드에는 뷰 컨트롤러를 구성할 때 사용할 데이터가 포함되어 있습니다. 또한 앱 익스텐션의 다른 파일에서 데이터를 가져와 활용할 수도 있습니다. 아래는 알림 페이로드에서 제목과 본문 텍스트를 가져와 뷰 컨트롤러에 아웃렛으로 연결된 두 개의 [UILabel]()에 할당하는 메서드 구현 예시를 보여줍니다.

```swift
func didReceive(_ notification: UNNotification) {
    self.bodyText?.text = notification.request.content.body
    self.headlineText?.text = notification.request.content.title
}
```

두 번재 알림이 도착했을 때 뷰 컨트롤러가 이미 표시 중이라면, 시스템은 새로운 알림 페이로드와 함께 [didReceive(_:)]() 메서드를 다시 호출합니다.


## Declare the Supported Notification Types

*Notification Content App Extension*이 인터페이스를 제공할 알림의 유형을 지정해야 합니다. 시스템은 알림을 받을 때 해당 알림의 카테고리 값(즉, 알림의 유형)을 앱 내 콘텐츠 앱 익스테션에 선언된 카테고리와 비교합니다. 일치하는 항목이 있으면 시스템은 해당 앱 익스텐션을 로드합니다. 

*Notification Content App Extension*의 *Info.plist* 파일에서 *UNNotificationExtensionCategory* 키를 설정하고, 익스텐션이 지원하는 알림의 카테고리 문자열을 지정해야 합니다. 카테고리 문자열은 iOS 앱에서 등록한 [UNNotificationCategory]() 객체에 포함된 식별자입니다. 이 문자열을 사용해 앱이 수신할 수 있는 알림의 유형을 구분합니다. 예를 들어, 새로운 회의 초대를 나타내는 알림에는 *MEETING_INVITE*라는 문자열을 포함할 수 있습니다. 식별자는 대소문자를 구분합니다.

{{< figure src="customizing-the-appearance-of-notifications-2.png" width="650px" align="center" >}}

> **Note**:
> *UNNotificationExtensionCategory* 키의 값이 문자열로 되어 있어 콘텐츠 앱 익스텐션이 한 가지 알림 유형만 지원할 수 있습니다. 여러 유형을 지원하려면 이 값을 문자열 배열로 변경해야 합니다.

로컬 알림의 경우, [UNMutableNotificationContent]() 객체의 [categoryIdentifier]() 프로퍼티에 카테고리 문자열을 넣습니다. 푸시 알림의 경우, JSON 페이로드의 *category* 키에 문자열을 넣습니다. 앱의 알림 유형 선언에 대한 자세한 내용은 [Declaring your actionable notification types]()를 참고하세요.

*Info.plist* 파일의 키에 대한 더 많은 정보는 [UNNotificationContentExtension]()을 참고하세요.



## Hide the Default Notification Interface

시스템은 모든 알림에 대해 기본 정보를 표시합니다. 이 규칙은 개발자가 커스텀 인터페이스를 제공하는 경우에도 적용됩니다. 시스템은 항상 앱 이름과 아이콘이 포함된 헤더를 표시합니다. 또한 알림의 제목, 부제목, 본문 텍스트가 포함된 인터페이스도 표시하지만, 원한다면 이 부분은 숨길 수 있습니다.

예를 들어, 기본 알림 인터페이스가 커스텀 인터페이스와 동일한 정보를 표시한다면 해당 알림 인터페이스를 숨길 수 있습니다. 아래 그림은 기본 인터페이스가 있을 때와 없을 때의 알림 인터페이스 레이아웃을 보여줍니다.

{{< figure src="customizing-the-appearance-of-notifications-3.png" width="650px" align="center" >}}

기본 시스템 인터페이스를 제거하려면, 익스텐션의 *Info.plist* 파일에 *UNNotificationExtensionDefaultContentHidden* 키를 추가하고 해당 값을 *true*로 설정하면 됩니다. 이 키에 대한 더 자세한 내용은 [UNNotificationContentExtension]()을 참고하세요.


## Incorporating Media Into Your Interface

커스텀 알림 인터페이스에서 오디오 또는 비디오 재생을 지원하려면 아래 사항을 구현하세요:

* 뷰 컨트롤러의 [mediaPlayPauseButtonType]() 속성으로 원하는 버튼 유형을 반환하세요.

* 뷰 컨트롤러의 [mediaPlayPauseButtonFrame]() 속성으로 버튼의 프레임을 반환하세요.

* [mediaPlay()]() 메서드에서 미디어 파일 재생을 시작합니다.

* [mediaPause()]() 메서드에서 미디어 파일 재생을 중지합니다.

시스템은 미디어 버튼을 직접 그려주며, 모든 사용자 상호작용을 처리합니다. 버튼이 눌리면 [mediaPlay()]()와 [mediaPause()]() 메서드를 호출하여 재생을 시작하거나 중지할 수 있도록 합니다.

미디어 파일 재생을 코드로 시작하거나 중지하려면 현재 [NSExtensionContext]() 객체의 [mediaPlayingStarted()]()와 [mediaPlayingPaused()]() 메서드를 호출하세요. 뷰 컨트롤러의 [extensionContext]() 속성을 사용하여 해당 익스텐션 컨텍스트에 접근할 수 있습니다. 


## Support Interactive Controls

iOS 12 이상에서는 커스텀 알림에서 사용자 상호작용을 할 수 있습니다. 이를 통해 버튼이나 스위치 같은 인터랙티브한 컨트롤을 커스텀 인터페이스에 추가할 수 있습니다. 사용자 상호작용을 활성화하려면 다음 단계를 따르세요:

1. * *Notification Content Extension*의 *Info.plsit* 파일을 여세요.

2. 익스텐션 속성에 *UNNotificationExtensionUserInteractionEnabled* 키를 추가합니다. 이 키의 값을 *Boolean* 타입으로 설정하고 *YES*로 지정합니다.

아래 그림은 사용자 상호작용이 활성화된 *Info.plist* 파일의 예시를 보여줍니다.

{{< figure src="customizing-the-appearance-of-notifications-4.png" width="650px" align="center" >}}