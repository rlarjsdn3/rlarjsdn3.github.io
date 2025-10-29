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

지오펜싱은 사용자가 지리적 영역에 들어오거나 벗어날 때 앱이 알림을 받을 수 있는 방법입니다. 

{{< figure src="media-2904074.png" width="450px" align="center" >}}



## Define and monitor a geographic condition

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
> 

## Respond to events