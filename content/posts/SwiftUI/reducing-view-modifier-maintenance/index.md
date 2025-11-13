---
date: '2025-12-30T09:05:27+09:00'
draft: false
title: '[번역] SwiftUI / Reducing View Modifier Maintenance (애플 공식 문서)'
description: "자주 재사용하는 뷰 제어자들을 하나로 묶어 커스텀 뷰 제어자로 사용하세요."
tags: ["ViewModifier", "View"]
categories: ["SwiftUI"]
cover:
    image: images/docs_1.jpg
    caption: ""
---

## Overview

일관된 뷰를 만들기 위해, 여러 화면에서 동일한 뷰 제어자 또는 제어자 조합을 반복해서 사용할 수 있습니다. 예를 들어, 앱 전체에서 텍스트 스타일을 통일하려 한다면, 많은 텍스트 뷰에 동일한 폰트와 글자 색을 적용하게 될 수 있습니다. 하지만 이런 방식은 유지 보수를 어렵게 만듭니디. 폰트 크기처럼 아주 작은 변경만 발생해도, 코드 여러 곳을 하나한 수정해야 하기 때문입니다.

이런 반복 작업을 줄이기 위해, 여러 제어자를 [ViewModifier]() 프로토콜을 구현한 하나의 타입으로 모아 두면 됩니다. 그리고 [View]() 프로토콜을 확장해 이 제어자를 적용하는 메서드를 만들어두면, 사용하기도 쉽고 코드도 훨씬 읽기 쉬워집니다. 이렇게 제어자들을 한 곳에 모아두면, 향후 스타일을 변경해야 할 때도 그 한곳만 수정하면 되므로 유지 보수가 편해집니다.


## Create a custom view modifier

커스텀 제어자를 만들 때는, 그 목적을 잘 드러내는 이름을 붙이는 것이 좋습니다. 예를 들어, [caption]() 폰트 스타일과 _secondary_ 색상을 반복해서 적용해 보조 텍스트 스타일을 표현하고 싶다면, _CaptionTextFormat_ 샅은 이름으로 하나로 묶어둘 수 있습니다.

```swift
struct CaptionTextFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
```

[modifier(_:)]() 메서드를 사용해 만들어둔 커스텀 제어자를 적용합니다. 아래 코드는 앞서 예로 들었던 커스텀 제어자를 [Text]() 인스턴스에 적용하는 방법을 보여줍니다.

```swift
Text("Some additional information...")
    .modifier(CaptionTextFormat())
```



## Extend the view protocol to provide fluent modifier access

커스텀 뷰 제어자를 더 편리하게 사용할 수 있도록 하려면, [View]() 프로토콜을 확장해 해당 제어자를 적용하는 함수를 추가합니다.

```swift
extension View {
    func captionTextFormat() -> some View {
        modifier(CaptionTextFormat())
    }
}
```

이 확장을 텍스트 뷰에 작성해 커스텀 제어자를 적용하세요.

```swift
Text("Some additional information...")
    .captionTextFormat()
```