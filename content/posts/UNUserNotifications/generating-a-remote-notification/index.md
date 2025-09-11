---
date: '2025-09-30T13:28:01+09:00'
draft: true
title: '[번역] UNUserNotifications / Generating a Remote Notification (애플 공식 문서)'
description: "JSON 페이로드와 함께 사용자의 디바이스로 알림을 보내세요."
tags: ["Remote Notifications", "JSON", "UNNotificationCategory"]
categories: ["UNUserNotifications"]
cover:
    image: images/docs_1.jpg
---

## Overview

푸시 알림은 JSON 페이로드 형태로 사용자에게 중요한 정보를 전달합니다. 페이로드에서 수행하려는 사용자 상호작용의 종류(알림, 사운드, 배지)가 지정되며, 앱이 알림에 응답하는 데 필요한 모든 커스텀 데이터가 포함됩니다.

<< figure src="media-2953613.png" align="center" >>

푸시 알림 페이로드에는 Apple이 정의한 키와 그에 해당하는 커스텀 값이 포함됩니다. 또한 알림에 맞게 직접 정의한 커스텀 키와 값을 추가할 수도 있습니다. Apple 푸시 알림 서버(APNs)는 페이로드의 전체 크기가 다음 제한을 초과하면 알림을 거부합니다.

* VolP(인터넷 전화) 알림의 경우, 최대 페이로드의 크기는 5KB (5120바이트)입니다.

* 그외 모든 푸시 알림의 경우, 최대 페이로드의 크기는 4KB (4096바이트)입니다.


## Create the JSON payload

푸시 알림의 페이로드는 JSON 딕셔너리로 생성합니다. 이 딕셔너리 안에는 *aps* 키를 포함해야 하며, *aps* 키의 값은 아래 표에 나열된 하나 이상의 Apple이 정의한 추가 키들을 담은 딕셔너리입니다. 이 키들을 통해 시스템에 알림을 표시하거나, 사운드를 재생하거나, 앱 아이콘에 배지를 적용하도록 지시할 수 있습니다. 또한 시스템이 알림을 백그라운드에서 조용히 처리하도록 지시할 수 있습니다. 더 자세한 내용은 [Pushing background updates to your App](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app)을 참고하세요.

