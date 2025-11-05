---
date: '2025-12-10T21:27:48+09:00'
draft: false
title: '[번역] Core Location / Suspending Authorization Requests (애플 공식 문서)'
description: "앱이 준비될 때까지 시스템의 권한 요청 알림창 표시를 미룹니다."
tags: ["CLServiceSession"]
categories: ["Core Location"]
cover:
    image: images/swift.jpg
    caption: ""
---

## Overview

앱의 온보딩 과정에 위치 정보 업데이트를 포함하고 있다면, 사용자에게 Core Location 권한을 요청하는 시점을 미루고 싶을 수 있습니다. 앱에서 [CLServiceSession]()을 적절한 시점에 생성함으로써 자동으로 표시되는 권한 요청 알림창을 억제할 수 있습니다. 그럼 다음 _diagnostic_ 프로퍼티를 순회하여 사용자가 선택한 권한 수준을 확인할 수 있습니다. 아래 예제는 권한 요청을 미루는 방법을 보여줍니다.

```swift
func doPromptingFlow() async {
    await showHelloPrompt()

    // Obtain a session. This causes Core Location to display the authorization prompt.
    let session = CLServiceSession(authorization: .whenInUse)

    // Wait for interaction with the prompt to complete (successfully or with denial)
    for try await diagnostic in session.diagnostics {
        if !diagnostic.authorizationRequestInProgress {
            // A denial occurred.
            break
        }
    }

    await doFurtherWork()
}
```

이 동작을 제어하려면 앱의 Info.plist 파일에 _CLRequireExplicitServiceSession_ 속성을 추가하세요.