---
date: '2025-12-15T10:22:07+09:00'
draft: false
title: '[번역] Core Location / Creating a Location Push Service Extension (애플 공식 문서)'
description: "다른 사용자의 요청에 응답해 사용자의 위치에 접근할 수 있도록 위치 공유 앱에 확장을 추가하고 구성하세요."
tags: ["Push Notification"]
categories: ["Core Location"]
cover:
    image: images/docs_1.jpg
    caption: ""
---

## Overview

iOS 15부터 제공되는 Location Push Service Extension은 앱이 실행 중이 아닐 때에도 iOS나 iPadOS 기기에 위치를 요청할 수 있게 해주는 에너지 효율적인 방법입니다.

앱에 Location Push Service Extension이 포함되어 있으면, 시스템은 서버로부터 Apple Push Notification service(APNs) 위치 푸시를 받을 때 해당 확장을 활성화합니다. 이 확장이 동작하려면, 앱이 사용자로부터 항상 허용(Always) 권한([CLAuthorizationStatus.authorizedAlways]())을 요청하고 승인받아야 합닌다. 항상 허용 권한에 대한 자세한 내용은 [Requesting authorization to use location services]()와 [requestAlwaysAuthorization()]()을 참고하세요.

사용자의 권한이 허용되면, 확장은 사용자의 위치를 조회하고 앱의 목적에 따라 해당 정보를 처리할 수 있습니다. 서버는 _location_ 푸시 타입을 사용해 APNs로 요청을 전송합니다.APNs로 요청을 보내는 방법에 대한 자세한 내용은 [Sending noification requests to APNs]()를 참고하세요.

> **Important:**
> Location Push Service Extension을 사용하려면, 앱에 [Location Push Service Extension]() 권한(entitlement)이 포함되어 있어야 합니다. 이 서비스 확장을 구현하기 전에 해당 권한을 요청해야 합니다. 권한을 신청하려면 계정 관리자(Account Holder) 역할의 개발자 계정으로 로그인한 뒤 [요청 양식]()을 작성하세요.


## Configure Your Xcode Project

앱에 Location Push Service Extension을 포함하려면 Xcode 13 이상을 사용해야 합니다. Xcode 프로젝트에서 다음 권한(entitlements), 기능(capabilities), 그리고 키(keys)를 구성하세요.

1. Location Push Service Extension 권한 키([Location Push Service Extension]())를 설정하세요.

2. 앱이 Apple Push Notification service(APNs) 푸시를 받을 수 있도록 Push Notification 기능을 추가하세요. 자세한 내용은 [Registering your app with APNs]()를 참고하세요.

3. 위치 서비스 권한 요청 시 표시되는 안내 문구(purpose string)를 작성하세요. 자세한 내용은 [Requesting authorization to use location services]()를 참고하세요.


## Add a Location Push Service Extension Target

Location Push Service Extension 템플릿을 사용해 새로운 타겟을 추가하세요.

1. Xcode에서 iOS 프로젝트를 엽니다.

2. File > New > Target을 선택합니다.

3. iOS Application Extension 그룹에서 Location Push Service Extension을 선택합니다.

4. Next를 클릭합니다.

5. 확장의 이름을 지정하고 언어 및 기타 옵션을 설정합니다.

6. Finish를 클릭합니다.

Xcode는 시작을 돕기 위해 [CLLocationPushServiceExtension]()의 서브 클래스를 생성해줍니다.


## Implement Location Push Functionality

위치 푸시 기능을 지원하려면, 확장, 앱, 그리고 서버에 다음 코드를 구현하세요.

1. 서비스 확장에서 [CLLocationPushServiceExtension]() 프로토콜을 구현하세요.

2. 서비스 확장에서 위치 요청의 결과를 처리하고 받은 위치 데이터를 가공하기 위해 [locationManager(_:didUpdateLocation:)]() 메서드를 구햔하세요.

3. 앱에서 [startMonitoringLocationPushes(completion:)]()을 호출해 APNs 토큰을 Data 형태로 받아 서버로 전송하세요. 서버는 이 토큰을 APNs 푸시를 생성할 때 사용합니다.

4. 서버에서 APNs로 _location_ 푸시 요청을 전송하여 위치 정보를 요청하세요.

사용자가 앱에 항상 허용 권한([CLAuthorizationStatus.authorizedAlways]())을 부여한 경우, 시스템은 _location_ 푸시를 수신하면 서비스 확장을 활성화하고 [didReceiveLocationPushPayload(_:completion:)]()을 호출합니다. 앱은 적절한 시점에 사용자에게 항상 허용 권한을 요청해야 합니다.

> **Important:**
> 위치 데이터를 다룰 때는 사용자 프라이버시를 보호하는 것이 중요합니다. 앱이 위치 데이터를 서버나 다른 사용자에게 전송하는 등 기기 밖으로 이동시키는 경우, 종단 간 암호화를 적용하면 보안을 한층 강화할 수 있습니다. 자세한 내용은 [Protecting the User's Privacy]()를 참고하세요.

## Send Location Push Requests From Your Server

한 사용자가 다른 사용자의 위치를 요청하면, 앱은 해당 요청을 서버로 전송하고, 서버는 APNs로 위치 푸시 요청을 보냅니다. 이때 APNs에 보내는 POST 요청에는 _ location_ 푸시 타입에 대해 다음 필드들이 포함되어야 합니다.

* method
    + (필수) 값은 _POST_&#8203;입니다.

* path
    + (필수) 기기 토큰으로의 경로입니다. 이 헤더의 값은 /3/device/<device_token> 형식이며, <device_token>은 사용자의 기기를 나타내는 16진수 식별자입니다. 앱이 위치 푸시 모니터링을 시작하기 위해 [startMonitoringLocationPushes(completion:)]()을 호출할 때 이 토큰을 받습니다.

* authorization
    + (토큰 기반 인증에 필수) 이 헤더의 값은 bearer <provider_token> 형식입니다. 여기서 <provider_token>은 지정된 토픽에 대해 알림을 보낼 수 있도록 인증하는 암호화된 토큰입니다. 자세한 내용은 [Establishing a token-based connection to APNs]()를 참고하세요.

* apns-topic
    + 토픽은 앱의 번들 ID에 “.location-query” 접미사가 붙은 값입니다.

* apns-push-type
    + (권장) 이 헤더의 값은 _location_&#8203;입니다.

* apns-priority
    + 알림의 우선순위를 나타냅니다. 이 헤더를 생략하면 APNs는 기본적으로 알림 우선순위를 10으로 설정합니다. 사용자가 위치 조회를 직접 시작한 경우, 이 헤더를 10으로 설정하세요. 앱의 서버가 위치 조회를 시작하는 경우(예: 주기적으로 요청하는 경우), 사용자 기기의 전력 사용을 고려해 이 헤더를 5로 설정하세요.

APNs 요청 전송 및 명령줄 도구를 사용한 전송 방법에 대한 자세한 내용은 [Sending notification requests to APNs]()와 [Sending push notifications using command-line tools]()를 참고하세요.

