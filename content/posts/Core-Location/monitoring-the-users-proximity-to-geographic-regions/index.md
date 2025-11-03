---
date: '2025-11-20T15:17:01+09:00'
draft: false
title: "[번역] Core Location / Monitoring the user's proximity to geographic regions (애플 공식 문서)"
description: "사용자가 지리적 영역에 들어오거나 벗어나는 시점을 판단하려면 모니터링을 사용하세요."
tags: ["CLLocationManager", "CLMonitor", "AsyncSequence"]
categories: ["Core Location"]
cover:
    image: images/docs_1.jpg
---

## Overview

지오펜싱은 사용자가 지리적 영역에 들어오거나 벗어날 때 앱이 알림을 받을 수 있는 방법입니다. 위치 관련 작업을 수행하기 위해 영역 모니터링(region monitoring)을 사용할 수 있습니다. 예를 들어, 아래 그림에 표시된 것처럼 미리 알림 앱은 사용자가 특정 위치에 도착하거나 떠날 때 미리 알림을 트리거하는 데 이를 사용합니다.

{{< figure src="media-2904074.png" width="450px" align="center" >}}

iOS에서는 시스템이 영역을 모니터링하고, 조건이 충족됨(satisfied)와 충족되지 않음(unsatisifed) 상태 사이에서 변경될 때 필요에 따라 앱을 깨워줍니다. macOS에서는 조건 모니터링이 앱이 실행 중일 때(포그라운드 또는 백그라운드 상태 모두) 그리고 사용자의 시스템이 깨어 있는 동안에만 작동합니다. 시스템은 영역 관련 알림을 전달하기 위해 Mac 앱을 자동으로 실행하지 않습니다.


## Define and monitor a geographic condition

[CLCircularGeographicCondition]()을 사용하여 특정 지리적 좌표를 중심으로 한 원형 영역을 정의합니다. 이 조건의 반지름(radius)은 영역의 경계를 결정합니다. 모니터링하려는 조건을 정의한 후, [CLLocationManager]() 객체의 [startMonitoring(for:)]() 메서드를 호출하여 시스템에 등록합니다. 시스템은 사용자가 명시적으로 중지 요청을 하거나 기기가 재부팅될 때까지 해당 조건을 계속 모니터링합니다.

아래 예제는 제공한 지점을 중심으로 조건을 구성하고 등록하는 방법을 보여줍니다. 이 작업은 반경 200미터를 사용하여 조건의 경계를 정의한 다음, Core Location으로부터 비동기적으로 전달되는 [AsyncSequence]() 이벤트를 받습니다.

```swift
Task {
    // Create a custom monitor.
    let monitor = await CLMonitor("my_custom_monitor")
    // Register the condition for 200 meters.
    let center1 = myFirstLocation;
    let condition = CLCircularGeographicCondition(center: center1, radius: 200)
    // Add the condition to the monitor.
    monitor.add(condition, identifier: "stay_within_200_meters")
    // Start monitoring.
    for try await event in monitor.events {
        // Respond to events.
        if event.state == .satisfied {
            // Process the 200 meter condition.
        }
    }
}
```

> **Tip**:
> 조건(condition)은 특정 하드웨어 기능에 의존하는 공유 자원입니다. 모든 앱이 조건 모니터링을 할 수 있도록 하기 위해, Core Location은 단일 앱이 동시에 모니터링할 수 있는 조건의 총 개수를 어떤 종류이든 최대 20개로 제한합니다. 따라서 이 제약을 고려하여 어떤 조건을 우선적으로 모니터링할지 결정해야 합니다.

iOS 앱이 실행 중이 아닐 때 조건이 충족되면, 시스템은 해당 앱을 실행하려고 시도합니다. 앱이 다시 실행되면, 동일한 식별자를 사용하여 모니터를 재생성해야 합니다. 단, 기기가 재부팅된 후에는 사용자가 기기의 잠금을 해제한 이후에만 모니터링이 수행될 수 있다는 점에 유의해야 합니다.


## Respond to events

앱의 조건이 변경될 때마다 Core Location은 모니터의 [AsyncSequence]()를 통해 이벤트를 전달합니다.

iOS 앱이 실행 중이 아닐 때 조건이 충족되면, 시스템은 해당 앱을 실행하려고 시도합니다. 앱이 다시 실행되면 동일한 식별자를 사용하여 모니터를 재생성하는 것은 개발자의 책임입니다. 기기가 재부팅된 후에는 사용자가 기기의 잠금을 해제한 이후에만 모니터링이 수행될 수 있습니다.

조건이 변경되는 시점을 올바르게 파악하기 위해서는 이벤트 반복(iteration)을 지속적으로 수행하는 것이 중요합니다.