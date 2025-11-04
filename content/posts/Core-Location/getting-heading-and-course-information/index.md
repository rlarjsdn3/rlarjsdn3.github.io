---
date: '2025-11-25T22:29:29+09:00'
draft: false
title: '[번역] Core Location / Getting Heading and Course Information (애플 공식 문서)'
description: "기기의 방향(orientation)과 진행 방향(course) 정보를 사용하여 내비게이션 기능을 구현합니다."
tags: ["CLLocationManager", "CLLocation"]
categories: ["Core Location"]
cover:
    image: images/docs_1.jpg
    caption: ""
---

## Overview

내베게이션 앱은 사용자가 목적지로 이동하도록 안내하기 위해 보통 방향(heading)과 진행 방향(course) 정보를 사용합니다. 사용자의 기기 방향은 자기 북극(magnetic) 또는 진북을 기준으로 한 현재 기기의 방향을 나타냅니다. GPS가 탑재된 기기는 이동 중인 방향을 나타내는 진행 방향 정보를 제공합니다. iOS의 나침반 앱은 아래 그림과 같이 이 방향 정보를 이용해 자기 나침반 인터페이스를 구현합니다. 증강 현실(AR) 앱은 이 정보를 사용하여 사용자가 어느 방향으로 향하고 있는지를 판단할 수도 있습니다.

{{< figure src="media-2904075.png" width="350px" align="center" >}}


## Get the current heading

방향(heading) 정보는 사용자의 기기가 현재 어떤 방향을 향하고 있는지를 판단하는 데 사용됩니다. 예를 들어, 증강 현실 앱은 현재 방향 정보를 활용하여 사용자의 화면에 어떤 정보를 표시할 지 결정할 수 있습니다. 방향 정보는 일반적으로 기기의 윗부분을 기준으로 판단하지만, [CLLocationManager]() 객체의 [headingOrientation]() 속성을 사용하여 값이 판단되는 기준을 설정할 수도 있습니다.

방향 정보를 사용할 수 있는지 먼저 확인한 뒤, [CLLocationManager]() 객체의 [startUpdatingHeading()]() 메서드를 호출하여 방향 정보 전달을 시작합니다. 방향 정보가 변경될 때마다 위치 매니저는 자신의 [locationManager(_:didUpdateHeading:)]() 델리게이트 메서드에 새로운 방향 정보를 전달합니다. 

> **Note:**
> 방향 정보는 자력계(magnetometer)가 있는 기기에서만 사용할 수 있으며, iOS 시뮬레이터에서는 사용할 수 없습니다. 자력계는 기기의 방향을 자기 북극을 기준으로 판단합니다. 위치 데이터가 사용 가능한 경우, _Core Location_&#8203;은 기기의 방향을 진북을 기준으로도 함께 전달합니다.


## Get course information

진행 방향(course) 정보는 기기가 이동하는 속도와 방향을 나타내며, GPS 하드웨어가 있는 기기에서만 사용할 수 있습니다. 진행 방향(course) 정보와 기기 방향(heading) 정보를 혼동하지 않도록 주의해야 합니다. 진행 방향은 기기의 실제 물리적 방향과는 관계없이, 기기가 이동하고 있는 방향을 나타냅니다. 이 정보는 내비게이션 앱에서 가장 흔하게 사용됩니다.

진행 방향 정보는 위치 업데이트의 일부로 앱에 전달되는 [CLLocation]() 객체에 자동으로 포함됩니다. 위치 매니저는 충분한 위치 데이터를 수집하여 진행 방향을 계산할 수 있게 되면, 해당 [CLLocation]() 객체의 [speed]()와 [course]() 속성에 적절한 값을 채워 넣습니다.