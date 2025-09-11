---
date: '2025-09-15T20:36:49+09:00'
draft: false
title: '[번역] UNUserNotifications / Registering your app with APNs (애플 공식 문서)'
description: "알림을 서로 구분하고 알림 인터페이스에 액션 버튼을 추가하세요."
tags: ["UNNotificationAction", "UNNotificationCategory"]
categories: ["UNUserNotifications"]
cover:
    image: images/docs_1.jpg
    caption: ""
draft: true
---

## Overview

동작 가능한 알림(actionable notification)은 사용자가 해당 앱을 실행하지 않고도 전달된 알림에 응답할 수 있게 합니다. 일반 알림은 알림 인터페이스에 정보를 표시하고, 이 경우 사용자가 취할 수 있는 유일한 동작은 앱을 실행하는 것이 됩니다. 동작 가능한 알림의 경우, 시스템은 알림 인터페이스 외에도 하나 이상의 버튼을 표시합니다. 버튼을 누르면 선택된 동작이 앱으로 전달되고, 앱은 이를 백그라운드에서 처리합니다.

{{< figure src="media-2953609.png" width="200px" align="center" >}}

> **Note**:
> Apple Watch Series 9 또는 Apple Watch Ultra 2에서 알림을 보고 있는 동안 이중 탭(Double Tap) 제스처를 수행하면, 시스템은 첫 번째 비파괴(Non-Desctructive) 동작을 실행합니다. 비파괴 동작이란 [destructive](https://developer.apple.com/documentation/usernotifications/unnotificationactionoptions/destructive) 옵션을 포함하지 않으며, 사용자가 데이터를 삭제하거나, 다시 되돌리기가 어렵지 않은 동작을 의미합니다.

동작 가능한 알림을 지원하려면 다음을 수행해야 합니다.

* iOS 앱 실행 시, 하나 이상의 알림 카테고리(Notification Category)를 선언합니다.

* 알림 카테고리에 적절한 동작을 할당합니다.

* 등록한 모든 동작을 처리합니다.

* 알림을 생성할 때, 알림 페이로드에 카테고리 식별자를 할당합니다.

> **Note**:
> 시스템은 또한 카테고리를 사용하여 _Notification Service App Extension_이나 _Notification Content App Extension_을 실행해야 하는지 여부를 결정합니다. 새로 전달된 알림의 콘텐츠를 수정하는 방법에 대한 자세한 내용은 [Modifying content in newly deliverd notifications](https://developer.apple.com/documentation/usernotifications/modifying-content-in-newly-delivered-notifications)를 참고해주시고, 알림의 모습을 사용자화하는 방법에 대한 자세한 내용은 [Customizing the Appearance of Notifications](https://developer.apple.com/documentation/UserNotificationsUI/customizing-the-appearance-of-notifications)를 참고하시기 바랍니다.


## Declare your custom actions and notification types

앱의 모든 동작을 처리해야 하므로, 앱이 지원하는 동작을 실행 시점에 선언해야 합니다. 동작은 카테고리와 액션 객체를 조합하여 선언합니다. [UNNotificationCategory](https://developer.apple.com/documentation/usernotifications/unnotificationcategory) 객체는 앱이 지원하는 알림의 종류를 정의하고, [UNNotificationAction](https://developer.apple.com/documentation/usernotifications/unnotificationaction) 객체는 각 종류 별로 표시할 버튼을 정의합니다. 예를 들어, 회의 초대 알림에는 초대를 수락하거나 거절하는 버튼이 포함될 수 있습니다. 

각 [UNNotificationCategory](https://developer.apple.com/documentation/usernotifications/unnotificationcategory) 객체는 고유한 식별자와 해당 유형의 알림을 처리하는 방법에 대한 옵션을 가집니다. [identifier](https://developer.apple.com/documentation/usernotifications/unnotificationcategory/identifier) 프로퍼티의 문자열은 카테고리 객체에서 가장 중요한 부분입니다. 알림을 생성할 때는 반드시 동일한 문자열을 알림의 페이로드에 포함시켜야 합니다. 시스템은 이 문자열을 사용해 해당 카테고리 객체와 연결된 동작들을 찾습니다. 

알림 카테고리에 동작을 연결하려면 하나 이상의 [UNNotificationAction](https://developer.apple.com/documentation/usernotifications/unnotificationaction) 객체를 알림 카테고리에 할당하면 됩니다. 각 액션 객체는 로컬라이즈된 문자열과 해당 동작을 어떻게 처리할지 나타내는 옵션이 포함됩니다. 예를 들어, 동작에 파괴적(destructvie) 옵션을 지정하면 시스템은 그 동작의 특성을 알리기 위해 다른 강조 표시와 함께 보여줍니다.

아래 예제는 두 개의 동작이 있는 사용자 지정 카테고리를 등록하는 방법을 보여줍니다. 각 동작은 제목과 옵션 외에도 고유한 식별자를 가집니다. 사용자가 동작을 선택하면, 시스템은 해당 식별자를 앱에 전달합니다.

```swift
// Define the custom actions.
let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
	title: "Accept",
    options: [])
let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
	titleL "Decline",
    options: [])
// Define the notification type
let meetingInviteCategory = UNNotificationCategory(identifier: "MEETING_INVITATION",
	actions: [acceptAction, declineAction],
    intentIdentifiers: [],
    hiddenPreviewsBodyPlaceholder: "",
    options: .customDismissAction)
// Register the notification type.
let notificationCenter = UNUserNotificationCenter.current()
notificationCenter.setNotificationCategories([meetingInviteCategory])
```

> **Important**:
> 모든 액션 객체는 고유한 식별자를 가져야 합니다. 동작이 서로 다른 카테고리에 속해 있더라도 식별자는 하나의 액션을 다른 액션과 구분할 수 있는 유일한 방법입니다.  

대부분의 동작은 사용자의 선택으로 끝나지만, 텍스트 입력 동작은 사용자가 직접 텍스트 기반 입력을 할 수 있게 합니다. 앱은 사용자가 입력한 응답을 동작 처리에 반영할 수 있습니다. 예를 들어, 메시지 앱은 입력된 텍스트를 수신 메시지에 대한 응답으로 전송할 수 있습니다. 텍스트 입력 동작을 만들려면 [UNNotificationAction](https://developer.apple.com/documentation/usernotifications/unnotificationaction) 객체 대신 [UNTextInputNotificationAction](https://developer.apple.com/documentation/usernotifications/untextinputnotificationaction) 객체를 생성해야 합니다. 사용자가 텍스트 입력 동작 버튼을 누르면, 시스템은 편집 가능한 텍스트 필드를 표시합니다. 이후 앱으로 동작이 전달될 때 시스템은 입력한 텍스트를 응답의 일부로 표함합니다.


## Include a notification category in the payload

시스템은 페이로드에 올바른 카테고리 식별자 문자열이 포함된 알림에만 동작을 표시합니다. 시스템은 카테고리 식별자를 사용해 앱에 등록된 카테고리와 그에 연결된 동작을 조회합니다. 그런 다음 해당 정보를 활용해 알림 인터페이스에 액션 버튼을 추가합니다.

로컬 알림에 카테고리를 할당하려면 [UNMutableNotificationContent](https://developer.apple.com/documentation/usernotifications/unmutablenotificationcontent) 객체의 [categoryIdentifier](https://developer.apple.com/documentation/usernotifications/unmutablenotificationcontent/categoryidentifier) 프로퍼티에 적절한 문자열을 할당하면 됩니다. 아래 예제는 로컬 알림의 콘텐츠를 생성하는 예제를 보여줍니다. 기본 정보 외에도 알림의 [userInfo](https://developer.apple.com/documentation/usernotifications/unnotificationcontent/userinfo) 딕셔너리에 사용자 정의 데이터를 추가하여, 이후 초대 요청을 처리할 때 이 데이터를 사용하도록 합니다.

```swift
let content = UNMutableNotificationContent()
content.title = "Weekly Staff Meeting"
content.boddy = "Every Tuesday at 2pm"
content.userInfo = ["MEETING_ID": meetingID,
					"USER_ID": userID]
content.categoryIdentifier = "MEETING_INVITATION"
```

원격 알림에 카테고리 식별자를 추가하려면 JSON 페이로드의 _aps_ 딕셔너리에 _category_ 키를 포함해야 합니다. 카테고리 문자열은 이 키의 값으로 설정됩니다. 예제에서는 카테고리가 앞서 정의한 _MEETING_INVITATION_으로 정의되어 있습니다. 로컬 알림 예제와 마찬가지로, 페이로드에는 _MEETING_ID_와 _USER_ID_ 같은 사용자 정의 키가 포함되며, 이는 페이로드의 [userInfo](https://developer.apple.com/documentation/usernotifications/unnotificationcontent/userinfo) 딕셔너리에 저장됩니다. 앱은 이 정보를 활용해 초대를 수락하거나 거절할 수 있습니다.

```
{
   "aps" : {
      "category" : "MEETING_INVITATION"
      "alert" : {
         "title" : "Weekly Staff Meeting"
         "body" : "Every Tuesday at 2pm"
      },
   },
   "MEETING_ID" : "123456789",
   "USER_ID" : "ABCD1234"

} 
```

## Handle the selected action

앱은 정의된 모든 동작을 반드시 처리해야 합니다. 사용자가 어떤 동작을 선택하면 시스템은 앱을 백그라운드에서 실행하고 [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter) 객체에 알리며, 이 객체는 자신의 델리게이트에 알립니다. 델리게이트 객체의 [userNotificationCenter(_:didReceive:withCompletionHandler:)](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/usernotificationcenter(_:didreceive:withcompletionhandler:)) 메서드를 사용해 선택된 동작을 식별하고 그에 맞는 처리를 수행하세요.

아래 예제는 회의 초대를 관리하는 앱에서 델리게이트 메서드를 구현한 예시를 보여줍니다. 이 메서드는 _response_의 [actionIdentifier](https://developer.apple.com/documentation/usernotifications/unnotificationresponse/actionidentifier) 프로퍼티를 사용하여 초대를 수락할지 거절할지를 결정합니다. 또한 알림 페이로드에 포함된 사용자 정의 데이터를 활용해 알림을 처리합니다. 동작 처리를 마친 후에는 반드시 _completion handler_를 호출해야 합니다.

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
	
	// Get the meeting ID from the original notification.
    let userInfo = response.notification.request.content.userInfo
    let meetingID = userInfo["MEETING_ID"] as! String
    let userID = userInfo["USER_ID"] as! String
    
    // Perform the task associated with the action.
    switch response.actionIdentifier {
    case "ACCEPT_ACTION":
    	sharedMeetingManager.acceptMeeting(user: userID,
        								   meetingID: meetingID)
        break
        
    case "DECLINE_ACTION":
    	sharedMeetingManager.declineMeeting(user: userID,
        								    meetingID: meetingID)
        break
    
    // Handle other actions...
    default:
    	break
    }
    
    // Always call the completion handler when done.
    completionHandler()
}
```

> **Important**:
> 동작에 대한 응답이 디스크의 파일에 접근하는 것을 포함한다면, 다른 접근 방식을 고려해야 합니다. 사용자는 기기가 잠겨있는 상태에서도 동작에 응답할 수 있는데, 이 경우 [complete](https://developer.apple.com/documentation/Foundation/FileProtectionType/complete) 옵션으로 암호화된 파일은 앱에서 접근할 수 없습니다. 이런 상황에서는 변경 사항을 임시로 저장해 두었다가 나중에 앱이 관리하는 실제 데이터 저장소에 반영해야할 수 있습니다.



