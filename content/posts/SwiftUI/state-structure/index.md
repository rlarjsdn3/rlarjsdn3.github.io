---
date: '2025-12-24T13:52:21+09:00'
draft: false
title: 'SwiftUI / State (애플 공식 문서)'
description: "A property wrapper type that can read and write a value managed by SwiftUI."
tags: ["State", "Binding", "Bindable"]
categories: ["SwiftUI"]
cover:
    image: images/swift.jpg
    caption: ""
---

{{ color color="lightgray" text="iOS 13.0+ | iPadOS 13.0+ | Mac Catalyst 13.0+ | macOS 10.15+ | tvOS 13.0+ | visionOS 1.0+ | watchOS 6.0+" }}

```swift
@frozen @propertyWrapper
struct State<Value>
```

## Mentioned in

* [Managing user interface state]()

* [Performaing a search operation]()

* [Understanding the navigation stack]()


## Overview

뷰 계층에 저장하는 특정 값 타입에 대해서는 _state_&#8203;를 단일한 진실의 원천(single source of truth)으로 사용하세요. _@State_&#8203;를 프로퍼티 선언에 적용하고 초기 값을 제공하여 [App](), [Scene]() 또는 [View]() 안에 _state_ 값을 만드세요. 상태(state)는 _private_&#8203;으로 선언하여 멤버와이즈 이니셜라이저로 초기화되지 못하도록 막으세요. 그렇지 않으면 SwiftUI가 관리하는 저장소와 충돌할 수 있습니다.

```swift
struct PlayButton: View {
    @State private var isPlaying: Bool = false // Creates the state.

    var body: some View {
        Button(isPlaying ? "Pause" : "Play") { // Read the state.
            isPlaying.toggle() // Write the state.
        }
    }
}
```

SwiftUI는 해당 속성의 저장소를 관리합니다. 값이 변경되면 SwiftUI는 그 값에 의존하는 뷰 계층의 일부분을 업데이트합니다. _state_&#8203;의 기본 값에 접근하려면 [wrappedValue]() 속성을 사용합니다. 그러나 Swift에서는 간편하게 _state_ 인스턴스 자체를 참조하여 값(wrapped value)에 바로 접근할 수 있습니다. 위의 예제에서는 _isPlaying_ 속성의 값을 속성 자체를 통해 직접 읽고 쓰고 있습니다.

값에 접근이 필요한 뷰 계층 중 가장 상위 뷰에서 _state_&#8203;를 _private_&#8203;으로 선언하세요. 그런 다음 해당 값에 접근해야 하는 하위 뷰들과 공유하세요. 읽기 전용 접근이 필요한 경우에는 값을 직접 전달하고, 읽기 및 쓰기가 필요한 경우에는 바인딩(binding)으로 전달합니다. _state_ 속성은 어느 스레드에서도 안전하게 변경할 수 있습니다.


## Share state with subviews

_state_ 속성을 하위 뷰에 전달하면, SwiftUI는 상위 뷰의 값이 변경될 때마다 하위 뷰를 업데이트합니다. 그러나 하위 뷰는 그 값을 수정할 수 없습니다 하위 뷰에서 _state_&#8203;의 저장된 값을 수정할 수 있도록 하려면 대신 [Binding]()을 전달해야 합니다.

예를 들어, 위의 예제에서 플레이 버튼에 있던 _isPlaying_ _state_&#8203;를 제거하고, 대신 버튼이 바인딩을 받도록 만들 수 있습니다.

```swift 
struct PlayButton: View {
    @Binding var isPlaying: Bool // Play button now receive a binding.

    var body: some View {
        Button(isPlaying ? "Pause" : "Play") {
            isPlaying.toggle()
        }
    }
}
```

그런 다음 _state_&#8203;를 선언하고 해당 _state_&#8203;에 대한 바인딩을 생성하는 _player_ 뷰를 정의할 수 있습니다. _state_&#8203; 값에 대한 바인딩은 _state_&#8203;의 [projectedValue]()에 접근하여 얻을 수 있으며, 이는 속성 이름 앞에 달러 기호($)를 붙여 사용할 수 있습니다.

```swift 
struct PlayerView: View {
    @State private var isPlaying: Bool = false // Create the state here now.

    var body: some View {
        VStack {
            PlayButton(isPlaying: $isPlaying) // Pass a binding.

            // ...
        }
    }
}
```

[StateObject]()를 사용할 때와 마찬가지로, _State_&#8203;도 _private_&#8203;으로 선언하여 멤버와이즈 이니셜라이저에서 초기화되지 못하도록 막으세요. 그렇지 않으면 SwiftUI가 제공하는 저장소와 충돌할 수 있습니다. 단, _StateObject_&#8203;와 달리 _State_&#8203;는 선언 시 기본값을 제공하여 초기화해야 합니다. 위의 예제처럼 _state_&#8203;는 해당 뷰와 그 하위 뷰에만 국한된 로컬 저장소 용도로만 사용하세요.


## Store observable objects

[Observable()]() 매크로로 생성한 옵저버블 객체도 _State_&#8203;에 저장할 수 있습니다. 예를 들어,

```swift
@Observable
class Library {
    var name = "My library of books"
    // ...
}

struct ContentView: View {
    @State private var library = Library()

    var body: some View {
        LibraryView(library: library)
    }
}
```