Apple이 정의한 키 외에도, 페이로드에 커스텀 키를 추가해 소량의 데이터를 앱이나 *Notification Service App Extension*, *Notification Content App Extension*으로 전달할 수 있습니다. 커스텀 키의 값은 딕셔너리, 배열, 문자열, 숫자, 불리언과 같은 기본 타입이어야 합니다. 이렇게 추가한 커스텀 키는 [UNNotificationContent](https://developer.apple.com/documentation/usernotifications/unnotificationcontent) 객체의 [userInfo](https://developer.apple.com/documentation/usernotifications/unnotificationcontent/userinfo) 딕셔너리에서 확인할 수 있습니다.

일반적으로 커스텀 키는 코드에서 알림을 처리하는 데 도움을 줍니다. 예를 들어, 앱 전용 데이터를 조회할 때 사용할 수 있는 식별자를 포함할 수 있습니다. 커스텀 키는 *aps* 딕셔너리와 같은 계층에 추가해야 합니다.

아래는 사용자를 게임에 초대하는 알림 메시지를 표시하도록 하는 알림 페이로드 예시를 보여줍니다. *category* 키가 미리 등록된 [UNUserNotificationCategory](https://developer.apple.com/documentation/usernotifications/unnotificationcategory) 객체를 가리키는 경우, 시스템은 알림에 액션 버튼을 추가합니다. 예를 들어, 여기서는 *category*에 즉시 게임을 시작할 수 있는 play 액션이 포함되어 있습니다. 커스텀 *gameID* 키에는 게임 초대를 가져올 때 사용할 수 있는 식별자가 담겨 있습니다.

```json
{
    "aps" : {
        "alert" : {
            "title" : "Game Request",
            "subtitle" : "Five Card Draw",
            "body" : "Bob wants to play poker"
        },
        "category" : "GAME_INVITATION"
    },
    "gameID" : "12345678"
}
```

아래는 앱 아이콘에 배지를 표시하고 사운드를 재생하는 알림 페이로드 예시를 보여줍니다. 지정한 사운드 파일은 사용자의 기기에 있어야 하며, 앱 번들 또는 *Library/Sounds* 폴더에 위치해야 합니다. *messageID* 키에는 알림을 발생시킨 메시지를 식별하기 위한 앱 전용 정보가 담겨 있습니다.

```json
{
    "aps" : {
        "badge" : 9,
        "sound" : "bingbong.tiff"
    },
    "messageID" : "ABCDEFGHIJ"
}
```

알림에 사용할 사운드를 생성하는 방법에 대한 더 자세한 내용은 [UNNotificationSound](https://developer.apple.com/documentation/usernotifications/unnotificationsound)를 참고하세요.

> **Important**: 
> 알림 페이로드에는 고객 정보나 신용카드 번호와 같은 민감한 데이터를 포함하지 마세요. 불가피하게 고객 정보나 민감한 데이터를 포함해야 한다면, 페이로드에 추가하기 전에 암호화를 해야 합니다. 그리고 사용자 기기에서 *Notification Service App Extension*을 사용해 해당 데이터를 복호화할 수 있습니다. 더 자세한 내용은 [Modifying content in newly delivered notifications](https://developer.apple.com/documentation/usernotifications/modifying-content-in-newly-delivered-notifications)를 참고하세요.


## Localize your alert messages

푸시 알림의 콘텐츠를 현지화하는 방법에는 두 가지가 있습니다:

* 페이로드에 현지화된 문자열을 직접 포함하는 방법

* 앱 번들에 현지화된 문자열을 추가하고, 시스템이 표시할 문자열을 선택하도록 하는 방법

현지화된 문자열을 직접 페이로드에 넣는 방식은 더 많은 유연성을 제공하지만, 제공자 서버(provider server)에서 사용자의 선호 언어를 추적해야 합니다. 문자열을 서버에서 제공하기 때문에 서버는 어떤 언어를 사용할지 알아야 합니다. 사용자의 기기에서 [NSLocale](https://developer.apple.com/documentation/Foundation/NSLocale)의 [preferredLanguages](https://developer.apple.com/documentation/Foundation/NSLocale/preferredLanguages) 속성을 확인하여 사용자의 선호 언어를 가져올 수 있습니다. 그런 다음 앱이 해당 정보를 서버로 전달할 수 있습니다.

알림 메시지의 텍스트가 미리 정해져 있다면, 앱 번들의 *Localizable.strings* 파일에 메시지 문자열을 저장하고 *title-loc-key*, *subtitle-loc-key*, *loc-key* 키를 사용하여 표시할 문자열을 지정할 수 있습니다. 현지화된 문자열에는 플레이스 홀더를 포함할 수 있으며, 이를 통해 최종 문자열에 동적으로 콘텐츠를 삽입할 수 있습니다. 아래는 앱에서 제공한 문자열을 기반으로 생성된 메시지를 포함하는 페이로드 예시를 보여줍니다. *loc-args* 키에는 플레이스 홀더를 대체할 변수들을 담은 배열이 포함됩니다.

```json
{
    "aps" : {
        "alert" : {
            "loc-key" : "GAME_PLAY_REQUEST_FORMAT",
            "loc-args" : [ "Shelly", "Rick" ] 
        }
    }
}
```

현지화된 콘텐츠에 사용하는 키에 대한 더 자세한 내용은 아래 섹션을 참고하세요.


## Payload key reference

아래 표에는 *aps* 딕셔너리에 포함할 수 있는 키들이 나와 있습니다. 사용자와 상호작용하려면 *alert*, *badge*, *sound* 키를 포함해야 합니다. *aps* 딕셔너리에 커스텀 키를 추가하지 마세요. APNs는 커스텀 키를 무시합니다. 대신, *aps* 딕셔너리와 같은 계층에 커스텀 키를 추가해야 합니다. 

| 키 | 타입 | 설명 | 
| - | --- | --- |
| *alert* | Dictionary (or String) | 경고(alert)를 표시하기 위한 정보입니다. 일반적으로는 딕셔너리 형태ㅐ로 전달하는 것을 권장합니다. 문자열을 지정하면, 해당 문자열이 경고의 본문(body)으로 표시됩니다. |
| *badge* | Number | 앱 아이콘의 배지에 표시할 숫자입니다. 현재 배지를 제거하려면 0을 지정하세요. |
| *sound* | String | 앱의 메인 번들 또는 앱 컨테이너 디렉토리의 *Library/Sounds* 폴더에 있는 사운드 파일의 이름입니다. 문자열 "default"를 지정하면 시스템 기본 사운드가 재생됩니다. 이 키는 일반 알림(regular notification)에 사용되며, 중요 알림(critical alerts)의 경우에는 대신 사운드 딕셔너리를 사용해야 합니다. 사운드 준비 방법에 대한 자세한 내용은 [UNNotificationSound](https://developer.apple.com/documentation/usernotifications/unnotificationsound)를 참고하세요. |
| *sound* | Dictionary | 중요 알림을 위한 사운드 정보를 담고 있는 딕셔너리입니다. 일반 알림의 경우에는 대신 사운드 문자열을 사용해야 합니다. |
| *thread-id* | String | 관련 알림들을 그룹화하기 위한 앱 전용 식별자입니다. 이 값은 [UNNotificationContent](https://developer.apple.com/documentation/usernotifications/unnotificationcontent) 객체의 [threadIdentifier](https://developer.apple.com/documentation/usernotifications/unmutablenotificationcontent/threadidentifier) 속성에 해당합니다. |
| *category* | String | 알림의 유형입니다. 이 문자열은 앱 실행 시 등록한 [UNNotificationCateogry](https://developer.apple.com/documentation/usernotifications/unnotificationcategory) 객체 중 하나의 [identifier](https://developer.apple.com/documentation/usernotifications/unnotificationcategory/identifier)와 반드시 일치해야 합니다. 자세한 내용은 [Declaring your actionable notification types]()을 참고하세요. |
| *content-available* | Number | 백그라운드 알림 플래그입니다. 조용한(slient) 백그라운드 업데이트를 수행하려면 이 값을 1로 지정하고, 페이로드에 *alert*, *badge*, *sound* 키를 포함하지 않아야 합니다. 자세한 내용은 [Pushing background updates to your app](https://developer.apple.com/documentation/usernotifications/declaring-your-actionable-notification-types) 문서를 참고하세요. |
| *mutable-content* | Number | 알림 서비스 앱 익스텐션 플래그입니다. 값이 1이면 시스템은 알림을 전달하기 전에 해당 알림을 *Notification Service App Extension*으로 넘깁니다. 익스텐션을 사용하여 알림의 콘텐츠를 수정할 수 있습니다. 자세한 내용은 [Modifying content in newly delivered notifications](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app) 문서를 참고하세요. |
| *target-content-id* | String | 앞으로 가져올 윈도우(window)의 식별자입니다. 이 키의 값은 푸시 페이로드로부터 생성된 [UNNotificationContent](https://developer.apple.com/documentation/usernotifications/unnotificationcontent) 객체에 채워집니다. 해당 값은 [UNNotificationContent](https://developer.apple.com/documentation/usernotifications/unnotificationcontent) 객체의 [targetContentIdentifier](https://developer.apple.com/documentation/usernotifications/unnotificationcontent/targetcontentidentifier) 프로퍼티를 사용해 접근할 수 있습니다. |
| *interruption-level* | String | 알림의 중요도와 전달 시점입니다. 문자열 값인 "passive", "active", "time-sensitive", "critical"은 [UNNotificationInterruptionLevel](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel) 열거형의 각 케이스에 대응합니다. |
| *relevance-score* | Number | 관련성 점수(relevance score)로, 0과 1 사이의 숫자이며, 시스템이 앱의 알림을 정렬할 때 사용합니다. 가장 높은 점수를 가진 알림이 알림 요약에 강조 표시됩니다. [relevanceScore](https://developer.apple.com/documentation/usernotifications/unnotificationcontent/relevancescore)를 참고하세요. 푸시 알림이 라이브 액티비티를 업데이트 하는 경우, 25, 50, 75, 100과 같이 임의의 Double 값을 설정할 수 있습니다. |
| *filter-criteria* | String | 시슻템이 현재 켜져 있는 집중 모드에서 알림을 표시할지 여부를 판단하기 위해 평가하는 기준입니다. 자세한 내용은 [SetFocusFilterIntent]https://developer.apple.com/documentation/AppIntents/SetFocusFilterIntent()를 참고하세요. |
| *stale-date* | Number | 라이브 액티비티가 오래되거나 더 이상 유효하지 않게 되는 날짜를 나타내는 UNIX 타임스탬프입니다. 자세한 내용은 [Displaying live data with Live Activities](https://developer.apple.com/documentation/ActivityKit/displaying-live-data-with-live-activities)를 참고하세요. |
| *content-state* | Dictionary | 라이브 액티비티의 업데이트되거나 최종적인 콘텐츠입니다. 이 딕셔너리의 내용은 사용자가 구현한 커스텀 [ActivityAttributes](https://developer.apple.com/documentation/ActivityKit/ActivityAttributes)에 정의한 데이터와 일치해야 합니다. 자세한 내용은 *Updating and ending your Live Activity with ActivityKit push notifications*를 참고하세요. |
| *timestamp* | Dictionary (or String) | 라이브 액티비티를 종료하거나 업데이트하는 푸시 알림을 보낸 시점을 나타내는 UNIX 타임스탬프입니다. 자세한 내용은 *Updating and ending your Live Activity with ActivityKit push notifications*를 참고하세요.  
| *event* | String | 푸시 알림으로 라이브 액티비티를 시작할지, 업데이트할지, 종료할지를 나타내는 문자열입니다. 라이브 액티비티를 시작하려면 *start*를, 업데이트하려면 *update*를, 종료하려면 *end*를 사용하세요. 자세한 내용은 *Updating and ending your Live Activity with ActivityKit push notifications*를 참고하세요.    |
| *dismissal-date* | Number | 시스템이 라이브 액티비티를 잠금 화면에서 제거하고 다이내믹 아일랜드를 제거하는 날짜를 나타내는 UNIX 타임스탬프입니다. 자세한 내용은 *Updating and ending your Live Activity with ActivityKit push notifications*를 참고하세요.  |
| *attributes-type* | String | 푸시 알림으로 라이브 액티비티를 시작할 때 사용하는 문자열입니다. 이 문자열은 라이브 액티비티에 표시되는 동적 데이터를 설명하는 구조체의 이름과 일치해야 합니다. 자세한 내용은 *Updating and ending your Live Activity with ActivityKit push notifications*를 참고하세요.  |
| *attributes* | Dictionary | 푸시 알림으로 시작한 라이브 액티비티에 전달하는 데이터를 담고 있는 딕셔너리입니다. 자세한 내용은 *Updating and ending your Live Activity with ActivityKit push notifications*를 참고하세요. |


아래 표는 *alert* 딕셔너리에 포함할 수 있는 키들이 나와 있습니다. 이 문자열들을 사용해 알림 배너에 포함할 제목과 메시지를 지정할 수 있습니다.

| 키 | 타입 | 설명 | 
| - | --- | --- |
| *title* | String | 알림의 제목입니다. Apple Watch에서는 이 문자열을 짧은 보기 알림 인터페이스에 표시합니다. 사용자가 빠르게 이해할 수 있는 문자열로 지정하세요. |
| *subtitle* | String | 알림의 목적을 설명하는 추가 정보입니다. |
| *body* | String | 알림 메시지의 콘텐츠입니다. |
| *launch-image* | String | 표시할 런치 이미지 파일의 이름입니다. 사용자가 앱을 실행하기로 선택하면, 지정한 이미지나 스토리보드 파일의 내용이 앱의 기본 런치 이미지 대신 표시됩니다. |
| *title-loc-key* | String | 현지화된 제목 문자열을 위한 키입니다. 제목을 앱의 *Localizable.strings* 파일에서 가져오려면 *title* 키 대신 이 키를 지정하세요. 값에는 문자열 파일에 있는 키의 이름이 들어가야 합니다. |
| *title-loc-args* | Array of strings | 제목 문자열에 있는 변수들을 치환할 값이 들어 있는 문자열 배열입니다. *title-loc-key*로 지정된 문자열에 포함된 *%@* 문자는 이 배열의 값으로 대체됩니다. 배열의 첫 번째 항목은 문자열의 첫 번째 *%@*을, 두 번째 항목은 두 번째 *%@*를, 이런 식으로 차례대로 대체됩니다. |
| *subtitle-loc-key* | String | 현지화된 부제목 문자열을 위한 키입니다. 부제목을 앱의 *Localizable.strings* 파일에서 가져오려면 *subtitle* 키 대신 이 키를 사용하세요. 값에는 문자열 파일에 있는 키의 이름이 들어가야 합니다. |
| *subtitle-loc-args* | Array of strings | 부제목 문자열에 있는 변수들을 치환할 값이 들어 있는 문자열 배열입니다. *subtitle-loc-key*로 지정된 문자열에 포함된 *%@* 문자는 이 배열의 값으로 대체됩니다. 배열의 첫 번째 항목은 문자열의 첫 번째 *%@*을, 두 번째 항목은 두 번째 *%@*를, 이런 식으로 차례대로 대체됩니다. |
| *loc-key* | String | 현지화된 메시지 문자열을 위한 키입니다. 메시지를 앱의 *Localizable.strings* 파일에서 가져오려면 *body* 키 대신 이 키를 사용하세요. 값에는 문자열 파일에 있는 키의 이름이 들어가야 합니다. |
| *loc-args* | Array of strings | 메시지 문자열에 있는 변수들을 치환할 값이 들어 있는 문자열 배열입니다. *loc-key*로 지정된 문자열에 포함된 *%@* 문자는 이 배열의 값으로 대체됩니다. 배열의 첫 번째 항목은 문자열의 첫 번째 *%@*을, 두 번째 항목은 두 번째 *%@*를, 이런 식으로 차례대로 대체됩니다. |

아래 표는 *sound* 딕셔너리에 포함할 수 있는 키들이 나와 있습니다. 이 키들을 사용해 긴급한 알림에 재생할 사운드를 설정할 수 있습니다.

| 키 | 타입 | 설명 | 
| - | --- | --- |
| *critical* | Number | 중요 알림 플래그입니다. 값을 1로 설정하면 중요 알림이 활성화됩니다. |
| *name* | String | 앱의 메인 번들 또는 앱 컨테이너 디렉토리의 *Library/Sounds* 폴더에 있는 사운드 파일의 이름입니다. 시스템 사운드를 재생하려면 문자열 "default"를 지정하십시오. 사운드를 준비하는 방법에 대한 자세한 내용은 [UNNotificationSound](https://developer.apple.com/documentation/usernotifications/unnotificationsound)를 참조하세요. |
| *volume* | Number | 중요 알림 사운드의 볼륨입니다. 이 갑을 0(무음)에서 1(최대 음량) 사이로 설정하세요. |

아래 그림은 배너 알림에서 제목, 부제목, 본문 콘텐츠가 기본적으로 배치되는 위치를 보여줍니다. 알림의 모양을 사용자화하려면, [Customizing the Appearance of Notifications](https://developer.apple.com/documentation/UserNotificationsUI/customizing-the-appearance-of-notifications)에 설명된 대로 *Notification Content App Extension*를 사용하면 됩니다.

{{< figure src="media-2953614.png" width="250px" align="center" >}}