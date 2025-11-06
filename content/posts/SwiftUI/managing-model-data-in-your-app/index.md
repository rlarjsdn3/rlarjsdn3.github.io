---
date: '2025-12-20T11:11:10+09:00'
draft: false
title: '[번역] SwiftUI / Managing Model Data in Your App (애플 공식 문서)'
description: ""
tags: ["@Observable", "ObservableObject", "@State"]
categories: ["SwiftUI"]
cover:
    image: images/docs_2.jpg
    caption: ""
---

[Download](https://docs-assets.developer.apple.com/published/6c08da4d9562/ManagingModelDataSample.zip)


## Overview

SwiftUI 앱은 사용자가 앱의 사용자 인터페이스(UI)를 통해 변경할 수 있는 데이터를 표시할 수 있습니다. 이러한 데이터를 관리하기 위해 앱은 데이터를 표현하는 사용자 정의 타입인 데이터 모델(data model)을 생성합니다. 데이터 모델은 데이터와 그 데이터와 상호작용하는 뷰를 분리해줍니다. 이러한 분리는 모듈화를 촉진하고, 테스트 용이성을 높이며, 앱의 동작 방식을 더 쉽게 이해할 수 있도록 도와줍니다.

모델 데이터(즉, 데이터 모델의 인스턴스)를 화면에 표시되는 내용과 동기화를 하는 것은 어려울 수 있습니다. 특히 데이터가 UI의 여러 뷰에 동시에 표시되는 경우에는 더욱 그렇습니다.

SwiftUI는 _Observation_ 덕분에 데이터가 변경될 때 앱의 UI를 최신 상태로 유지하도록 도와줍니다. _Observation_&#8203;을 사용하면 SwiftUI의 뷰가 관찰 가능한 데이터 모델(observable data model)에 의존 관계를 형성하고, 데이터가 변경될 때 UI를 자동으로 업데이트할 수 있습니다.

> **Note:**
> SwiftUI의 [Observation]()은 iOS 17, iPadOS 17, macOS 14, tvOS 17, watchOS 10부터 사용할 수 있습니다. 기존 앱에서 _Observation_&#8203;을 도입하는 방법에 대한 내용은 [Migrating from the Observable Object Protocol to the Observable macro]()를 참고하세요.


## Make model data observable

데이터 변경 사항이 SwiftUI에 반영되도록 하려면 데이터 모델에 [Observable()]() 매크로를 적용하세요. 이 매크로는 컴파일 시점에 데이터 모델에 관찰 기능을 추가하는 코드를 생성하여, 데이터 모델 코드가 데이터 저장에 필요한 프로퍼티에만 집중할 수 있도록 합니다. 예를 들어, 아래 코드는 책에 대한 데이터 모델으 정의합니다.

```swift
@Observable class Book: Identifiable {
    var title = "Sample Book Title"
    var author = Author()
    var isAvailable = true
}
```

> **Important:**
> [Observable()] 매크로는 관찰 기능을 추가할 뿐만 아니라 _Observation_&#8203;을 지원한다는 사실을 다른 API에 전달하기 위해 해당 타입이 _Observable_ 프로토콜을 자동으로 준수하도록 합니다. _Observable_ 프로토콜만 단독으로 데이터 모델 타입에 적용해서는 안 됩니다. 프로토콜만 적용해도 관찰 기능이 추가되지 않기 때문입니다. 대신, 타입에 관찰 기능을 추가할 때는 항상 _Observable_ 매크로를 사용해야 합니다.


## Observe model data in a view

SwiftUI에서는 뷰는 Book 인스턴스와 같은 옵저버블 데이터 모델 객체의 프로퍼티를 _body_ 속성에서 읽을 때, 해당 데이터 모델 객체에 대한 의존성을 형성합니다. 반대로 _body_가 옵저버블 데이터 모델 객체의 어떤 프로퍼티도 읽지 않는다면, 그 뷰는 해당 객체에 대한 의존성을 추적하지 않습니다.

추적 중인 프로퍼티가 변경되면 SwiftUI는 해당 뷰를 업데이트합니다. 반면, _body_&#8203;에서 읽지 않는 다른 프로퍼티가 변경되더라도 뷰에는 영향을 주지 않으며 불필요한 업데이트를 피합니다. 예를 들어, 아래 코드의 뷰는 책의 _title_&#8203;이 변경될 때만 업데이트되고, _author_&#8203;이나 _isAvailable_&#8203;이 변경될 때는 업데이트되지 않습니다.

```swift
struct BookView: View {
    var book: Book

    var body: some View {
        Text(book.title)
    }
}
```

SwiftUI는 뷰가 옵저버블 타입을 직접 저장하지 않더라도, 예를 들어 전역 프로퍼티나 싱글톤을 사용할 때에도 이러한 의존성 추적을 형성합니다.

```swift
var globalBook: Book = Book()

struct BookView: View {
    var body: some View {
        Text(globalBook.title)
    }
}
```

_Observation_&#8203;은 계산 프로퍼티가 옵저버블 프로퍼티를 사용하고 있을 경우, 해당 계산 프로퍼티의 변경도 추적할 수 있습니다. 예를 들어, 아래 코드의 뷰는 이용 가능한 책의 개수가 변경될 때 업데이트됩니다.

```swift
@Observable class Library {
    var books: [Book] = [Book(), Book(), Book()]

    var availableBooksCount: Int {
        books.filter(\.isAvailable).count
    }
}

struct LibraryView: View {
    @Environment(Library.self) private var library

    var body: some View {
        NavigationStack {
            List(library.books)  { book in 
                // ...
            }
            .navigationTitle("Books available: \(library.availableBooksCount)")
        }
    }
}
```

뷰가 어떤 컬렉션 타입이든 객체의 컬렉션에 의존성을 형성하면, 뷰는 컬렉션 자체의 변경 사항을 추적합니다. 예를 들어, 아래 코드의 뷰에서 _body_&#8203;는 _books_&#8203;를 읽기 때문에 _books_&#8203;에 대한 의존성을 형성합니다. _books_ 컬렉션에 항목이 추가, 삭제, 이동, 교체되는 등의 변경이 발생하면 SwiftUI는 해당 뷰를 업데이트합니다.

```swift
struct LibraryView: View {
    @State private var books = [Book(), Book(), Book()]

    var body: some View {
        List(books) { book in
            Text(book.title)
        }
    }
}
```

하지만 _LibraryView_&#8203;는 _title_ 프로퍼티에 대한 의존성을 형성하지 않습니다. 그 이유는 뷰의 [body]()가 _title_&#8203;을 직접 읽지 않기 때문입니다. 이 뷰에서 [List]()의 콘텐츠 클로저는 _@escaping_ 클로저로 받으며, SwiftUI는 화면에 표시되기 전에 리스트 항목을 지연(lazy) 생성할 때 이 클로저를 호출합니다. 따라서 _LibaryView_ 자체가 책의 _title_&#8203;에 의존하는 것이 아니라, 리스트의 각 [Text]() 항목이 _title_&#8203;에 의존하게 됩니다. 즉, _title_&#8203;이 변경되면 해당 책을 표시하는 개별 [Text]()만 업데이트되고, 다른 항목들은 영향을 받지 않습니다.

> **Note:**
> _Observation_은 뷰의 [body]() 프로퍼티 실행 범위 내에 나타나는 모든 옵저버블 프로퍼티의 변경을 추적합니다.

옵저버블 모델 데이터 객체를 다른 뷰와 공유할 수도 있습니다. 이때, 전달받은 뷰가 _body_&#8203; 안에서 해당 객체의 프로퍼티를 읽으면 의존성이 형성됩니다. 예를 들어, 아래 코드에서 _LibraryView_는 _Book_ 인스턴스를 _BookView_&#8203;와 공유하고, _BookView_&#8203;는 책의 제목만 표시합니다. 책의 제목이 변경되면 SwiftUI는 _title_ 프로퍼티를 읽는 _BookView_&#8203;만 업데이트하고, _LibraryView_는 업데이트하지 않습니다.

```swift
struct LibraryView: View {
    @State private var books = [Book(), Book(), Book()]

    var body: some View {
        List(books) { book in 
            BookView(book: book)
        }
    }
}

struct BookView: View {
    var book: Book

    var body: some View {
        Text(book.title)
    }
}
```

뷰가 어떤 의존성을 갖지 않는 경우, SwiftUI는 데이터가 변경되더라도 해당 뷰를 업데이트하지 않습니다. 이런 방식 덕분에 옵저버블 모델 데이터 객체는 중간에 위치한 각 뷰가 의존성을 형성하지 않고도, 여러 계층의 뷰 계층 구조를 거쳐 전달될 수 있습니다.

```swift
// Will not update when any property of `book` changes.
struct LibraryView: View {
    @State private var book = Book()

    var body: some View {
        LibraryItemView(book: book)
    }
}

// Will not update when any property of `book` changes.
struct LibraryItemView: View {
    var book: Book

    var body: some View {
        BookView(book: book)
    }
}

// Will update when `book.title` changes.
struct BookView: View {
    var book: Book

    var body: some View {
        Text(book.title)
    }
}
```

하지만 옵저버블 객체에 대한 참조를 저장하는 뷰는 그 참조 자체가 변경될 경우 업데이트됩니다. 이는 객체가 옵저버블이 아니라, 저장된 참조가 뷰의 값(value)의 일부이기 때문입니다. 예를 들어, 아래 코드에서 _book_&#8203;에 대한 참조가 변경되면 SwiftUI는 해당 뷰를 업데이트합니다.

```swift
struct BookView: View {
    var book: Book

    var body: some View {
        // ...
    }
}
```

뷰는 다른 객체를 통해 접근한 옵저버블 데이터 모델 객체에도 의존성을 형성할 수 있습니다. 예를 들어, 아래 코드의 뷰는 _author_&#8203;의 _name_&#8203;이 변경될 때 업데이트됩니다.

```swift
struct LibraryItemView: View {
    var book: Book

    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
            Text("Written by: \(book.author.name)")
                .font(.caption)
        }
    }
}
```

## Create the source of truth for model data

모델 데이터의 단일한 진실의 원천(single source of truth)을 생성하고 저장하려면, 우선 _private_ 변수를 선언한 뒤 옵저버블 데이터 모델 타입의 인스턴스로 초기화합니다. 그런 다음 해당 변수를 [State]() 프로퍼티 래퍼로 감쌉니다. 예를 들어, 아래 코드는 데이터 모델 타입 _Book_&#8203;의 인스턴스를 상태 변수 _book_&#8203;에 저장합니다.

```swift
struct BookView: View {
    @State private var book = Book()

    var body: some View {
        Text(book.title)
    }
}
```

_book_을 [State]()로 감싸면, SwiftUI에게 해당 인스턴스의 저장을 관리하도록 지시하는 것입니다. SwiftUI가 _BookView_&#8203;를 다시 생성할 때마다 _book_ 변수는 SwiftUI가 관리하는 인스턴스에 연결되며, 이로써 뷰는 모델 데이터에 대한 단일한 진실의 원천을 가지게 됩니다.

앱의 최상위 [App]() 인스턴스나 [Scene]() 인스턴스 내에서도 상태 객체를 생성할 수 있습니다. 예를 들어, 아래 코드는 앱의 최상위 구조에서 _Library_ 인스턴스를 생성합니다.

```swift
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


## Share model date throughout a view hierarchy

앱 전역에 공유하고 싶은 _Library_&#8203;와 같은 데이터 모델 객체가 있다면 다음 두 가지 방법 중 하나를 사용할 수 있습니다.

* 하나는 뷰 계층 구조의 각 뷰에 해당 데이터 모델 객체를 전달하는 방법이고,

* 다른 하나는 데이터 모델 객체를 뷰의 _environment_&#8203;에 추가하는 방법입니다.

모델 데이터를 각 뷰에 전달하는 방식은 뷰 계층 구조가 얕을 때 편리합니다. 예를 들어, 한 뷰가 자신의 하위 뷰들과 해당 객체를 공유하지 않는 경우가 그렇습니다. 그러나 실제로는 하위 뷰에 객체를 전달해야 하는지, 또는 계층 구조의 깊은 곳의 하위 뷰가 모델 데이터를 필요로 하는지 미리 알기 어려운 경우가 많습니다.

모델 데이터를 각 뷰에 직접 전달하지 않고 뷰 계층 전체에서 공유하려면, 모델 데이터를 뷰의 _environment_&#8203;에 추가하면 됩니다. [environment(_:_:)]()나 [environment(_:)]() 제어자를 사용해 모델 데이터를 전달함으로써 _environment_&#8203;에 데이터를 추가할 수 있습니다.

[environment(_:_:)]() 제어자를 사용하기 전에, 먼저 사용자 정의 [EnvironmentKey]()를 생성해야 합니다. 그런 다음 [EnvironmentValues]()를 확장하여 해당 키의 값을 가져오고 사용자 정의 환경 프로퍼티를 추가합니다. 예를 들어, 아래 코드는 _library_&#8203;를 위한 환경 키와 프로퍼티를 생성합니다.

```swift
extension EnvironmentValues {
    var library: Library {
        get { self[LibraryKey.self] }
        set { self[LibraryKey.self] = newValue }
    }
}

private struct LibraryKey: EnvironmentKey {
    static let defaultValue: Library = Library()
}
```

사용자 정의 환경 키와 프로퍼티를 정의한 후에는, 뷰가 모델 데이터를 자신의 _environment_&#8203;에 추가할 수 있습니다. 예를 들어, _BookReaderApp_&#8203;은 [environment(_:_:)]() 제어자를 사용하여 _Library_ 인스턴스의 단일한 진실의 원천을 _environment_&#8203;에 추가합니다.

```swift
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

_environment_&#8203;에서 _Library_ 인스턴스를 가져오려면, 뷰에서 해당 인스턴스의 참조를 저장할 로컬 변수를 정의한 뒤, 그 변수를 [Environment]() 프로퍼티 래퍼로 감쌉니다. 이때 사용자 정의 환경 값에 대한 키 경로를 전달합니다.

```swift
struct LibraryView: View {
    @Environment(\.library) private var library

    var body: some View {
        // ...
    }
}
```

커스텀 환경 값을 정의하지 않고도, [environment(_:)]() 제어자를 사용하여 모델 데이터를 환경에 직접 저장할 수도 있습니다. 예를 들어, 이 제어자를 사용해 _Library_ 인스턴스를 _environment_&#8203;에 추가합니다.

```swift
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

_environment_&#8203;에서 인스턴스를 가져오기 위해, 다른 뷰는 해당 인스턴스를 저장할 로컬 변수를 정의하고 이를 [Environment]() 프로퍼티 래퍼로 감쌉니다. 이때 환경 값의 키 경로를 전달하는 대신, 아래 코드와 같이 모델 데이터 타입 자체를 전달할 수 있습니다.

```swift
struct LibraryView: View {
    @Environment(Library.self) private var library

    var body: some View {
        // ...
    }
}
```

기본적으로, 객체 타입을 키로 사용하여 _environment_&#8203;에서 객체를 읽을 때는 비-옵셔널(non-optional) 객체가 반환됩니다. 이 기본 동작은 현재 뷰 계층 내의 상위 뷰가 [environment(_:)]() 제어자를 사용해 해당 타입의 비-옵셔널 인스턴스를 이미 환경에 저장했다고 가정하기 때문입니다. 만약 뷰가 타입을 통해 객체를 가져오려 하지만, 그 객체가 환경에 존재하지 않는다면 SwiftUI는 예외를 발생시킵니다.

객체가 _environment_&#8203;에 존재한다는 보장이 없는 경우, 아래 코드와 같이 옵셔널 형태로 객체를 가져올 수 있습니다. 이때 객체가 _environment_&#8203;에 존재하지 않으면 SwiftUI는 예외를 발생시키는 대신 _nil_&#8203;을 반환합니다. 


## Change model data in a view

대부분의 앱에서는 사용자가 앱에 표시된 데이터를 변경할 수 있습니다. 데이터가 변경되면, 해당 데이터를 표시하는 모든 뷰는 변경된 내용을 반영하도록 업데이트되어야 합니다. SwiftUI의 _Observation_&#8203;을 사용하면, 뷰는 프로퍼티 래퍼나 바인딩을 사용하지 않고도 데이터 변경을 처리할 수 있습니다. 예를 들어, 아래 코드는 버튼의 액션 클로저에서 책의 _isAvailable_ 프로퍼티를 토글합니다.

```swift
struct BookView: View {
    var book: Book

    var body: some View {
        List {
            Text(book.title)
            HStack {
                Text(book.isAvailable ? "Available or checkout" : "Waiting for return")
                Spacer()
                Button(book.isAvailable ? "Check out" : "Return") {
                    book.isAvailable.toggle()
                }
            }
        }
    }
}
```

하지만 어떤 경우에는 뷰가 변경 가능한 프로퍼티의 값을 수정하기 위해 바인딩을 필요로 할 수 있습니다. 이때는 모델 데이터를 [Bindable]() 프로퍼티 래퍼로 감싸 바인딩을 제공할 수 있습니다. 예를 들어, 아래 코드는 _book_ 변수를 _@Bindable_&#8203;로 감싼 뒤, [TextField]()를 사용해 책의 _title_ 프로퍼티를 변경하고 [Toggle]()을 사용해 _isAvailable_ 프로퍼티를 변경합니다. 각 프로퍼티에는 $ 기호를 사용해 바인딩을 전달합니다.

```swift
struct BookEditView: View {
    @Bindable var book: Book
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack() {
            HStack {
                Text("Title")
                TextField("Title", text: $book.title)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        dismiss()
                    }
            }

            Toggle(isOn: $book.isAvailable) {
                Text("Book is available")
            }

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderProminent)
        }
        .padding()
    }
}
```

[Bindable]() 프로퍼티 래퍼는 [Observable]() 객체에 대한 프로퍼티나 변수에 사용할 수 있습니다. 여기에는 전역 변수, SwiftUI 타입 외부에 존재하는 프로퍼티, 혹은 로컬 변수도 포함됩니다. 예를 들어, 뷰의 [body]() 내부에서 _@Bindable_ 변수를 생성할 수도 있습니다.

```swift
struct LibraryView: View {
    @State private var books = [Book(), Book(), Book()]

    var body: some View {
        List(books) { book in 
            @Bindable var book = book
            TextField("Title", text: $book.title)
        }
    }
}
```

_@Bindable_ 변수 _book_&#8203;은 [TextField]()와 책의 _title_ 프로퍼티를 연결하는 바인딩을 제공합니다. 이를 통해 사용자는 모델 데이터에 직접 변경을 가할 수 있습니다.