_State_ 프로퍼티는 SwiftUI가 뷰를 인스턴스화할 때 항상 기본 값을 함께 인스턴스화합니다. 이러한 이유로 기본값을 초기화할 때 사이드-이펙트(side effects)가 생기거나 성능에 부담이 되는 작업은 피해야 합니다. 예를 들어, 뷰가 자주 업데이트되는 경우 매번 다시 초기화될 때마다 새로운 기본 객체를 할당하면 비용이 많이 들 수 있습니다. 대신, 뷰가 실제로 처음 나타날 때 한 번만 호출되는 [task(priority:_:)]() 제어자를 사용해 객체 생성을 지연시키는 것이 좋습니다. 

```swift
struct ContentView: View {
    @State private var library: Library?

    var body: some View {
        LibraryView(library: library)
            .task {
                library = Library()
            }
    }
}
```

옵저버블 상태 객체의 생성을 지연시키면 SwiftUI가 뷰를 초기화할 때마다 불필요하게 객체를 반복 생성하는 일을 방지할 수 있습니다. [task(priority:_:)]() 제어자를 사용하는 것도 네트워크 호출이나 파일 접근처럼 뷰의 초기 상태를 설정하기 위해 필요한 다른 작업들을 지연시키는 효과적인 방법입니다. 

> **Note:**
> [ObservableObject]() 프로토콜을 준수하는 객체를 _State_ 프로퍼티에 저장할 수도 있습니다. 하지만, 이 경우 뷰는 해당 객체의 참조가 변경될 때만 업데이트됩니다. 즉, 프로퍼티에 다른 객체의 참조를 할당할 때만 뷰가 갱신됩니다. 반면, 객체 내부의 _published_ 프로퍼티 값이 변경되더라도 뷰는 업데이트되지 않습니다. 참조 변경뿐만 아니라 객체의 _@Published_ 프로퍼티의 변경까지 추적하려면, 객체를 저장할 때 [State]() 대신 [StateObject]()를 사용해야 합니다. 


## Share observable state objects with subviews

_State_&#8203;에 저장된 [Observable]() 객체를 하위 뷰와 공유하려면, 그 객체의 참조를 하위 뷰에 전달하면 됩니다. SwiftUI는 객체의 옵저버블 프로퍼티가 변경될 때마다 하위 뷰를 업데이트하지만, 이는 하위 뷰의 [body]()가 해당 프로퍼티를 읽을 때만 발생합니다. 예를 들어, 아래 코드에서 _BookView_&#8203;는 _title_이 변경될 때만 업데이트되지만 _isAvailable_&#8203;이 변경될 때는 업데이트되지 않습니다. 

```swift
@Observable
class Book {
    var title = "A sample book"
    var isAvailable = true
}

struct ContentView: View {
    @State private var book = Book()

    var body: some View {
        BookView(book: book)
    }
}

struct BookView: View {
    var book: Book

    var body: some View {
        Text(book.title)
    }
}
```

_State_ 프로퍼티는 값에 대한 바인딩을 제공합니다. 객체를 저장한 경우, 그 객체 자체(즉, 객체의 참조)에 대한 [Binding]()을 얻을 수 있습니다. 이는 하위 뷰에서 _State_&#8203;에 저장된 참조 자체를 변경해야 할 때 유용합니다. 예를 들어, 참조를 _nil_&#8203;로 설정해야 하는 경우에 유용할 수 있습니다.

```swift
struct ContentView: View {
    @State private var book: Book?


    var body: some View {
        DeleteBookView(book: $book)
            .task {
                book = Book()
            }
    }
}


struct DeleteBookView: View {
    @Binding var book: Book?

    var body: some View {
        Button("Delete book") {
            book = nil
        }
    }
}
```

하지만 _State_&#8203;에 저장된 객체의 프로퍼티를 변경할 때는 해당 객체에 대한 [Binding]()을 전달할 필요가 없습니다. 예를 들어, 참조 자체에 대한 바인딩을 전달하는 대신 객체의 참조만 하위 뷰에 넘겨주면, 하위 뷰에서 그 객체의 프로퍼티 값을 새 값으로 설정할 수 있습니다.

```swift
struct ContentView: View {
    @State private var book = Book()

    var body: some View {
        BookCheckoutView(book: book)
    }
}


struct BookCheckoutView: View {
    var book: Book

    var body: some View {
        Button(book.isAvailable ? "Check out book" : "Return book") {
            book.isAvailable.toggle()
        }
    }
}
```

객체의 특정 프로퍼티에 대한 바인딩이 필요하다면 두 가지 방법이 있습니다. 객체 자체에 대한 바인딩을 전달한 뒤 필요한 위치에서 특정 프로퍼티의 바인딩을 추출하거나, 객체의 참조를 전달한 다음 [Bindable]() 프로퍼티 래퍼를 사용해 특정 프로퍼티에 대한 바인딩을 생성하는 것입니다. 예를 들어, 아래 코드에서 _BookEditorView_&#8203;는 _book_&#8203;을 _@Bindable_&#8203;로 감쌉니다. 그런 다음 뷰는 $ 기호를 사용해 [TextField]()에 _title_ 프로퍼티에 대한 비인딩을 전달합니다. 

```swift
struct ContentView: View {
    @State private var book = Book()

    var body: some View {
        BookView(book: book)
    }
}

struct BookView: View {
    let book: Book

    var body: some View {
        BookEditorView(book: book)
    }
}

struct BookEditorView: View {
    @Bindable var book: Book

    var body: some View {
        TextField("Title", text: $book.title)
    }
}
```