---
date: '2025-10-10T16:16:13+09:00'
draft: false
title: '[번역] UNUserNotifications / Modifying Content in Newly Delivered Notifications (애플 공식 문서)'
description: "사용자의 iOS 기기에 알림이 표시되기 전에 푸시 알림의 페이로드를 수정합니다."
tags: ["UNNotificationServiceExtension"]
categories: ["UNUserNotifications"]
cover:
    image: images/docs_1.jpg
---

## Overview

아래와 같은 경우에는 사용자의 iOS 기기에서 푸시 알림의 콘텐츠를 수정해야 할 수 있습니다:

* 암호화된 형식으로 전송된 데이터를 복호화해야 할 때

* 최대 페이로드 크기를 초과하는 이미지나 다른 미디어 첨부 파일을 다운로드해야 할 때

* 사용자의 기기의 데이터를 반영해 알림의 콘텐츠를 업데이트해야 할 때

푸시 알림을 수정하려면 iOS 앱 번들에 포함되는 *Notification Service App Extension*이 필요합니다. 이 익스텐션은 시스템이 사용자에게 알림을 표시하기 전에 푸시 알림의 내용을 먼저 받아서, 알림 페이로드를 업데이트할 시간을 제공합니다. 또한 익스텐이 어떤 알림을 처리할지 개발자가 직접 제어할 수 있습니다.

> **Important**:
> *Notification Service App Extension*은 시스템에서 사용자에게 경고(alert)를 표시하도록 구성된 푸시 알림에만 동작합니다. 앱에 대해 경고가 비활성화되어 있거나, 페이로드가 단순히 사운드 재생이나 아이콘 배지 표시에만 국한되어 있는 경우에는 익스텐션이 사용되지 않습니다.


## Add a service app extension to your project

*Notification Service App Extension*은 iOS 앱 내부에 별도의 번들로 포함됩니다. 앱에 이 익스텐션을 추가하려면 아래 단계를 따르세요:

1. Xcode에서 File > New > Target을 선택합니다.

2. iOS > Application 섹션에서 *Notification Service App Extension*을 선택합니다.

3. Next를 선택합니다.

4. 앱 익스텐션의 이름과 기타 세부 정보를 지정합니다.

5. Finish를 선택합니다.


## Implement your extension's handler methods

Xcode가 제공하는 *Notification Service App Extension* 템플릿에는 기본 구현이 포함되어 있으며, 이를 수정해서 사용할 수 있습니다.

* [didReceive(_:withContentHandler:)]() 메서드를 사용하여 업데이트된 콘텐츠로 새로운 [UNMutableNotificationContent]() 객체를 생성하세요.

* [serviceExtensionTimeWillExpire()]() 메서드를 사용하여 아직 실행 중인 페이로드 수정 작업을 종료하세요.

[didReceive(_:withContentHandler:)]() 메서드는 약 30초 동안 페이로드를 수정하고 *content handler*를 호출해야 합니다. 코드 실행이 더 오래 걸리면 시스템은 [serviceExtensionTimeWillExpire()]() 메서드를 호출하며, 이때는 가능한 한 즉시 수정된 결과를 반환해야 합니다. 만약 두 메서드 어느 곳에서도 *content handler*를 호출하지 않으면, 시스템은 원래 알림 내용을 그대로 표시합니다.

아래는 푸시 알림을 통해 전달된 비밀 메시지의 내용을 복호화하는 [UNNotificationServiceExtension]() 객체의 구현 예시를 보여줍니다. [didReceive(_:withContentHandler:)]() 메서드는 데이터를 복호화하고 성공한 경우 수정된 알림 콘텐츠를 반환합니다. 복호화에 실패하거나 시간이 초과되면, 익스텐션은 여전히 암호화되어 있음을 나타내는 콘텐츠를 반환합니다.

```swift
// Storage for the completion handler and content.
var contentHandler: ((UNNotificationContent) -> Void)?
var bestAttemptContent: UNMutableNotificationContent?
// Modify the payload contents.
override func didReceive(_ request: UNNotificationRequest,
         withContentHandler contentHandler: 
         @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    // Try to decode the encrypted message data.
    let encryptedData = bestAttemptContent?.userInfo["ENCRYPTED_DATA"]
    if let bestAttemptContent = bestAttemptContent {
        if let data = encryptedData as? String {
           let decryptedMessage = self.decrypt(data: data)
           bestAttemptContent.body = decryptedMessage
        }
        else {
            bestAttempContent.body = "(Encrypted)"
        }

        // Always call the completion handler when done.
        contentHandler(bestAttemptContent)
    }
}

// Return something before time expires.
override func serviceExtensionTimeWillExpire() {
    if let contentHandler = contentHandler,
       let bestAttemptContent = bestAttempContent {
        
        // Mark the message as still encrypted.
        bestAttemptContent.subtitle = "(Encypted)"
        bestAttemptContent.body = ""
        contentHandler(bestAttemptContent)
    }
}
```


## Configure the payload for the remote notification

시스템은 푸시 알림의 페이로드에 아래 정보가 포함된 경우에만 *Notification Service App Extension*을 실행합니다:

* 페이로드에 *mutable-content* 키와 함께 값 1을 반드시 포함해야 합니다.

* 페이로드에 *title*, *subtitle* 또는 *body* 정보를 가진 *alert* 딕셔너리를 반드시 포함해야 합니다.

아래는 암호화된 데이터를 포함하는 페이로드의 JSON 데이터를 보여줍니다. 여기에는 *mutable-content* 플래그가 설정되어 있어, 사용자의 기기가 상기 작성한 *Notification Service App Extension*을 실행해야 함을 알 수 있습니다.

```json
{
    "aps" : {
        "category" : "SECRET",
        "mutable-content" : 1,
        "alert" : {
            "title" : "Scret Message!",
            "body" : "(Encrypted)"
        }
    },
    "ENCRYPTED_DATA" : "Salted__·öîQÊ$UDì_¶Ù∞èΩ^¬%gq∞NÿÒQùw"
}
```