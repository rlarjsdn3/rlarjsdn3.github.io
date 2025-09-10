---
date: "2025-09-10T20:36:49+09:00"
draft: false
title: "[번역] UNUserNotifications / Asking permission to use notifications"
description: "알림에 대한 응답으로 경고(alert)을 표시하거나, 사운드를 재생하거나, 앱 아이콘에 배지를 표시할 수 있도록 권한을 요청합니다."
tags: ["UNUserNotificationCenter"]
categories: ["UNUserNotifications"]
cover:
  image: images/docs_1.jpg
---

## Overview

로컬 및 원격 알림은 경고을 표시하거나, 사운드를 재생하거나, 앱 아이콘에 배지를 표시하여 사용자의 주의를 끌 수 있습니다. 이러한 상호작용은 앱이 실행 중이 아니거나 백그라운드에 있을 때 발생합니다. 이를 통해 사용자는 앱에 자신과 관련된 정보가 있다는 것을 알 수 있습니다. 그러나 알림 기반 상호작용은 사용자에게 방해 요소로 여겨질 수 있으므로, 이를 사용하려면 반드시 권한을 얻어야 합니다.

{{< figure src="media-3559454.png" width="300px" align="center" >}}

## Explicitly request autorization in context

권한을 요청하려면, [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter) 공유 인스턴스를 가져와 [requestAuthorization(options:completionHandler:)](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/requestauthorization(options:completionhandler:)) 메서드를 호출하세요. 앱이 사용하는 모든 상호작용 유형을 지정해야 합니다. 예를 들어, 알림을 표시하거나, 앱 아이콘에 배지를 추가하거나, 사운드를 재생할 수 있도록 권한을 요청할 수 있습니다:

```swift
let center = UNUserNotificationCenter.current()

do {
    try await center.requestAuthorization(options: [.alert, .sound, .badge])
} catch {
    // Handle the error here.
}

// Enable or disable featrues based on the authorization.
```

앱이 처음으로 이 권한 요청을 수행하면, 시스템은 사용자에게 요청을 허용할지 거부할지 묻고 그 응답을 기록합니다. 이후의 권한 요청에서는 사용자에게 다시 묻지 않습니다.

앱이 권한을 필요로 하는 이유를 사람들이 이해할 수 있는 맥락(context)에서 권한을 요청하세요. 예를 들어, 알림으로 리마인드를 보내는 작업 관리 앱에서 사용자가 첫 번째 작업을 예약한 후에 권한을 요청할 수 있습니다. 처음 실행 시 자동으로 권한을 요청하는 것보다, 이런 맥락에서 요청하는 것이 더 나은 경험을 제공합니다. 사용자가 앱의 알림이 어떤 목적을 가지는지 직접 확인할 수 있기 때문입니다.


## Use provisional autorization to send trial notifications

앱에서 알림을 보내기 위한 권한을 명시적으로 요청하면, 사용자는 앱의 알림을 한 번도 보지 못한 상태에서 허용할지 거부할지 결정해야 합니다. 권한을 요청하기 전에 맥락을 신중히 설계하더라도, 사용자가 결정을 내리기에 충분한 정보를 얻지 못해 권한을 거부할 수 있습니다.

임시(provisional) 권한을 사용하여 알림을 시험적으로 보낼 수 있습니다. 그러면 사용자는 알림을 직접 본 뒤, 이를 허용할지 여부를 결정할 수 있습니다.

시스템은 임시 알림을 조용히 전달합니다. 즉, 소리나 배너로 사용자를 방해하지 않으며, 잠금 화면에도 표시되지 않습니다. 대신 알림 센터의 기록에만 나타납니다. 이러한 알림에는 사용자가 알림을 유지하거나 끌 수 있도록 안내하는 버튼도 함께 포함됩니다.

{{< figure src="media-3544497.png" width="500px" align="center" >}}

사용자가 **Keep** 버튼을 누르면, 시스템은 즉시 전달(Deliver Immediately)와 시간 지정 요약(Deliver in Scheduled Summary) 옵션 중 하나를 선택하도록 안내합니다. 즉시 전달을 선택하면 이후 알림이 조용히 전달됩니다. 이 경우 시스템은 앱이 알림을 보낼 수 있도록 허용하지만, 경고 표시, 사운드 재생, 앱 아이콘 배지 표시 권한은 주지 않습니다. 따라서 사용자가 알림 설정을 변경하지 않는 한, 알림은 알림 센터 기록에만 나타납니다. 시간 지정 요약 옵션은 사용자가 설정에서 시간 지정 요약(Scheduled Summary)을 켜둔 경우에만 표시됩니다.

