---
date: '2025-12-20T22:32:45+09:00'
draft: false
title: '[번역] SwiftUI / Migrating From the Observable Object Protocol to the Observable Macro (애플 공식 문서)'
description: "기존 앱을 Swift의 Observation이 제공하는 이점을 활용하도록 업데이트하세요."
tags: ["ObservableObject", "@Observable"]
categories: ["SwiftUI"]
cover:
    image: images/docs_.jpg
    caption: ""
---

[Download](https://docs-assets.developer.apple.com/published/b78f7ecb6749/ObservationSample.zip)

## Overview

iOS 17, iPadOS 17, macOS 14, tvOS 17, 그리고 watchOS 10부터 SwiftUI는 옵저버 디자인 패턴을 Swift에 맞게 구현한 [Observation]()을 지원합니다.

* 옵셔널 값이나 객체 컬렉션을 추적할 수 있습니다. 이는 [ObservableObject]()를 사용할 때는 불가능한 기능입니다.

* [State]()나 [Environment]() 같은 기존의 데이터 흐름 기본 타입을 사용할 수 있으며, [StateObject]()나 [EnvironmentObject]()처럼 객체 기반의 타입을 사용할 필요가 없습니다.

* 뷰의 [body]()에서 읽는 _observable_ 속성의 변경에만 기반해 뷰를 업데이트합니다. 이는 _observable_ 객체의 모든 속성 변경 시마다 뷰가 업데이트되는 기존 방식과 달리, 앱의 성능을 향상시키는 데 도움이 됩니다.

앱에서 이러한 이점을 활용하기 위해, [ObservableObject]()에 의존하는 기존 소스 코드를 [Observable()]() 매크로를 사용하는 코드로 교체하는 방법을 알아보겠습니다.

> **Note:**
> 마이그레이션된 버전의 샘플 앱을 보려면 이 샘플을 다운로드하세요. 마이그레이션 이전 버전을 보려면 [Monitoring data changes in your app]()에서 제공하는 샘플을 다운로드하면 됩니다. 이 문서를 따라 직접 코드를 작성해보고 싶다면 마이그레이션 이전 버전을 사용해도 됩니다.


## Use the Observable macro

기존 앱에서 [Observation]()을 도입하려면, 데이터 모델 타입에 [ObservableObject]()를 [Observable()]() 매크로로 교체하는 것부터 시작하세요. [Observable()]() 매크로는 컴파일 시점에 관찰 기능을 해당 타입에 추가하는 소스 코드를 생성합니다.

```swift
// BEFORE
import SwiftUI

class Library: ObservableObject {
    // ...
}
```

```swift
// AFTER
import SwiftUI

@Observable class Library {
    // ...
}
```

그 다음, _observable_ 프로퍼티에서 [Published]() 프러퍼티 래퍼를 제거하세요. _Observation_&#8203;에서는 프로퍼티를 관찰 가능하게 만들기 위해 별도의 프로퍼티 래퍼가 필요하지 않습니다. 대신, 뷰와 같은 옵저버와의 접근성에 따라 해당 프로퍼티가 관찰 가능한지가 결정됩니다.

```swift
// BEFORE
@Observable class Library {
    @Published var books: [Book] = [Book(), Book(), Book()]
}
```

```swift
// AFTER
@Observable class Library {
    var books: [Book] = [Book(), Book(), Book()]
}
```

옵저버가 접근할 수 있지만 추적하지 않길 원하는 프로퍼티가 있다면, 해당 프로퍼티에 [ObservationIgnored()]() 매크로를 적용하세요.


## Migrate incrementally

앱 전체에서 [ObservableObject]() 프로토콜을 한 번에 교체할 필요는 없습니다. 대신 점진적으로 변경할 수 있습니다. 먼저 한 가지 데이터 모델 타입을 [Observable()]() 매크로를 사용하도록 변경해보세요. 앱 내에서는 서로 다른 _observation_ 시스템을 사용하는 데이터 모델 타입을 혼합해 사용할 수도 있습니다. 다만, SwiftUI는 데이터 모델 타입이 사용하는 _observation_ 시스템(_Observable_&#8203;인지, _ObservableObject_&#8203;인지)에 따라 변경 사항을 추적하는 방식이 다릅니다.

추적 방식에 따라 앱의 동작에 약간의 차이가 나타날 수 있습니다. 예를 들어, [Observable()]() 방식으로 추적할 때, SwiftUI는 _observable_ 프로퍼티가 변경되고 뷰의 [body]()가 해당 프로퍼티를 직접 읽을 때만 뷰를 업데이트합니다. _body_&#8203;에서 읽지 않는 _observable_ 프로퍼티가 변경되더라도 뷰는 업데이트되지 않습니다. 반면 [ObservableObject]() 방식으로 추적할 때는 뷰가 해당 프로퍼티를 읽지 않더라도 _ObservableObject_ 인스턴스의 어떤 _Published_ 프로퍼티가 변경되면 뷰가 업데이트됩니다.

> **Note:**
> _observable_ 프로퍼티가 변경될 때 SwiftUI가 뷰를 언제 업데이트하는지에 대해 더 알아보려면, [Managing model data in your app]()을 참고하세요.


## Migrate other source code

지금까지 샘플 앱에 적용한 변경 사항은 _Library_ 타입에 [Observable()] 매크로를 적용하고 [ObservableObject]() 프로토콜 준수를 제거한 것입니다. 앱은 여전히 _Library_ 인스턴스를 관리하기 위해 [StateObject]()와 같은 [ObservableObject]() 기반 데이터 흐름 기본 타입을 사용하고 있습니다. 이 상태에서 앱을 빌드하고 실행해도 SwiftUI는 여전히 예상대로 뷰를 업데이트합니다. 그 이유는 [StateObject]()와 [EnvironmentObject]() 같은 데이터 흐름 프로퍼티 래퍼가 [Observable()]() 매크로를 사용하는 타입도 지원하기 때문입니다. SwiftUI는 앱이 점진적으로 소스 코드를 변경할 수 있도록 이러한 호환성을 제공합니다. 

그러나 [Observation]()을 완전히 도입하려면, 데이터 모델 타입을 업데이트한 후 [StateObject]() 대신 [State]()를 사용해야 합니다. 예를 들어, 아래 코드에서는 메인 앱 구조체는 _Library_ 인스턴스를 생성하고 이를 [StateObject]()에 저장합니다. 또한 [environmentObject(_:)]() 제어자를 사용해 _Library_ 인스턴스를 _environment_&#8203;에 추가합니다.

```swift
// BEFORE
@main
struct BookReaderApp: App {
    @StateObject private var library = Library()

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environmentObject(library)
        }
    }
}
```

이제 _Library_&#8203;가 더 이상 [ObservableObject]()를 준수하지 않으므로, 코드를 수정하여 [StateObject]() 대신 [State]()를 사용하고, [environmentObject(_:)]() 대신 [environment(_:)]() 제어자를 사용해 _library_&#8203;를 _environment_&#8203;에 추가할 수 있습니다.

```swift
// AFTER
@main
struct BookReaderApp: App {
    @State private var library = Library()

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(library)
        }
    }
}
```

_Library_&#8203;가 [Observation]()을 완전히 도입하려면 한 가지를 더 바꿔야 합니다. 이전 코드에서는 _LibraryView_&#8203;에서 [EnvironmentObject]() 프로퍼티 래퍼를 사용해 _environment_&#8203;에서 인스턴스를 가져왔습니다. 그러나 새로운 코드에서는 대신 [Environment]() 프로퍼티 래퍼를 사용합니다.

```swift
// BEFORE
struct LibraryView: View {
    @EnvironmentObject var library: Library

    var body: some View {
        List(library.books) { book in
            BookView(book: book)
        }
    }
}
```

```swift 
// AFTER
struct LibraryView: View {
    @Environment(Library.self) private var library 

    var body: some View {
        List(library.books) { book in
            BookView(book: book)
        }
    }
}
```


## Remove the ObservedObject property wrapper

샘플 앱의 마이그레이션을 마무리하려면, 데이터 모델 타입인 _Book_&#8203;에도 [Observation]()을 적용하세요. 이를 위해 타입 선언에서 [ObservableObject]()를 제거하고 [Observable()]() 매크로를 적용합니다. 그 다음 관찰할 프로퍼티들에서 [Published]() 프로퍼티 래퍼를 제거하세요.

```swift
// BEFORE
class Book: ObservableObject, Identifiable {
    @Published var title = "Sample Book Title"

    let id = UUID() // A unique identifier that never changes.
}
```

```swift
// AFTER
@Observable class Book: Identifiable {
    var title = "Sample Book Title"

    let id = UUID() // A unique identifier that never changes
}
```

다음으로 _BookView_&#8203;의 _book_ 변수에서 [ObservedObject]() 프로퍼티 래퍼를 제거하세요. [Observation]()을 도입하면 이 프로퍼티 래퍼는 더 이상 필요하지 않습니다. 그 이유는 SwiftUI가 뷰의 [body]()에서 직접 읽는 _observable_ 프로퍼티를 자동으로 추적하기 때문입니다. 예를 들어 _book.title_&#8203;이 변경되면 SwiftUI는 _BookView_&#8203;를 자동으로 업데이트합니다.

```swift
// BEFORE
struct BookView: View {
    @ObservedObject var book: Book
    @State private var isEditorPresented = false

    var body: some View {
        HStack {
            Text(book.title)
            Spacer()
            Button("Edit") {
                isEditorPresented = true
            }
        }
        .sheet(isPresented: $isEditorPresented) {
            BookEditView(book: book)
        }
    }
}
```

```swift
// AFTER
struct BookView: View {
    var book: Book
    @State private var isEditorPresented = false

    var body: some View {
        HStack {
            Text(book.title)
            Spacer()
            Button("Edit") {
                isEditorPresented = true
            }
        }
        .sheet(isPresented: $isEditorPresented) {
            BookEditView(book: book)
        }
    }
}
```

뷰가 _observable_ 타입에 대한 바인딩이 필요할 경우에는 [ObservableObject]() 대신 [Bindable]() 프로퍼티 래퍼를 사용해야 합니다. 이 프로퍼티 래퍼는 _observable_ 타입에 바인딩 기능을 제공하여, 바인딩을 기대하는 뷰가 _observable_ 프로퍼티의 값을 변경할 수 있게 합니다. 예를 들어, 아래 코드에서 [TextField]()는 _book.title_&#8203;에 대한 바인딩을 전달받습니다.

```swift
// BEFORE
struct BookEditView: View {
    @ObservedObject var book: Book
    @Environment(\.dismiss)private var dismiss

    var body: some View {
        VStack() {
            TextField("Title", text: $book.title)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    dismiss()
                }

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

```swift
// AFTER
struct BookEditView: View {
    @Bindable var book: Book
    @Environment(\.dismiss)private var dismiss

    var body: some View {
        VStack() {
            TextField("Title", text: $book.title)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    dismiss()
                }

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```