---
date: '2025-12-27T10:07:36+09:00'
draft: false
title: '[번역] SwiftUI / Environment (애플 공식 문서)'
description: "A property wrapper that reads a value from a view’s environment."
tags: ["EnvironmentValues"]
categories: ["SwiftUI"]
cover:
    image: images/swift.jpg
    caption: ""
---

{{ color color="lightgray" text="iOS 13.0+ | iPadOS 13.0+ | Mac Catalyst 13.0+ | macOS 10.15+ | tvOS 13.0+ | visionOS 1.0+ | watchOS 6.0+" }}

## Mentioned in

* [Building and customizing the menu bar with SwiftUI]()

* [Managing search interface activation]()

* [Migrating to the SwiftUI life cycle]()


## Overview

_Environment_ 프로퍼티 래퍼를 사용하면 뷰의 환경(environment)에 저장된 값을 읽을 수 있습니다. 프로퍼티 선언에서 [EnvironmentValues]()의 키 패스를 지정해 읽을 값을 지정합니다. 예를 들어, [colorScheme]() 프로퍼티의 키 패스를 사용해 현재 뷰의 색상 모드를 읽는 프로퍼티를 다음과 같이 만들 수 있습니다.

```swift
@Environment(\.colorScheme) var colorScheme: ColorScheme
```

선언된 프로퍼티의 [wrappedValue]()에서 읽은 값을 기반으로 뷰의 콘텐츠를 조건부로 표시할 수 있습니다. 다른 프로퍼티 래퍼와 마찬가지로, 해당 프로퍼티 이름으 직접 참조하면 _wrapped value_&#8203;에 접근할 수 있습니다.

```swift
if colorScheme == .dark { // Checks the wrapped value.
    DarkContent()
} else {
    LightContent()
}
```

값이 변경되면, SwiftUI는 그 값에 의존하는 뷰의 모든 부분을 자동으로 업데이트합니다. 예를 들어, 위의 예제에서는 사용자가 _Appearance_ 설정을 변경할 때 이러한 업데이트가 발생할 수 있습니다.

이 프로퍼티 래퍼는 값을 읽을 때만 사용할 수 있으며, 값을 바꾸는 용도로는 사용할 수 없습니다. SwiftUI는 일부 환경 값을 시스템 설정에 따라 자동으로 업데이트하며, 다른 값들에는 적절한 기본값을 제공합니다. 이러한 값 중 일부는 재정의할 수 있고, [environment(_:_:)]() 제어자를 사용해 사용자가 정의한 커스텀 환경 값을 설정할 수도 있습니다. 

SwiftUI에서 제공하는 모든 환경 값의 전체 목록은 [EnvironmentValues]() 구조체의 프로퍼티에서 확인할 수 있습니다. 커스텀 환경 값을 만드는 방법에 대해서는 [Entry()]() 매크로를 참고하세요.


## Get an observable object

_Environment_&#8203;를 사용하면 뷰의 환경에서 옵저버블 객체를 가져올 수도 있습니다. 이때 옵저버블 객체는 반드시 [Observable]() 프로토콜을 준수해야 하며, 앱에서는 해당 객체를 직접 또는 키 패스를 통해 환경에 설정해야 합니다.

객체 자체를 사용해 환경에 설정하려면 [environment(_:)]() 제어자를 사용하세요.

```swift
@Observable
class Library {
    var books: [Book] = [Book(), Book(), Book()]

    var availableBooksCount: Int {
        books.filter(\.isAvailable).count
    }
}

@main
struct BookReaderAp: App {
    @State private var library = Library()

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(library)
        }
    }
}
```

옵저버블 객체를 타입으로 가져오려면, 프로퍼티를 선언하고 _Environment_ 프로퍼티 래퍼에 해당 객체의 타입을 지정합니다.

```swift
struct LibraryView: View {
    @Environment(Library.self) private var library

    var body: some View {
        // ...
    }
}
```

기본적으로, 객체 타입을 키로 사용해 환경에서 읽으면 논-옵셔널 객체가 반환됩니다. 이러한 기본 동작은 현재 뷰 계층 내의 어떤 뷰가 [environment(_:)]() 제어자를 사용해 해당 타입의 논-옵셔널 인스턴스를 미리 저장해두었다고 가정하기 때문입니다. 만약 뷰가 타입을 통해 객체를 가져오려 하지만, 그 객체가 환경에 존재하지 않는다면 SwiftUI는 예외를 발생시킵니다.

객체가 환경에 존재한다는 보장이 없는 경우, 아래 예제처럼 옵셔널 형태로 객체를 가져올 수 있습니다. 이때 객체가 환경에 존재하지 않으면 SwiftUI는 예외를 발생시키는 대신 _nil_&#8203;을 반환합니다.

```swift
@Environment(Library.self) private var library: Library?
```


## Get an observable object using a key path

키 패스를 사용해 객체를 설정하려면 [environment(_:_:)]() 제어자를 사용하세요.

```swift
@Observable
class Library {
    var books: [Book] = [Book(), Book(), Book()]

    var availableBooksCount: Int {
        books.filter(\.isAvailable).count
    }
}

@main
struct BookReaderApp: App {
    @State private var library = Library()

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(\.library, library)
        }
    }
}
```

객체를가져오려면 프로퍼티를 선언하고 해당 키 패스를 지정합니다.

```swift
struct LibraryView: View {
    @Environment(\.library) private var library

    var body: some View {
        // ...
    }
}
```