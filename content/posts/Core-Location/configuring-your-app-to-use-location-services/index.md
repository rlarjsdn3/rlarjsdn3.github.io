---
date: '2025-10-15T23:08:40+09:00'
draft: true
title: '[번역] Core Location / Configuring Your App to Use Location Services (애플 공식 문서)'
description: "앱이 위치 데이터 수집을 시작할 수 있도록 준비하세요."
tags: ["CLLocationManger", "CLServiceSession"]
categories: ["Core Location"]
cover:
    image: images/docs_1.jpg
---

# Overview

대부분의 Apple 기기에서 제공되는 위치 데이터는 앱의 콘텐츠에 추가적인 맥락과 정보를 더할 수 있게 해줍니다. 예를 들어, 사용자의 실제 위치를 지도에 표시하여 주변을 탐색하도록 하거나, 식당과 상점 목록에 위치 데이터를 적용해 근처에 없는 선텍지를 제외할 수 있습니다. 또한 특정 기기나 지정된 지역 근처에 있을 때 알림을 제공하는 데에도 위치 데이터를 활용할 수 있습니다. 이러한 모든 사용 사례와 그 외 다양한 경우에 대해 Core Location 프레임워크는 필요한 위치 데이터에 접근할 수 있도록 지원합니다.

Core Location을 지원하는 코드를 추가할 때는 위치 데이터를 사용할 수 없는 상황을 고려해야 합니다. 시스템은 앱이 위치 데이터를 사용하기 위해 반드시 권한을 얻도록 요구하며, 권한 없이는 위치 정보를 획득하지 못하도록 막습니다. 어떤 이유로든 위치 데이터를 사용할 수 없는 경우에는 그 상황에서도 가능한 최선의 앱 경험을 제공해야 합니다. 위치 데이터에 의존하는 기능을 비활성화하거나, 필요한 동작을 얻기 위한 대안을 제공하도록 해야 합니다.

> **Important**:
> 위치 데이터는 민감한 정보이므로, 수집한 위치 데이터를 안전하게 보호하는 것이 중요합니다. 디스크에 저장하거나 네트워크를 통해 전송할 때는 반드시 암호화를 해야 합니다. 또한 사용자의 위치 데이터를 어떻게 활용하는지 명확히 설명하는 개인정보 처리 방침을 제공해야 합니다.


## Check the availability of services your app uses

위치 서비스를 사용하기 전에 항상 해당 서비스가 사용 가능한지 확인해야 합니다. 서비스가 사용 불가능할 수 있는 이유는 여러 가지가 있으며, 예를 들면 다음과 같습니다:

* 기기가 비행기 모드에 있는 경우

* 기기에 특정 하드웨어가 없는 경우

* 기기가 특정 서비스를 지원하지 않는 경우

* 앱이 해당 서비스를 사용할 수 있는 권한을 가지고 있지 않은 경우

서비스를 사용할 수 없는 경우, 해당 서비스에 의존하는 앱 고유 기능을 비활성화해야 합니다. 기능을 미리 비활성화하는 방식이 서비스를 직접 사용하다가 오류에 대응하는 것보다 더 안정적인 접근 방식입니다.

[CLLocationManager]() 클래스는 각 서비스의 사용 가능 여부를 확인할 수 있는 메서드를 제공합니다. 특정 서비스를 사용하기 직전에 해당 서비스에 맞는 메서드를 호출해야 합니다. 예를 들어, 나침반 방향 정보를 제공하는 앱은 서비스를 시작하기 전에 [headingAvailable()]() 메서드를 호출할 수 있습니다. 앱에서 여러 서비스를 사용하는 경우, 각 서비스마다 적절한 메서드를 호출해야 합니다.

```swift
// Check if heading data is available.
if CLLocationManager.headingAvailable() {
    locationManager.startUpdatingHeading()
} else {
    // Disable compass features.
}
```

앱이 특정 위치 서비스 없이는 동작할 수 없다면, 앱의 *Info.plist*에 이러한 요구사항을 미리 선언해야 합니다. 자세한 내용은 *Declare the device capabilities your app requires* 섹션을 참고하세요.

## Start receiving location updates and authorization status changes

코드에서 바로 위치 업데이트를 요청할 수 있습니다. 만약 시스템이 아직 앱에 대해 권한 요청을 하지 않았다면, 코드가 비동기 스트림의 반복을 시작할 때 시스템이 권한을 요청합니다. 위치 데이터는 민감한 개인 정보이기 때문에, 기기 소유자가 어떤 앱에 접근 권한을 줄지 제어합니다. 사용자는 앱별로 접근을 허용하거나 거부할 수 있으며, 언제든지 설정 앱에서 앱의 접근 권한을 변경할 수 있습니다.

