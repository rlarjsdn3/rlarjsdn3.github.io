---
date: '2025-10-25T13:40:15+09:00'
draft: false
title: '[번역] Core Location / CLLocationManager / requestAlwaysAuthorization()'
description: "Requests the user’s permission to use location services regardless of whether the app is in use."
tags: ["requestAlwaysAuthorization", "CLLocationManager"]
categories: ["Core Location"]
cover:
    image: images/code.jpg
---

{{< color color="darkgray" text="iOS 8.0+ ⏐ iPadOS+ ⏐ Mac Catalyst 13.1+ ⏐ macOS 10.15+ ⏐ watchOS 2.0+" >}}

```swift
func requestAlwaysAuthorization()
```

---

## Mentioned in

[Creating a location push service extension]()

## Discussion

앱이 위치 정보를 받으려면 이 메서드나 [requestWhenInUseAuthorization()]() 메서드를 반드시 호출해야 합니다. 이 메서드를 호출하려면 앱의 *Info.plist* 파일에 [NSLocationAlwaysUsageDescription]() 키와 [NSLocationWhenInUseUsageDescription]() 키가 모두 있어야 합니다. [requestAlwaysAuthorization()]()은 현재 권한 상태가 다음 중 하나일 때 호출할 수 있습니다.

* 결정되지 않음(Not Determined) - [CLAuthorizationStatus.notDetermined]()

* 앱을 사용하는 동안 허용(When In Use) = [CLAuthorizationStatus.authorizedWhenInUse]()

사용자가 권한 선택을 한 후, 위치 업데이트를 받으려면 [CLLocationManager]() 델리게이트의 [locationManager(_:didUpdateLocations:)]() 메서드를 사용하세요.

Core Location은 [requestAlwaysAuthorization()]() 호출을 제한합니다. 앱에서 이 메서드를 한 번 호출하면 이후 호출은 효과가 없습니다. iPad나 iPhone 앱이 visionOS에서 실행 중일 때 이 메서드를 호출하면, 이 메서드는 대신 앱을 사용하는 동안 허용 권한 요청으로 처리됩니다.


## Request Always Authorization After Getting When In Use

항상 허용 권한을 얻으려면, 앱이 먼저 앱을 사용하는 동안 허용 권한을 요청한 뒤 이어서 항상 허용 권한을 요청해야 합니다. 

앱에서 [requestWhenInUseAuthorization()]()를 호출한 후, 사용자가 앱을 사용하는 동안 허용 권한을 허용하면, 이이서 [requestAlwaysAuthorization()]()를 호출했을 때 곧바로 항상 허용 권한을 요청하는 알림이 표시됩니다. 하지만 사용자가 [requestWhenInUseAuthorization()]() 요청에 한 번 허용(Allow Once)으로 권한을 허용하면, Core Location은 임시 권한이기 때문에 이후 [requestAlwaysAuthorization()]() 호출을 무시합니다.

> **Note**:
> iOS 16 이상에서는 사용자의 위치를 활발히 추적하거나 최근에 Core Location을 활성화한 앱이 제어 센터에 표시됩니다. 배터리 사용과 사용자 프라이버시를 고려하여, 꼭 필요할 때 그리고 사용자가 예상하는 상황에서만 기기의 위치를 모니터링하도록 주의해야 합니다.

## Request Always Authorization Directly

앱의 현재 권한 상태가 [CLAuthorizationStatus.notDetermined]일 때 [requestAlwaysAuthorization()]()을 호출하면, Core Location은 항상 허용 권한을 완전히 활성화하기 전에 두 번의 권한 요청을 묻는 알림을 표시합니다.

첫 번째 알림은 [NSLocationWhenInUseUsageDescrition]()에 지정한 문자열과 함께 즉시 표시됩니다. 이때 사용자에게 표시되는 알림에는 아래와 같은 옵션이 있으며, 선택 결과에 따라 앱이 맏는 권한 수준이 결정됩니다.

| 옵션 | 권한 |
| :-  | :-  |
| 앱을 사용하는 동안 허용(Allow While Using App) | Core Location은 앱에 임시적인 항상 허용 권한(Provisional Always)을 부여합니다. 이때 델리게이트는 [CLAuthorizationStatus.authorizedAlways]() 값을 받습니다. |
| 한 번 허용(Allow Once) | Core Location은 앱에 임시적인 앱을 사용하는 동안 허용 권한(Temporary When In Use)을 부여합니다. 이 권한은 앱을 더 이상 사용하지 않을 때 만료되므로, 다시 [CLAuthorizationStatus.notDetermined]() 상태로 돌아갑니다. |
| 허용 안 함(Dont't Allow) | Core Location은 앱을 거부된 권한(Denied) 상태로 표시하빋나. 이때 델리게이트는 [CLAuthorizationStatus.denied]() 값을 받습니다. |

두 번째 알림은 Core Location이 [CLAuthorizationStatus.authorizedAlways]() 권한이 필요한 이벤트를 앱에 전달하려고 할 때 표시됩니다. 앱이 임시적인 항상 허용 권한 상태에 있는 경우, 시스템은 [NSLocationAlwaysUsageDescription]()에 지정된 문자열과 함께 두 번째 알림을 표시합니다. Core Location은 일반적으로 앱이 실행 중이지 않을 때 이 두 번째 알림을 표시합니다.

앱이 임시적인 항상 허용 권한 상태일 때 두 번째 알림이 나타나고 사용자가 권한 부여를 선택하면, 앱은 영구적인 항상 허용 권한 상태(Permanent Always)를 받습니다. 사용자가 권한을 부여하면, 앱은 위치 이벤트를 받거나 수정된 권한 상태와 함께 델리게이트 메서드 호출을 받게 됩니다. 

두 번째 알림이 표시될 때, 사용자에게 표시되는 알림에는 아래와 같은 옵션이 있습니다.

| 옵션 | 권한 |
| :-  | :-  |
| 사용하는 동안만 유지(Keep Only While Using) | Core Location은 앱을 사용하는 동안 허용(When In Use) 권한으로 변경합니다. 이때 델리게이트는 [CLAuthorizationStatus.authorizedWhenInUse]() 값을 받습니다. |
| 항상 허용으로 변경(Change to Always Allow) | Core Location은 임시 권한 상태를 제거하고 항상 허용 권한을 영구적으로 부여합니다. 이 경우 델리게이트는 콜백을 받지 않습니다. |

사용자가 알림이 표시된 시점과 가까운 시간에 항상 허용 권한을 부여하면, 위치 이벤트가 앱으로 전달됩니다.