사용자가 **Turn Off** 버튼을 누르면, 시스템은 선택을 확인한 뒤 앱이 추가 알림을 보낼 수 있는 권한을 거부합니다. 

임시 권한을 요청하려면, 알림 전송 권한을 요청할 때 [provisional](https://developer.apple.com/documentation/usernotifications/unauthorizationoptions/provisional) 옵션을 함께 추가하세요.

```swift
let center = UNUserNotificationCenter.current()

do {
    try await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
} catch {
    // Handle errors that may occure during requestAuthorization.
}
```

명시적으로 권한을 요청하는 경우와 달리, 이 코드는 사용자에게 알림 권한 요청을 묻는 창을 띄우지 앟습니다. 대신 이 메서드를 처음 호출하면 자동으로 권한이 부여됩니다. 그러나 사용자가 알림을 명시적으로 유지(keep)하거나 끄기(turn off) 전까지 권한 상태는 [UNAuthorizationStatus.provisional](https://developer.apple.com/documentation/usernotifications/unauthorizationstatus/provisional)로 유지됩니다. 사용자는 언제든 권한 상태를 변경할 수 있으므로, 로컬 알림을 스케줄링하기 전에 권한 상태를 확인해야 합니다.

또한 임시 권한을 요청하는 경우, (사람들이 이해할 수 있는 맥락이 아니라) 앱이 처음 실행될 때 권한을 요청할 수 있습니다. 사용자는 실제로 알림을 받았을 때에만 알림을 유지할지 끌지를 묻게 됩니다.


## Custommize notifications based on the current autorizations

로컬 알림을 스케줄링하기 전에 항상 앱의 권한을 확인하세요. 사용자가는 언제든 앱의 권한 설정을 변경할 수 있습니다. 또한 앱에서 허용되는 상호작용 유형을 변경할 수도 있으며, 이로 인해 앱이 보내는 알림의 수나 유형을 조정해야 할 수도 있습니다.

최적의 사용자 경험을 제공하려면, [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter)의 [getNotificationSettings(completionHandler:)](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/getnotificationsettings(completionhandler:)) 메서드를 호출해 현재 알림 설정을 가져오세요. 그런 다음 이 설정에 따라 알림을 맞춤화하세요.

```swift
let center = UNUserNotificationCenter.current()

// Obtain the notification settings.
let settings = await center.notificationSettings()

// Verify the authorization status.
guard (settings.authorizationStatus == .authorized) || 
	  (settings.authorizationStatus == .provisional) else { return }
      
if settings.alertSetting == .enabled {
    // Schedule an alert-only notification.
} else {
    // Schedule a notification with a badge and sound.
}
```

위 예제에서는 앱에 권한이 없을 경우 알림 스케줄링을 막기 위해 `guard` 조건을 사용합니다. 그런 다음 허용된 상호작용 유형에 따라 알림을 구성하며, 가능한 경우 알림 기반 방식(alert-based notification) 방식을 우선적으로 사용합니다.

일부 상호작용에 대한 권한이 앱에 없더라도, 알림에 경고, 사운드, 배지 정보를 설정하고 싶을 수 있습니다. [UNNotificationSettings](https://developer.apple.com/documentation/usernotifications/unnotificationsettings) 인스턴스의 [notificationCenterSettings](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/notificationcentersetting) 속성이 [UNNotificationSetting.enabled](https://developer.apple.com/documentation/usernotifications/unnotificationsetting/enabled)로 설정되어 있으면, 시스템은 여전히 알림 센터에 경고를 표시합니다. 또한 앱이 포그라운드에 있을 때에도 알림 센터 델리게이트의 [userNotificationCenter(_:willPresent:withCompletionHandler:)](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/usernotificationcenter(_:willpresent:withcompletionhandler:)) 메서드가 알림을 수신하여, 이때도 경고, 사운드, 배지 정보에 접근할 수 있습니다.
