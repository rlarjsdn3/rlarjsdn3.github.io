---
date: '2025-09-20T14:21:37+09:00'
draft: false
title: '[번역] UNUserNotifications / Handling Notifications and Notification Related Actions'
description: "시스템의 알림 인터페이스에서 발생하는 사용자 상호작용에 응답하고, 앱의 사용자 지정 동작을 처리하세요."
tags: ["UNUserNotificationCenter", "UNNotificationAction", "UNNotificationCategory"]
categories: ["UNUserNotifications"]
cover:
    image: images/docs_1.jpg
---

## Overview

알림은 주로 사용자에게 정보를 보여주기 위한 수단이지만, 앱이 알림에 응답할 수도 있습니다. 예를 들어, 다음과 같은 상황에 응답할 수 있습니다:

* 사용자가 알림 인터페이스에서 선택한 동작

* 앱이 포그라운드에서 실행 중일때 도착한 알림

* 무음(Slient) 알림 ([Pushing background updates to your App](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app)을 참고)

* [PushKit](https://developer.apple.com/documentation/PushKit) 프레임워크와 관련된 알림 (예를 들어, VolP나 WatchOS의 컴플리케이션(complication) 관련 알림)

## Handle user-selected actions

동작 가능한 알림은 사용자가 알림 인터페이스에서 직접 응답할 수 있게 해줍니다. 알림의 콘텐츠 외에도, 동작 가능한 알림은 사용자가 선택할 수 있는 하나 이상의 버튼을 표시합니다. 사용자가 버튼 중 하나를 탭하면 앱이 포그라운드로 전환되지 않고, 선택된 동작이 앱으로 전달됩니다. 앱이 동작 가능한 알림 타입을 지원한다면, 반드시 그에 연결된 동작을 처리해야 합니다.

{{< figure src="media-2953610.png" width="300px" align="center" >}}

> **Note**:
> 동작 가능한 알림 타입은 앱이 지원하는 카테고리를 선언할 때와 동일하게, 앱 실행 시점에 선언합니다. 더 자세한 내용은 [Declaring your actionable notification types](https://developer.apple.com/documentation/usernotifications/declaring-your-actionable-notification-types)을 참고하세요.

선택된 동작은 [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter) 공유 객체의 델리게이트에서 처리합니다. 사용자가 동작을 선택하면, 시스템은 앱을 백그라운드에서 실행하고 델리게이트의 [userNotificationCenter(_:didReceive:withCompletionHandler:)](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/usernotificationcenter(_:didreceive:withcompletionhandler:)) 메서드를 호출합니다. 이때 *response* 객체의 [actionIdentifier](https://developer.apple.com/documentation/usernotifications/unnotificationresponse/actionidentifier) 속성 값을 앱이나 시스템에서 정의한 동작과 매칭해야 합니다. 사용자가 알림을 닫거나 앱을 실행할 때는 시스템은 앱에 특별한 신호를 전달합니다. 

아래는 회의 초대와 관련된 동작을 처리하는 예제를 보여줍니다. *ACCEPT_ACTION*와 *DECLINE_ACTION* 문자열은 앱에서 정의한 동작을 식별하며, 각각 회의 초대한 대한 적절한 응답을 생성합니다. 사용자가 앱에서 정의한 동작 중 하나를 선택하지 않으면, 메서드는 관련 데이터를 저장해 두었다가 사용자가 앱을 실행할 때 처리합니다.

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: 
               @escaping () -> Void) {
    // Get the meeting ID from the original notification.
    let userInfo = response.notification.request.content.userInfo

    if response.notification.request.content.categoryIdentifier == "MEETING_INVITATION" {
        // Retrieve the meeting details.
        let meetingID = userInfo["MEETING_ID"] as! String
        let userID = userInfo["USER_ID"] as! String

        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            sharedMeetingManager.acceptMeeting(user: userID, meetingID: meetingID)
        break

        case "DECLINE_ACTION":
            sharedMeetingManager.declineMeeting(user: userID, meeting: meetingID)
        break

        case UNNotificationDefaultActionIdentifier,
             UNNotificationDismissActionIdentifier:
        // Queue meeting-related notifications for later
        //  if the user does not act.
        sharedMeetingManager.queueMeetingForDelivery(user: userID, meetingID: meetingID)
        break

        default:
            break
        }
    } 
    else {
        // Handle other notification types...
    }

    // Always call the completion handler when done.
    completionHandler()
}
```

## Handle notifications while your app runs in the foreground

앱이 포그라운드에서 실행 중일 때 알림이 도착하면, 시스템은 해당 알림을 앱에 직접 전달합니다. 알림을 받으면 알림의 페이로드를 사용해 원하는 동작을 수행할 수 있습니다. 예를 들어, 알림에 담긴 새로운 정보를 활용하여 앱의 인터페이스를 업데이트할 수 있습니다. 이후 예약된 알림을 표시하지 않거나, 해당 알림을 수정할 수도 있습니다.  

알림이 도착하면 시스템은 [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter) 객체의 델리게이트 메서드인 [userNotificationCenter(_:willPresent:willCompletionHandler:)](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/usernotificationcenter(_:willpresent:withcompletionhandler:))를 호출합니다. 이 메서드를 통해 알림을 처리하고, 시스템에 알림을 어떻게 처리할 지 알려줄 수 있습니다. 아래는 캘린더 앱에서 이 메서드를 구현한 예시를 보여줍니다. 회의 초대 알림이 도착하면 앱은 *queueMeetingForDelivery* 메소드를 호출하여 새로운 초대를 앱의 인터페이스에 표시합니다. 또한, *completion handler*에 [sound](https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/sound) 값을 전달하여 시스템에 알림 사운드를 재생하도록 요청합니다. 그 외의 알림 타입에 대해서는 알림을 무음 처리합니다.

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
         willPresent notification: UNNotification,
         withCompletionHandler completionHandler: 
            @escaping (UNNotificationPresentationOptions) -> Void) {
    if notification.request.content.categoryIdentifier == "MEETING_INVITATION" {
        // Retrieve the meeting details.
        let meetingID = notification.request.content.userInfo["MEETING_ID"] as! String
        let userID = notification.request.content.userInfo["USER_ID"] as! String

        // Add the meeting to the queue.
        sharedMeetingManager.queueMeetingForDelivery(user: userID, meetingID: meetingID)

        // Play a sound to let the user know about the invitation.
        completionHandler(.sound)
        return
    }
    else {
      // Handle other notification types...
    }

    // Don't alert the user for other types
    completionHandler(UNNotificatioPresentationOptions(rawValue: 0))
}
```

앱이 PushKit에 등록되어 있다면, PushKit 타입을 대상으로 하는 알림은 항상 사용자에게 표시되지 않고 앱으로 직접 전달됩니다. 앱이 포그라운드나 백그라운드에 있을 경우, 시스템은 해당 알림을 처리할 시간을 제공합니다. 앱이 실행 중이 아니라면, 시스템은 앱을 백그라운드에서 실행시켜 알림을 처리할 수 있도록 합니다. PushKit 알림을 보내려면, 제공자 서버(Provider Server)에서 알림의 *topic*을 앱의 컴플리케이션과 같은 적절한 타깃에 맞게 설정해야 합니다. PushKit 알림 등록에 대한 더 자세한 내용은 [PushKit](https://developer.apple.com/documentation/PushKit)을 참고하세요.