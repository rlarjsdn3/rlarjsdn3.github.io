---
date: '2025-09-25T20:41:44+09:00'
draft: false
title: '[번역] UNUserNotifications / Registering Your App With APNs (애플 공식 문서)'
description: "Apple 푸시 알림 서버(APNs)와 통신하여 앱을 식별하는 고유한 디바이스 토큰을 받으세요."
tags: ["Remote Notifications", "UIApplication"]
categories: ["UNUserNotifications"]
cover:
    image: images/docs_1.jpg
---

## Overview

Apple 푸시 알림 서비스 (APNs)가 특정 사용자의 기기로 알림을 전송하려면, 먼저 그 기기의 주소를 알아야 합니다. 이 주소는 기기와 앱 모두에 고유한 디바이스 토큰(device token)의 형태로 제공됩니다. 앱이 실행될 때, 앱은 APNs와 통신하여 디바이스 토큰을 받고, 이 토큰을 여러분의 제공자 서버(provider server)로 전달합니다. 이후 서버는 알림을 전송할 때 토큰을 함께 포함시켜야 합니다. 

> **Note**: 
> 같은 기기라 하더라도 여러 앱이 하나의 디바이스 토큰을 함께 사용할 수는 없습니다. 각 앱은 반드시 자신만의 고유한 디바이스 토큰을 요청해 받아야 하며, 그 토큰을 제공자 서버로 전달해야 합니다.

## Enable the push nootifications capability