> **Tip**:
> 앱에서 위치 데이터를 사용하는 시점, 예를 들어 위치 관련 데이터를 표시하는 뷰에서 위치 업데이트 요청을 시작하세요. 앱 실행 시점이나 위치와 관련 없는 부분에서 요청하지 마세요. 꼭 필요한 경우가 아니라면 그렇게 하지 않는 것이 좋습니다. 사용자가 앱이 왜 권한을 요청하는지 이해하지 못할 수 있으며, 그 경우 요청을 거부할 수 있습니다. 

위치 업데이트와 권한 상태 변경은 비동기적으로 처리됩니다. 반복문 안에서 위치 업데이트가 있는지와 권한 상태 변경이 있는지를 모두 확인해야 합니다. 반복문은 명시적으로 *return*, *break* 또는 예외를 발생시켜야만 종료됩니다.

```swift
// Obtain an asynchronous stream of updates.
let stream = CLLocationUpdate.liveUpdates()

// Iterate over the stream and handle incoming updates.
for try await update in stream {
    if update.location != nil {
        // Process the location.
    } else if update.authorizationDenied {
        // Process the authorization denied state change.
    } else {
        // Process other state changes.
    }
}
```

앱이 항상 권한을 필요로 한다면, [CLServiceSession]()이 제공하는 권한 세션(previleged session)을 생성하고 유지해야 합니다. 이 클래스는 *앱 사용 중(While using)* 권한에서 *항상(Always)* 권한으로 업그레이드할 수 있는 단 한 번의 기회를 제공합니다.

## Declare the device capabilities your app requires

Core Location은 Wi-Fi, 셀룰러, GPS 하드웨어를 조합해 위치 업데이트를 생성하며, 나침반 업데이트는 자기계 센서 하드웨어를 사용해 생성합니다. 위치 업데이트의 경우, Core Location은 매번 모든 하드웨어를 사용하는 것이 아닙니다. 개발자가 [CLLocationManager]() 객체에서 원하는 정밀도를 지정하면, Core Location은 그 데이터를 가장 에너지 효율적인 방식으로 전달하기 위해 필요한 하드웨어만 사용합니다. 

앱이 특정 하드웨어 없이는 동작할 수 없다면, *Info.plist*에 [UIRequiredDeviceCapabilities]() 키를 추가해야 합니다. 이 키가 있으면 App Store는 지정된 하드웨어나 기능이 없는 기기에서 앱 설치를 막습니다. 이 키의 값은 문자열 배열이며, 위치 관련 요구사항으로 *location-services*, *gps*, *magnetometer* 문자열 중 하나를 포함해야 합니다.

위치 데이터에 대한 가장 높은 수준의 정밀도가 반드시 필요할 때만 *gps* 키를 포함해야 합니다. 일반적으로 내비게이션 앱만 이런 정밀도를 요구하지만, 다른 앱에서도 필요한 순간 정확한 위치가 보장되도록 하기 위해 사용할 수 있습니다. 앱에서 방위(heading) 정보를 필요로 한다면, *magnetometer* 키를 포함해야 합니다. 

사용자가 위치 데이터 없이도 앱을 사용할 수 있다면 [UIRequiredDeviceCapabilities]() 키를 포함하지 마세요. 예를 들어, 앱이 근처 식당 검색 결과를 필터링하기 위해 위치 데이터를 사용한다면 이 키를 넣지 않아야 합니다. 위치 데이터를 사용할 수 없는 경우에도 필요한 정보를 얻을 다른 방법을 찾거나 해당 데이터 없이 동작할 수 있어야 합니다. 예를 들어 검색 결과를 위치 기준으로 필터링하려는 경우, 사용자에게 우편 번호나 다른 지리 정보를 직접 입력하도록 요청할 수 있습니다.


## Start the location services

초기 확인을 수행하고 앱의 권한 상태를 검증한 뒤, 필요한 위치 서비스를 시작하세요. Core Location은 위치 관련 정보에 접근할 수 있는 여러 가지 방법을 제공합니다. 

* **현재 위치를 가져옵니다.** 이를 통해 내비게이션 안내를 제공하거나, 위치를 기반으로 데이터 셋을 필터링하거나, 사용자의 위치를 친구와 공유하거나, 사용자의 현재 위치를 활용하는 다른 작업을 수행할 수 있습니다. 자세한 내용은 [Getting the current location of a device]()를 참고하세요.

* **기기가 지정한 지리적 영역에 들어오거나 벗어날 때를 감자힙니다.** 관심 장소에 대한 알림을 보내거나, 위치에 민감한 리마인더를 전달하는 등 다양한 기능에 사용할 수 있습니다. 자세한 내용은 [Monitoring the user's proximity to geographic regions]()를 참고하세요.

* **현재 나침반 방위를 확인합니다.** 진행 방향(코스) 기반 내비게이션을 제공하거나 화면에 나침반을 표시할 수 있습니다. 자세한 내용은 [Getting heading and course information]()을 참고하세요.

* **근처의 iBeacon 하드웨어를 감지합니다.** Bluetooth 기기에 대한 사용자의 근접 정도를 판별합ㄴ디ㅏ. 자세한 내용은 [Determining the proximity to an iBeacon]()를 참고하세요.

