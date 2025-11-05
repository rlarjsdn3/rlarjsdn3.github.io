---
date: '2025-12-05T19:29:00+09:00'
draft: false
title: '[번역] Core Location / Handling Location Updates in the Background (애플 공식 문서)'
description: "앱이 포그라운드에서 실행 중이지 않을 때에도 위치 업데이트를 받을 수 있도록 앱을 구성하세요."
tags: ["CLServiceSession", "CLBackgroundActivitySession", "CLMonitor", "CLLocationUpdate"]
categories: ["Core Location"]
cover:
    image: images/docs_1.jpg
    caption: ""
---

## Overview

일부 Apple 기기에서는 운영체제가 백그라운드 앱의 실행을 일시 중단(suspend)하여 배터리 수명을 절약합니다. 예를 들어, iOS, iPadOS, 그리고 watchOS에서는 대부분의 앱이 백그라운드로 전환된 직후 시스템에 의해 실행이 중단됩니다. 이러한 일시 중단 상태에서는 앱이 실행되지 않으며 시스템으로부터 위치 업데이트를 받을 수 없습니다. 대신 시스템은 위치 업데이트를 큐에 저장해두었다가, 앱이 다시 포그라운드나 백그라운드에서 실행될 때 이를 한꺼번에 전달합니다. 앱이 보다 시의적절하게 업데이트를 받아야 하는 경우, 위치 서비스가 활성화되어 있는 동안 시스템이 앱을 일시 중단하지 않도록 요청할 수 있습니다.

앱이 정말로 백그라운드 위치 업데이트가 필요한지 신중히 고려해야 합니다. 대부분의 앱은 사용자가 앱을 적극적으로 사용할 때만 위치 데이터가 필요합니다. 앱이 실시간으로 업데이트를 받아야 하는 경우에만 백그라운드 업데이트를 고려하세요. 예를 들어 아래와 같은 경우가 있습니다.

* 하이킹이나 피트니스 운동 중 이동한 정확한 경로를 추적해야 하는 경우

* 실시간으로 내비게이션 안내를 제공해야 하는 경우

* 시간에 민감한 알림인 업데이트를 생성해야 하는 경우

* 특정 지리 영역에 사용자가 진입하거나 이탈했을 때 즉시 동작을 수행해야 하는 경우

iOS, iPadOS 또는 watchOS 앱에서 백그라운드 위치 업데이트가 필요하다면, 프로젝트를 해당 기능을 지원하도록 설정해야 합니다. macOS에서는 앱이 백그라운드로 전환되더라도 시스템이 앱 실행을 일시 중단하지 않기 때문에 별도의 백그라운드 업데이트 지원을 추가할 필요가 없습니다. visionOS에서 실행되는 앱은 백그라운드 업데이트를 받을 수 없습니다.


## Add the background mode capability

백그라운드 모드(Background Mode) 기능은 시스템에 앱이 백그라운드 업데이트를 사용하는지 여부를 알리는 역할을 합니다. 이 기능을 추가하려면 앱 타겟의 _Signing & Capabilities_ 탭으로 이동한 뒤, _Location Updates_ 옵션을 활성화하세요. 이 기능을 활성화하면, Xcode가 앱의 Info.plist 파일에 백그라운드 업데이트를 지원함을 나타내는 데 필요한 키를 자동으로 추가합니다.

{{< figure src="media-4061646.png" width="650px" align="center" >}}


## Receive location updates in the background

위치 업데이트를 받을 수 있도록 백그라운드 활동 세션을 시작하려면 [CLBackgroundActivitySession]() 인스턴스를 생성하세요. 백그라운드로 가기 전에 위치 업데이트를 받을 것임을 알리고, 실제로 업데이트가 도착했을 때 이를 처리하는 것은 앱의 책임입니다. 

관련 권한 형태([CLServiceSession.AuthorizationRequirement.always]() 또는 [CLServiceSession.AuthorizationRequirement.whenInUse]())를 요구하는 [CLServiceSession]()을 생성하세요. 이 세션은 앱이 포그라운드에 있을 때 생성해야 합니다. 앱이 종료되면, 백그라운드에서 다시 실행될 때 즉시 [CLServiceSession]()을 다시 생성해야 합니다.

[CLMonitor]() 이벤트를 처리하거나, [CLLocationUpdate]()를 사용하거나, [CLBackgroundActivitySession]()을 사용할 때 Core Location은 자동으로 '사용하는 동안 허용(When in Use)' 권한으로 설정합니다. 예외가 있다면 앱의 _Info.plist_&#8203;에 _NSLocationRequireExplicitServiceSession_&#8203;을 설정한 경우입니다.

> **Important:**
> 항상 허용(Always) 권한을 사용하는 경우, 위치 업데이트가 백그라운드에서 도착한다는 사실을 사용자에게 알려야 합니다. 이는 투명성을 제공하고 사용자에게 어떤 일이 발생하고 있는지 이해할 수 있도록 돕습니다.


## Process location updates after an app launch

시스템은 메모리나 기타 시스템 자원을 확보하기 위해 언제든지 앱을 종료할 수 있습니다. 앱이 위치 업데이트를 적극적으로 수신하고 처리하는 중에 종료되었다면, 다시 실행될 때 이러한 업데이트를 계속 받기 위해 관련 API를 다시 시작해야 합니다. 이러한 서비스를 시작하면, 시스템은 큐에 저장되어 있던 위치 업데이트의 전달을 재개합니다. 단, 앱의 권한 상태가 아직 결정되지 않은 경우(undetermined)에는 앱 실행 시점에 이러한 서비스를 시작하면 안됩니다.