앱에 필요한 권한을 추가하려면, Xcode 프로젝트에서 푸시 알림 기능(Push Notifications Capability)를 활성화해야 합니다. iOS에서 이 옵션을 활성화하면 앱에 [APS Environment Entitlement](https://developer.apple.com/documentation/BundleResources/Entitlements/aps-environment)가 추가되고, macOS에서는 [APS Environment (macOS) Entitlement](https://developer.apple.com/documentation/BundleResources/Entitlements/com.apple.developer.aps-environment) 권한이 추가됩니다. 더 자세한 내용은 Xcode 도움말의 [Enable push notifications](https://help.apple.com/xcode/mac/current/#/devdfd3d04a1)를 참고하세요.

{{< figure src="media-4321361.png" width="250px" align="center" >}}

> **Important**:
> 개발자 계정에서 프로젝트에 할당된 App ID에 대해 푸시 알림 서비스를 활성화해야 합니다. 개발자 계정 설정에 대한 더 자세한 내용은 [Develop Account](https://developer.apple.com/account/#/overview/) 페이지를 참고하세요.

## Register your app and retrieve your app's device token

앱을 APNs에 등록하고 전역적으로 고유한 디바이스 토큰을 받아야 합니다. 이 토큰은 현재 기기에서 앱의 주소 역할을 합니다. 제공자 서버에서 기기로 알림을 전송하기 전에 반드시 이 토큰을 가지고 있어야 합니다.

앱을 등록하고 디바이스 토큰을 받는 과정은 앱이 실행될 때마다 Apple에서 제공하는 API를 사용하여 이루어집니다. 이 등록 절차는 플랫폼 전반에서 유사하게 동작합니다.

* iOS와 tvOS에서는 [UIApplication](https://developer.apple.com/documentation/UIKit/UIApplication)의 [registerForRemoteNotifications()](https://developer.apple.com/documentation/UIKit/UIApplication/registerForRemoteNotifications()) 메서드를 호출하여 디바이스 토큰을 요청합니다. 등록에 성공하면, 앱 델리게이트의 [application(_:didRegisterForRemoteNotificationsWithDeviceToken:)](https://developer.apple.com/documentation/UIKit/UIApplicationDelegate/application(_:didRegisterForRemoteNotificationsWithDeviceToken:)) 메서드에서 해당 토큰을 받게 됩니다.

* macOS에서는 [NSApplication](https://developer.apple.com/documentation/AppKit/NSApplication)의 [registerForRemoteNotifications()](https://developer.apple.com/documentation/AppKit/NSApplication/registerForRemoteNotifications()) 메서드를 호출하여 디바이스 토큰을 요청합니다. 등록에 성공하면, 앱 델리게이트의 [application(_:didRegisterForRemoteNotificationsWithDeviceToken:)](https://developer.apple.com/documentation/AppKit/NSApplicationDelegate/application(_:didRegisterForRemoteNotificationsWithDeviceToken:)) 메서드에서 해당 토큰을 받게 됩니다.

* watchOS에서는 [WKExtension](https://developer.apple.com/documentation/WatchKit/WKExtension)의 [registerForRemoteNotifications()](https://developer.apple.com/documentation/WatchKit/WKApplication/registerForRemoteNotifications()) 메서드를 호출하여 디바이스 토큰을 요청합니다. 등록에 성공하면, 익스텐션 델리게이트의 [didRegisterForRemoteNotifications(withDeviceToken:)](https://developer.apple.com/documentation/WatchKit/WKApplicationDelegate/didRegisterForRemoteNotifications(withDeviceToken:)) 메서드에서 해당 토큰을 받게 됩니다.

앱은 APNs 등록이 성공했을 때뿐만 아니라 실패했을 때도 처리할 수 있도록 준비해야 합니다. 이를 위해 [application(_:didFailToRegisterForRemoteNotificationsWithError:)](https://developer.apple.com/documentation/UIKit/UIApplicationDelegate/application(_:didFailToRegisterForRemoteNotificationsWithError:)) 메서드를 구현해야 합니다. APNs 등록은 사용자의 기기가 네트워크에 연결되지 않았거나, APNs 서버에 어떤 이유로든 접근할 수 없거나, 앱에 올바른 코드 서명 권한(code-signing entitlement)이 없을 경우 실패할 수 있습니다. 실패가 발생하면 플래그를 설정해 두고, 나중에 다시 등록을 시도해야 합니다.

아래는 푸시 알림을 등록하고 디바이스 토큰을 받기 위해 필요한 iOS 앱 델리게이트 메서드의 구현 예시를 보여줍니다. *sendDeviceTokenToServer* 메서드는 앱이 받은 데이터를 제공자 서버로 전송하기 위해 사용하는 커스텀 메서드입니다.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    UIApplication.shared.registerForRemoteNotifications()
    return true
}

func application(_ application: UIApplication, didRegisterForRemoteForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    self.sendDeviceTokenToServer(data: deviceToken)
}

func application(_ application: UIApplication,
                 didFailToRegisterForRemoteNotificationsWithError
                 error: Error) {
    // Try agian later.
}
```

> **Important**:
> 디바이스 토큰을 로컬 저장소에 캐시해서는 안 됩니다. 사용자가 백업에서 기기를 복원하거나, 새 기기에 앱을 설치하거나, 운영체제를 재설치할 때 APNs는 새로운 토큰을 발급합니다. 시스템에 토큰을 요청할 때마다 최신 토큰을 받게 됩니다.

## Forward tokens to your provider server

디바이스 토큰을 받으면, 앱에서 제공자 서버로 네트워크 연결을 열어야 합ㄴ디ㅏ. 이때 디바이스 토큰과 특정 사용자를 식별하는 데 필요한 추가 정보를 안전하게 서버로 전달해야 합니다. 예를 들어, 사용자의 로그인 이름이나 서브스와 연결할 수 있는 다른 정보를 포함할 수 있습니다. 네트워크를 통해 전송하는 모든 정보는 반드시 암화화해야 합니다.

제공자 서버에서는 알림을 보낼 수 있도록 디바이스 토큰을 안전하게 저장해야 합니다. 알림을 생성할 때 서버는 특정 기기로 알림을 전송할 수 있어야 합니다. 따라서 알림이 사용자의 계정과 연결되어 있다면, 디바이스 토큰을 사용자 계정 정보와 함께 저장해야 합니다. 한 사용자가 여러 기기를 가질 수 있으므로, 앱은 여러 디바이스 토큰을 처리할 수 있도록 준비해야 합니다. 페이로드와 디바이스 토큰을 APNs로 전송하는 방법에 대한 자세한 내용은 [Sending notification requests to APNs](https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns)를 참고하세요.