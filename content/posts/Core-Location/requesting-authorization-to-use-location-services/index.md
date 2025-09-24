---
date: '2025-10-20T22:52:40+09:00'
draft: false
title: '[번역] Core Location / Requesting Authorization to Use Location Services (애플 공식 문서)'
description: "위치 서비스를 사용하기 위한 권한을 얻고, 앱의 권한 상태가 변경될 때 이를 관리하세요."
tags: ["CLLocationManager", "CLAuthorizationStatus"]
categories: ["Core Location"]
cover:
    image: images/docs_1.jpg
---

## Overview

위치 데이터는 민감한 정보이며, 이를 사용하는 것은 앱 사용자에게 개인정보 보호와 관련된 영향을 끼칩니다. 사람들이 자신의 정보를 스스로 통제할 수 있도록, 시스템은 앱이 권한을 얻기 전까지 위치 데이터를 사용할 수 없도록 합니다. 이 권한 부여 과정에서 한 번의 인터럽션이 발생하며, 이때 시스템은 사용자에게 앱의 위치 데이터 사용 요청을 허용할지 거부할지 묻습니다. 초기 요청 이후에는 시스템이 앱의 권한 상태를 저장하고, 다시는 사용자에게 요청을 표시하지 않습니다.

사용자가 왜 위치 데이터가 필요한지 이해할 수 있도록, 권한 요청은 반드시 앱에서 해당 데이터가 필요한 기능을 사용할 때만 하세요. 필요한 순간 직전에 요청하면 사용자가 권한을 허용할 가능성이 높아집니다. 반대로 앱이 실행되자마자 요청하거나 위치 데이터를 명확히 사용하지 않는 부분에서 요청하면, 사용자가 의도를 오해하고 권한 요청을 거부할 수 있습니다.


## Choose the access level you need

권한 요청을 하기 전에, 앱에서 필요한 접근 수준을 먼저 선택하세요. Core Location은 두 가지 권한 수준을 지원합니다.

* **앱을 사용하는 동안 허용(When in use)** 권한은 사용자가 앱을 사용할 때만 위치 업데이트를 제공할 수 있습니다. 이 권한은 개인정보 보호와 배터리 사용 측면에서 더 유리하기 때문에 권장되는 선택입니다.

* **항상 허용(Always)** 권한은 언제든지 위치 업데이트를 받을 수 있으며, 시스템이 일부 업데이트를 처리하기 위해 앱을 조용히 실행할 수도 있습니다. 이 접근 수준은 iOS·iPadOS에서 꼭 필요할 때만 요청해야 합니다. 예를 들어, 앱이 위치 변화에 대해 자동으로 시간에 민감한 응답을 제공하거나, *Location Push Servcie App Extension*을 구현하는 경우가 이에 해당합니다. 이 접근 수준은 visionOS에서는 사용할 수 없습니다.

앱이 사용 중(when in use)인지에 대한 정의는 플랫폼에 따라 다릅니다.

* iOS에서 앱이 사용 중이라는 것은 앱이 포그라운드에 있거나, 포그라운드에서 백그라운드로 전환될 때 잠시 동안을 의미합니다. 백그라운드 위치 업데이트를 활성화하면, 앱을 사용하는 동안 허용 권한을 가진 앱은 위치 서비스가 실행 중일 때 백그라운드에서도 계속 동작할 수 있습니다. 그러나 위치 서비스가 실행되지 않은 경우에는 일반적인 앱 일시 중단 규칙이 적용됩니다. 시스템이 앱을 종료했거나 앱이 실행 중이지 않다면, 앱을 사용하는 동안 허용 권한을 가진 앱은 새로운 위치 업데이트가 전달될 때 앱이 실행되지 않습니다. 반대로, 항상 허용 권한을 가진 앱은 일부 위치 업데이트에 대해서 시스템이 실행시켜 줄 수 있습니다. 

* macOS에서는 앱을 사용하는 동안 허용 권한과 항상 허용 권한이 기능적으로 동일합니다. macOS 앱은 최초 실행 이후에도 백그라운드에서 계속 실행되므로, 항상 사용 중인 상태로 간주됩니다. 만약 Mac Catalyst를 사용해 Mac 앱을 만든다면, iOS 앱의 필요에 따라 권한을 요청해야 합니다.

* watchOS에서는 컴플리케이션이 위치 업데이트를 받을 수 있지만, 위치 데이터에 접근 권한을 요청하기 위해서는 watchOS 앱이 최소한 한 번은 실행되어야 합니다. 앱의 컴플리케이션이 워치 페이스에 있다면, 시스템은 해당 컴플리케이션을 사용 중인 것으로 간주하고 위치 업데이트를 전달합니다. 그러나 시스템은 앱이 항상 허용 권한을 가지고 있더라도 watchOS 앱을 실행하지는 않습니다.

* visionOS에서 앱이 사용 중이라는 것은 사용자가 해당 앱을 바라보고 있을 때, 그리고 사용자가 앱을 보는 것을 멈춘 직후의 짧은 시간 동안을 의미합니다.

> **Note**:
> 앱이 이미 앱을 사용하는 동안 허용 권한을 가지고 있다면, 나중에 별도로 항상 허용 권한을 요청할 수 있습니다. 그러나 이 요청은 단 한 번만 할 수 있습니다.

