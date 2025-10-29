---
date: '2025-11-15T14:52:36+09:00'
draft: false
title: '[번역] Core Location / Getting the current location of a device (애플 공식 문서)'
description: "위치 서비스를 시작하고, 시스템이 해당 서비스의 전력 사용을 최적화하는 데 필요한 정보를 제공하세요."
tags: ["CLLocationManager"]
categories: ["Core Location"]
cover:
    image: images/docs_1.jpg
---

## Overview

Core Location은 위치 관련 데이터를 가져오기 위해 여러 가지 서비스를 제공하지만, 가장 일반적인 서비스는 기기의 현재 위치를 반환합니다. 이 정보는 아래와 같은 용도로 사용할 수 있습니다.

* 도보, 자동차 또는 기타 교통수단을 통한 네비게이션을 지원합니다.

* 주변의 관심 지점(POI)를 식별합니다.

* 사람과 가까운 거리를 기준으로 검색 결과를 필터링합니다.

* 사람의 위치를 지도에 표시합니다.

* 사람의 위치를 친구와 공유합니다.

* 사진의 위치를 태그합니다.

* 소셜 미디어에 체크인합니다.

* 운동이나 하이킹 중 이동 경로를 추적합니다.

Core Location은 Wi-Fi, 셀룰러, GPS 라디오 등 다양한 하드웨어를 사용하여 현재 위치를 결정할 수 있습니다. Core Location은 위치를 알아내기 위해 모든 라디오를 사용할 필요는 없습니다. 대신, 필요한 위치 데이터를 가장 전력-효율적인 방식으로 얻기 위해 선택적으로 라디오를 활성화합니다. [CLLocationManager](https://developer.apple.com/documentation/corelocation/cllocationmanager) 객체의 설정은 시스템이 어떤 라디오를 사용할지와 앱의 전력 소모에 영향을 줍니다.

## Start the service that delivers the location data you need

항상 앱의 요구사항을 충족하면서도 가장 전력-효율적인 위치 서비스를 선택해야 합ㄴ디ㅏ. Core Location은 위치 데이터를 얻기 위해 아래와 같은 서비스를 제공합니다.

* **Visits** 위치 서비스는 위치 데이터를 얻는 가장 전력-효율적인 방법을 제공합니다. 시스템은 사용자가 방문한 장소와 그곳에서 머문 시간을 모니터링하고, 해당 데이터를 나중에 전달합니다. 서비스를 시작하려면 [startMonitoringVisits()](https://developer.apple.com/documentation/corelocation/cllocationmanager/startmonitoringvisits())를 호출하세요.

* **Significant Change** 위치 서비스는 저-전력으로 위치 업데이트를 받을 수 있는 방법을 제공합니다. 이 서비스는 GPS가 아닌 셀룰러와 Wi-Fi 라디오를 사용하여 상당히 큰 거리를 이동하는 위치 변화만 알려줍니다. 서비스를 시작하려면 [startMonitoringSignificantLocationChanges()](https://developer.apple.com/documentation/corelocation/cllocationmanager/startmonitoringsignificantlocationchanges())를 호출하세요.

* **Standard** 위치 서비스는 가장 정밀하고 규칙적인 위치 데이터를 제공하지만, 다른 서비스보다 더 많은 전력을 사용합니다. 이 서비스는 주로 턴바이턴 내비게이션을 제공하거나 더 높은 정밀도나 빈도의 이벤트가 필요한 경우에 사용해야 합니다. 또한 이 위치 서비스는 visionOS에서 실행되는 앱에서 사용할 수 있는 유일한 서비스입니다. 서비스를 시작하려면 [startUpdatingLocation()](https://developer.apple.com/documentation/corelocation/cllocationmanager/startupdatinglocation())을 호출하거나, 위치 데이터를 한 번만 얻으려면 [requestLocation()](https://developer.apple.com/documentation/corelocation/cllocationmanager/requestlocation())을 호출하세요.

즉시 위치 서비스를 시작해야 하는 앱은 거의 없으며, 장시간 위치 서비스를 계속 실행해야 하는 앱은 더더욱 드뭅니다. 사용자가 앱과 상호작용하여 위치 정보가 필요해지는 시점까지 위치 서비스 시작을 미루세요. 그런 다음 필요한 위치 서비스를 얻는 즉시 서비스를 중지하여 배터리 수명을 보존하세요. 예를 들어, 현재 위치가 단 한 번 검색 결과를 필터링하는 데 필요하다면 서비스를 중지해야 합니다.

위치 서비스에 대한 지원을 추가할 때는 해당 서비스와 관련된 모든 메서드를 반드시 델리게이트 객체에 구현해야 합니다. Standard와 Significant-Change 위치 서비스는 동일한 델리게이트 메서드를 사용하지만, Visits 서비스는 방문 데이터를 받는 별도 메서드를 따로 가지고 있습니다. 

각 서비스의 동작 방식과 시작 및 중지 방법에 대한 정보는 [CLLocationManager](https://developer.apple.com/documentation/corelocation/cllocationmanager)를 참고하세요.


## Enable power-saving features

Core Location은 전력 사용을 최대한 최적화하지만, 여전히 개발자가 도울 수 있는 부분이 있습니다. 가장 좋은 최적화 방법은 앱에서 새로운 위치 데이터가 필요하지 않을 때 위치 서비스를 끄는 것입니다. 그 외의 최적화는 *location manager* 객체의 설정을 조정해야 합니다.

* [distanceFilter]() 속성을 필요로 하는 정보를 얻을 수 있는 범위에서 가장 큰 값으로 설정하세요. 값이 클수록 시스템은 라디오 하드웨어를 더 자주 끌 수 있습니다.

* [desiredAccuracy]() 속성을 필요로 하는 정보를 얻을 수 있는 범위에서 가장 작은 값으로 설정하세요. 정확도 값이 낮을수록 시스템이 더 전력-효율적으로 하드웨어를 사용할 수 있습니다. 또한 값이 낮을수록 하드웨어를 더 빨리 끌 수 있습니다.

* [activityType]() 속성을 적절한 값으로 설정하고, [pausesLocationUpdatesAutomatically]() 속성을 [true]()로 설정하세요. Core Location은 지정한 *activity type*을 사용하여 상황이 허락될 때 하드웨어를 자동으로 끕니다. 예를 들어, *activity type*이 [CLActivityType.automotiveNavigation]()이고 사용자의 위치가 변하지 않는다면, 시스템은 새로운 움직임이 감지될 때까지 라디오 하드웨어를 끌 수 있습니다.

* 백그라운드 위치 업데이트가 필요하지 않을 때는 [allowsBackgroundLocationUpdates]() 속성을 [false]()로 설정하세요.

전력 사용을 개선하는 또 다른 방법은 앱의 *Info.plist* 파일에 *NSLocationDefaultAccuracyReduced* 키를 *true* 값으로 추가하는 것입니다. 낮은 정확도의 위치 데이터만으로 충분하다면 이 키를 포함하세요. 예를 들어, 자동차로 이동 가능한 거리 내의 음식점 목록을 제공하는 앱은 사용자의 정확한 위치를 필요로 하지 않습니다. 필요할 경우 *location manager*를 사용하여 더 정확한 데이터를 요청할 수 있습니다. 다만, 시스템은 사용자가 요청할 때마다 사용자에게 권한 요청 알림을 표시합니다.
