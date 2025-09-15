---
date: '2025-10-05T22:11:11+09:00'
draft: false
title: '[번역] UNUserNotifications / Pushing Background Updates to Your App (애플 공식 문서)'
description: "앱을 백그라운드에서 업데이트하도록 알림을 전달하세요."
tags: ["Remote Notifications", "AppDelegate"]
categories: ["UNUserNotifications"]
cover:
    image: images/docs_1.jpg
---

## Overview

앱의 서버 기반 콘텐츠가 드물게 또는 불규칙하게 변경된다면, 새로운 콘텐츠가 사용 가능할 때 앱에 알려주기 위해 백그라운드 알림을 사용할 수 있습니다. 백그라운드 알림은 경고를 표시하거나, 사운드를 재생하거나, 앱 아이콘에 배지를 표시하지 않는 푸시 알림입니다. 이 알림은 앱을 백그라운드에서 깨워주고, 앱이 서버에서 다운로드를 시작하고 콘텐츠를 업데이트할 시간을 제공합니다.

> **Important**:
> 시스템은 백그라운드 알림을 낮은 우선순위로 취급합니다. 따라서 이를 사용해 앱의 콘텐츠를 새로고침할 수 있지만, 시스템이 반드시 전달을 보장하지는 않습니다. 또한 백그라운드 알림의 총 개수가 과도해지면 시스템이 그 전달을 제한할 수 있습니다. 시스템에서 허용하는 백그라운드 알림의 수는 현재 상황에 따라 달라지지만, 한 시간에 두 세개 이상 보내지 않도록 하는 것이 좋습니다.


## Enable the remote notifications capability

백그라운드 알림을 받으려면 앱에 푸시 알림(background mode)을 추가해야 합니다. Signing & Capabilities 탭에서 Background Modes 기능을 추가한 뒤, Remote notifications 체크박스를 선택해야 합니다. 아래 그림은 백그라운드 알림을 받기 위해 선택해야 하는 항목을 보여줍니다.

{{< figure src="media-4285757.png" width="650px" align="center" >}}

watchOS의 경우, 이 기능을 WatchKit Extension에 추가해야 합니다.


## Create a background notification

백그라운드 알림을 보내려면, 아래 예시 코드처럼 *aps* 딕셔너리에 *content-available* 키만 포함한 푸시 알림을 생성해야 합니다. 페이로드에 커스텀 키를 포함할 수 있지만, *aps* 딕셔너리에는 사용자 상호작용을 일으키는 키를 포함하면 안됩니다.

```json
{
    "aps" : {
        "content-available" : 1
    },
    "acme1" : "bar",
    "acme2" : 42
}
```

또한 알림의 POST 요청에는 *apns-push-type* 헤더 필드를 *background* 값으로 설정하고, *apns-priority* 필드를 *5* 값으로 설정해야 합니다. APNs 서버는 Apple Watch에 푸시 알림을 보낼 때 *apns-push-type* 필드를 반드시 요구하며, 모든 플랫폼에서 이를 사용하는 것을 권장합니다. 더 자세한 내용은 [Sending notification requests to APNs](https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns)의 Create a POST request to APNs를 참고하세요.


## Receive background notifications

디바이스가 백그라운드 알림을 수신하면, 시스템은 알림 전달을 보류하거나 지연시킬 수 있으며, 이로 인해 아래와 같은 사이드 이펙트가 발생할 수 있습니다:

* 시스템이 백그라운드 알림을 받으면, 이전 알림은 폐기되고 가장 최근 알림만 보관됩니다.

* 앱이 강제로 종료되거나 종료된 경우, 시스템은 보관 중이던 알림을 폐기합니다.

* 사용자가 앱을 실행하면, 시스템은 즉시 보관 중이던 알림을 전달합니다.

백그라운드 알림을 전달하기 위해 시스템은 앱을 백그라운드에서 깨웁니다. iOS에서는 엡 델리게이트의 [application(_:didReceiveRemoteNotification:fetchCompletionHandler:)](https://developer.apple.com/documentation/UIKit/UIApplicationDelegate/application(_:didReceiveRemoteNotification:fetchCompletionHandler:)) 메서드를 호출하고, watchOS에서는 익스텐션 델리게이트의 [didReceiveRemoteNotification(_:fetchCompletionHandler:)](https://developer.apple.com/documentation/WatchKit/WKExtensionDelegate/didReceiveRemoteNotification(_:fetchCompletionHandler:)) 메서드를 호출합니다. 앱은 최대 30초 동안 작업을 수행하고, *completion handler*를 호출해야 합니다. 더 자세한 내용은 [Handling notifications and notification-related actions](https://developer.apple.com/documentation/usernotifications/handling-notifications-and-notification-related-actions) 문서를 참고하세요.