어떤 접근 수준을 선택하든, 현재 기기에서 사용 가능한 모든 위치 서비스를 시작할 수 있으며 동일한 결과를 얻을 수 있습니다. 접근 수준은 주로 앱이 실행되지 않을 때 업데이트를 어떻게 받는지를 결정합니다. 아래 표는 접근 수준의 차이를 요약한 것입니다.

| 기능 | 앱을 사용하는 동안 허용(When in use) | 항상 허용(Always) |
| 지원 플랫폼 | 모든 플랫폼 | tvOS와 visionOS를 제외한 모든 플랫폼 |
| 지원 위치 서비스 | 모든 위치 서비스 | 모든 위치 서비스 |
| 종료된 앱 실행 여부 | 아니요. 사용자가 직접 앱을 실행해야 합니다. | 예. 중요한 위치 변화, 방문, 지오펜싱 서비스의 경우에는 자동으로 실행되며, 그 외에는 실행되지 않습니다. | 

백그라운드에서 위치 업데이트를 처리하는 방법에 대한 자세한 내용은 [Handling location updates in the background](https://developer.apple.com/documentation/corelocation/handling-location-updates-in-the-background)를 참고하세요.

## Provide descriptions of how you use location services

처음으로 권한 요청을 하면, 시스템은 사용자가 요청을 허용할지 거부할지 묻는 알림을 표시합니다. 이 알림에는 위치 데이터 접근을 요청하는 이유를 설명하는 문자열이 포함됩니다. 이 문자열은 *Info.plist*에서 설정할 수 있으며, 이를 통해 앱이 위치 데이터를 어떻게 사용하는지 사용자에게 알립니다.

Core Location은 접근 수준별로 서로 다른 문자열을 표시하도록 지원합니다. 앱을 사용하는 동안 허용 접근을 받기 위해서는 반드시 사용 목적을 설명하는 문자열을 포함해야 합니다. 앱이 항상 허용 접근을 지원한다면, 더 높은 권한이 필요한 이유를 설명하는 문자열을 제공해야 합니다. 아래 표는 *Info.plist*에 포함해야 하는 키와 포함 시점을 정리한 것입니다.

| Usage Key | Required when: |
| [NSLocationWhenInUseUsageDescription](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSLocationWhenInUseUsageDescription) | 앱이 앱을 사용하는 동안 허용 또는 항상 허용 권한을 요청할 때 |
| [NSLocationAlwaysAndWhenInUseUsageDescription](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSLocationAlwaysAndWhenInUseUsageDescription) | 앱이 항상 허용 권한을 요청할 때 |
| [NSLocationUsageDescription](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSLocationUsageDescription) | (macOS 전용) macOS 앱이 위치 서비스를 사용할 때 |

권한 요청을 하기 전에 모든 키를 앱의 *Info.plist*에 추가해야 합니다. 필요한 키가 존재하지 않으면 권한 요청은 즉시 실패합니다.


## Make authorization requests and respond to status changes

위치 서비스를 시작하기 전에, 앱의 현재 권한 상태를 확인하고 필요하다면 권한 요청을 해야 합니다. 앱의 현재 권한 상태는 [CLLocationManger](https://developer.apple.com/documentation/corelocation/cllocationmanager) 객체의 [authorizationStatus](https://developer.apple.com/documentation/corelocation/cllocationmanager/authorizationstatus-swift.property) 속성에서 가져올 수 있습니다. 새로 구성한 [CLLocationManager](https://developer.apple.com/documentation/corelocation/cllocationmanager) 객체는 앱의 현재 권한 상태를 자동으로 델리게이트의 [locationManagerDidChangeAuthorization(_:)](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/locationmanagerdidchangeauthorization(_:)) 메서드를 호출해 알려줍니다. 이 메서드를 사용하여 현재 상태가 [CLAuthorizationStatus.notDetermined](https://developer.apple.com/documentation/corelocation/clauthorizationstatus/notdetermined)일 때 권한 요청을 수행할 수 있습니다. 아래 예제에서는 권한 상태가 결정되면 위치 기능을 활성화하거나 비활성화하고, 상태가 결정되지 않았다면 권한 요청을 하는 방법을 보여줍니다.

```swift
func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedWhenInUse:  // Location services are available.
        enableLocationFeatures()
        break
    
    case .restricted, .denied:  // Location services currently unavailable.
        disableLocationFeatures()
        break

    case .notDetermined:  // Authorization not determined yet.
        manager.requestWhenInUseAuthorization()
        break
    
    default:
        break
    }
}
```

[locationManagerDidChangeAuthorization(_:)](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/locationmanagerdidchangeauthorization(_:)) 메서드는 권한과 관련된 모든 변화를 처리할 수 있는 중심 지점입니다. 사용자는 설정 앱에서 언제든지 앱의 권한 상태를 변경할 수 있습니다. 이때 앱이 실행 중이라면, 앱의 모든 [CLLocationManager](https://developer.apple.com/documentation/corelocation/cllocationmanager) 객체가 해당 델리게이트 메서드에 이를 알립니다. 또한 *location manager*는 다른 시점에도 앱의 현재 권한 상태를 보고합니다. 예를 들어, 일시 중단된 iOS 앱이 다시 실행될 때도 이 메서드를 호출합니다.