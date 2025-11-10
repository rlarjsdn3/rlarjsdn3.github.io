---
date: '2025-12-21T12:30:34+09:00'
draft: false
title: '[번역] SwiftUI / Understanding the Navigation Stack'
description: "앱의 구조 속에서 내비게이션 스택과 링크를 이해하고, 다양한 내비게이션 방식을 관리하는 방법을 알아보세요."
tags: ["NavigationStack", "NavigationPath"]
categories: ["SwiftUI"]
cover:
    image: images/docs_1.jpg
    caption: ""
---

## Overview

[NavigationStack]()은 앱의 내비게이션 구조를 위한 컨테이너입니다. 내비게이션 스택을 사용하면 루트 뷰 위에 여러 개의 뷰를 스택 형태로 표시할 수 있습니다.

_NavigationStack_&#8203;은 초기화 시 전달되는 _path_ 매개변수를 통해 앱의 내비게이션 상태를 노출합니다. 내비게이션 스택의 경로를 직접 제어하거나 스택에 표시되는 뷰를 추적하려면, [NavigationPath]() 또는 _Hashable_ 요소를 포함하는 [RandomAccessCollection]()과 [RangeReplaceableCollection]()에 대한 [Binding]()을 사용하세요.

_NavigationPath_&#8203;는 다양한 타입의 데이터를 함께 저장할 수 있는 타입 소거(type-erased) 컬렉션입니다, 만약 동일한 타입의 데이터만 다룬다면 [Array]()를 대신 사용할 수 있습니다. _NavigationPath_&#8203;는 타입이 소거되어 있기 때문에, 내비게이션 스택의 각 뷰에 대응하는 서로 다른 타입의 데이터를 표현할 수 있습니다.

> **Tip:**
> 네비게이션 경로의 요소로 모델 타입을 사용하는 것은 피하세요. 내비게이션 경로의 요소는 가벼운 타입이어야 하며, 데이터 모델을 전달하기 위한 수단으로 사용해서는 안 됩니다. 

내비게이션 스택의 또 다른 요소는 _navigation destination_&#8203;으로, 사용자가 앱 내에서 이동할 수 있는 뷰를 캡슐화합니다. 

다음 방법들을 사용하여 _NavigationStack_&#8203;에서 목적지(destination)를 표시할 수 있습니다.

* _View-destination_
    + [init(destination:label:)]() 이니셜라이저를 사용하면 뷰를 내비게이션 스택에 직접 푸시할 수 있습니다. _view-destination_ 링크는 일회성(fire-and-forget)으로 동작하며, SwiftUI가 내비게이션 상태를 추적하지만, 앱의 관점에서는 뷰를 푸시했다는 상태를 나타내는 훅(hook)이 존재하지 않습니다.

* _Value-destination_
    + _value-destination_은 경로(path)에 값을 푸시한다는 것을 의미합니다. SwiftUI는 경로에 푸시된 값을 사용하여 [navigationDestination(for:destination:)]() 제어자를 통해 해당 값에 대응하는 뷰를 결정합니다. [init(value:label)]() 이니셜라이저를 사용하면 내비게이션 경로에 값을 추가할 수 있고, [navigationDestination(for:destination:)]() 제어자를 사용해 경로에 추가된 데이터 타입을 특정 목적지 뷰에 매핑할 수 있습니다. [navigationDestination(isPresented:destination:)]() 제어자를 사용하면 코드로 내비게이션 스택에 뷰를 푸시할 수도 있습니다. 이 목적지는 상태를 가지며, Boolean 바인딩을 통해 앱에서 그 상태를 명시적으로 제어할 수 있습니다. 표시 상태를 단순한 Boolean 값보다 특정 값의 존재 여부로 표현하는 것이 더 적합한 경우에는 [navigationDestination(item:destination:)]()을 사용하세요. 이 제어자는 옵셔널 데이터 모델에 대한 바인딩을 받습니다.

> **Note:**
> _Value-destination_&#8203;과 _View-destination_ 링크는 화면에 표시되는 스택 자체를 직접 표현하지 않습니다. 대신, 경로(path)에 추가된 데이터를 참조하는 방식으로 동작합니다.


## Present view-destination links

_NavigationLink(destination:label:)_&#8203;을 사용하면 뷰를 _NavigationStack_&#8203;에 푸시할 수 있습니다. 이 이니셜라이저에서는 링크 자체에 표시될 레이블(label)과 사용자가 링크를 탭했을 때 표시되는 뷰(destination)를 모두 지정합니다.

[NavigationLink]()는 뷰 계층 구조에서 상위에 있는 내비게이션 구조 안에 포함되어야 합니다. 이 조건이 충족되지 않으면, 링크는 일반적으로 비활성화된 상태로 표시됩니다. 

아래 예제는 _NavigationStack_ 안에 두 개의 링크가 포함된 예시입니다.

```swift
struct DestinationView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                ColorDetail(color: .mint, text: "Mint")
            } label: {
                Text("Mint")
            }

            NavigationLink {
                ColorDetail(color: .red, text: "Red")
            } label: {
                Text("Red")
            }
        }
    }
}

struct ColorDetail: View {
    var color: Color
    var text: String

    VStack {
        Text(text)
        color
    }
}
```

이 예제에서 "Mint"라는 레이블을 탭하면 _ColorDetail(color: .mint, text: "Mint")_ 뷰가 내비게이션 스택에 푸시됩니다. 내비게이션 스택의 콘텐츠는 깊이 0단계에 루트 뷰(_NavigationLink_ 자체)가 있고, 깊이 1단계에 _Color(color: .mint, text: "Mint")_ 뷰가 위치하게 됩닌다. 

[init(destination:label:)]()을 사용할 때는 다음 사항에 유의하세요.

* SwiftUI는 내비게이션 상태와 경로의 내용을 추적하지만, 시스템이 뷰를 푸시할 때 이를 감지할 수 있는 상태 기반 훅은 제공되지 않습니다. 

* 이 방식으로 생성된 상태는 코드로 복원할 수 없습니다.

내비게이션 링크가 트리거되는 시점을 추적하려면 [onAppear(perform:)]()나 [task(priority:_:)]() 대신 [Manage navigation state and compose links]()에서 설명한 상태 기반 내비게이션을 사용하세요. 

[navigationDestination(isPresented:destination:)]() 제어자를 사용하면 Boolean 값에 대한 바인딩을 제공하여 코드로 내비게이션을 수행할 수 있습니다. 예를 들어, _ColorDetail_ 뷰를 코드로 내비게이션 스택에 푸시할 수 있습니다.

```swift
struct DestinationView: View {
    @State private var showDetails = false
    var favoriteColor: Color

    var body: some View {
        NavigationStack {
            VStack {
                Circle()
                    .fill(favoriteColor)

                Button("Show details") {
                    showDetails = true
                }
            }
            .navigationDestination(isPresented: $showDetails) {
                ColorDetail(color: favoriteColor, text: color.description)
            }
        }
    }
}
```

이 접근 방식은 사용자의 직접적인 상호작용이 아니라 상태 변화에 따라 내비게이션을 수행하고자 할 때, 또는 내비게이션 스택의 단일 타입 경로와는 다른 데이터 타입을 가진 일회성 목적지를 표시해야 할 때 사용합니다.


## Present value-destination links

내비게이션 경로에 데이터를 추가하면 SwiftUI는 해당 데이터 타입을 뷰에 매핑하고, 사용자가 링크를 탭할 때 그 뷰를 스택에 푸시합니다. 스택이 표시할 뷰를 지정하려면 _NavigationStack_ 내부에서 [navigationDestination(for:destination:)]_ 제어자를 사용하세요.

아래 예제는 _DestinationView_&#8203;를 여러 개의 내비게이션 링크로 구현한 것입니다.

```swift
NavigationStack {
    List {
        NavigationLink("Mint", value: Color.mint)
        NavigationLink("Red", value: Color.red)
    }
    .navigationDestination(for: Color.self) { color in 
        ColorDetail(color: color, text: color.description)
    }
}
```

위의 예제에서 SwiftUI는 값 타입(이 경우 _Color_)을 사용해 내비게이션 목적지를 결정합니다. 값 기반 내비게이션을 사용하면 하나의 스택에 대해 여러 가지 목적지를 정의할 수 있습니다. 사용자가 "Mint"를 탭하면, SwiftUI는 _.mint_ 값을 가진 _ColorDetail_ 뷰를 스택에 푸시합니다. 

값 기반 내비게이션은 목적지의 타입이 서로 다른 경우에 특히 유용합니다. 예를 들어, 색상뿐만 아니라 레시피 관련 콘텐츠도 함께 처리하도록 앱을 확장할 수 있습니다.

```swift
struct ValueView: View {
    private var recipes: [Recipe] = [.applePie, .chocolateCake]

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
                ForEach(recipes) { receip in 
                    NavigationLink(receip.description, value: receip)
                }
            }
        }
        .navigationDestination(for: Color.self) { color in 
            ColorDetail(color: color, text: color.destination)
        }
        .navigationDestination(for: Receip.self) { receip in 
            RecipeDetailView(receipe: recipe)
        }
    }
}

struct ReceipDetailView: View {
    var receipe: Recipe
    
    var body: some View {
        Text(receipe.description)
    }
}

enum Recipe: Identifiable, Hashable, Codable {
    case applePie
    case chocolateCake
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .applePie:
            return "Apple Pie"
        case .chocolateCake:
            return "Chocolate Cake"
        }
    }
}
```

이 예제에서 _NavigationStack_&#8203;은 두 가지 목적지 타입을 지원합니다. 색상을 위한 _Color_ 타입과 레시피를 위한 _Receipe_ 타입입니다. SwiftUI는 내비게이션 링크에서 전달된 값의 데이터 타입을 기준으로 올바른 목적지 뷰를 결정합니다. 

특정 항목의 존재 여부에 따라 뷰로 이동해야 할 때는 [navigationDestination(item:destination:)]()을 사용하세요. 항목이 _nil_&#8203;이 아니면, SwiftUI는 그 값을 _destination_ 클로저에 전달하고 해당 뷰를 스택에 푸시합니다. 예를 들어,

```swift
struct ContentView: View {
    private var receipes: [Recipe] = [.applePie, .chocolateCake]
    @State private var selectedRecipe: Recipe?

    var body: some View {
        NavigationStack {
            List(receipes, selection: $selectedRecipe) { receipe in 
                NavigationLink(receip.destination, value: receipe)
            }
            .navigationDestination(item: $selectedRecipe) { receipe in 
                ReceipeDetailView(recipe: recipe)
            }
        }
    }
}
```

사용자가 레시피를 탭하면 _selectedRecipe_ 값이 업데이트되고, SwiftUI는 _RecipeDetailView(recipe: recipe)_&#8203;를 내비게이션 스택에 푸시합니다. _selectedRecipe_ 값을 다시 _nil_&#8203;로 설정하면 해당 뷰가 스택에서 팝(pop)됩니다.


## Manage navigation state and compose links

기본적으로 내비게이션 스택은 스택에 쌓인 뷰들을 추적하기 위한 상태를 자체적으로 관리합니다. 하지만, 앱에서 직접 만든 데이터 값 컬렉션에 대한 바인딩을 사용해 스택을 초기화하면 해당 상태의 제어를 앱이 함께 공유할 수 있습니다.

이 스택의 내비게이션 상태를 관찰하려면 _NavigationPath_ 인스턴스에 대한 바인딩을 받는 [ini(path:root:)]() 이니셜라이저를 사용하세요.

_NavigationPath_ 데이터 타입은 다양한 타입의 _Hashable_ 값을 담을 수 있는 이종 컬렉션 타입(hetergeneous collection type)입니다. [append(_:)]() 메서드를 호출하거나, 사용자가 [init(value:label:)]()과 같은 값 기반 내비게이션 링크를 탭할 때 경로에 값을 추가할 수 있습니다.

[init(_:value:)]()를 사용해 스택에 값을 푸시하면, 아래 예제처럼 해당 값이 경로에 추가됩니다. 

```swift
struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color)
            }
        }
    }
}
```

이 예제에서 사용지가 링크를 활성화하면, SwiftUI는 _Color.mint_&#8203;와 같은 값을 _path_&#8203;에 추가합니다. SwiftUI는 _path_&#8203;라는 [State]() 프로퍼티를 사용해 내비게이션 스택의 상태를 관리합니다.

[init(path:root:)]()는 _path_ 매개변수로 _RandomAccessCollection_&#8203;과 _RangeReplaceableCollection_&#8203;을 모두 따르는 컬렉션에 대한 [Binding]()을 받는 구문을 제공합니다. [Observable]() 매크로를 적용한 데이터 타입의 객체 안에 _path_ 프로퍼티를 저장할 수 있으며, 값 기반 내비게이션 링크가 트리거될 때 발생하는 변화를 감지하기 위해 _willSet_&#8203;, _didSet_ 같은 프로퍼티 옵저버나 [onChange(of:initial:_:)]() 제어자를 사용할 수 있습니다.

이 경우 내비게이션 경로는 _Array_&#8203;와 같은 표준 타입이나, 아래 예제처럼 커스텀 데이터 타입을 받을 수 있는 동종 컬렉션 타입(homogeneous collection type)입니다.

```swift
@Observable
class NavigationManager {
    var path: [Color] = [] {
        willSet {
            print("will set to \(newValue)")
        }
        
        didSet {
            print("didSet to \(path)")
        }
    }
}

struct ContentView: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color, text: color.description)
            }
        }
    }
}
```

위 에제에서 _willSet_&#8203;과 _didSet_ 프로퍼티 옵저버는 내비게이션 링크가 트리거될 때를 감지합니다. 

또한, _path_ 변수의 참조를 사용해 코드로 내비게이션을 제어할 수도 있습니다. 예를 들어, 스택에서 뷰를 팝할 수 있습니다.

```swift
@Observable
class NavigationManager {
    var path: [Color] = [] {
        willSet {
            print("will set to \(newValue)")
        }
        
        didSet {
            print("didSet to \(path)")
        }
    }
    
    @discardableResult
    func navigateBack() -> Color? {
        path.popLast()
    }
}
```

스택이 단일 데이터 타입에만 의존하는 뷰를 표시할 때는 표준 타입을 사용하고, 아래 예제처럼 단일 스택에서 여러 데이터 타입을 표시해야 할 때는 _NavigationPath_&#8203;를 사용하세요.

```swift
struct ValueView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
                NavigationLink("Apple Pie", value: Recipe.applePie)
                NavigationLink("Chocolate Cake", value: Recipe.chocolateCake)
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
```

> **Note:**
> 값 기반 링크와 뷰 기반 링크 모두 최종적으로 사용자에게 표시되는 뷰를 스택에 푸시합니다. 그러나 값 기반 링크로 푸시된 경우에는 스택의 _path_ 바인딩(제공된 경우)에 반영되지만, 뷰 기반 링크로 푸시된 경우에는 반영되지 않습니다.

값 기반 링크와 뷰 기반 링크를 모두 함께 구성하고자 할 때, 내비게이션 API는 상황에 따라 두 가지 스타일의 링크를 모두 활용하도록 지원합니다. 

아래 예제에서 사용자가 "View Mint Color"를 탭하면, SwiftUI는 먼저 값 기반 링크를 스택에 푸시하고, 이어서 뷰 기반 링크를 푸시합니다.

```swift
struct ContentView: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            NavigationLink("View Mint Color", value: Color.mint)
                .navigationDestination(for: Color.self) { color in 
                    NavigtionLink("Push Recipe View") {
                        RecipeDetailView(recipe: .applePie)
                    }
                }
        }
    }
}
```

이 예제에서 코드가 실행된 후 사용자가 각 _NavigationLink_&#8203;를 클릭하면, 내비게이션 스택에는 총 세 개의 뷰가 순서대로 쌓이게 됩니다.

* Root
    + _NavigationStack_&#8203;의 시작 뷰

* Collection of values
    + _Color.mint_&#8203;와 같은 0개 이상의 값이 경로에 푸시됩니다. 이 값들은 SwiftUI가 어떤 뷰를 표시할지를 결정하기 위한 식별자나 키 역할을 합니다.

* Collection of views
    + _RecipeDetailView_&#8203;와 같은 일련의 뷰들이 경로에 추가됩니다. 이러한 뷰들은 내비게이션 대상(navigation destination) 안에 포함되어 있으며, 사용자가 링크를 탭할 때 표시됩니다.

SwiftUI는 전체 내비게이션 경로를 추적합니다. 그 내부 데이터 구조는 아래와 같습니다.

```
Root → [Color.mint] → [RecipeDetailView]
```

개념적으로 SwiftUI는 스택의 내비게이션 경로에서 값 기반 위에 뷰 기반을 쌓습니다. 예를 들어, 아래 코드에서 앞선 예제의 _RecipeDetailView_&#8203;를 _NavigationLink_&#8203;로 대체합니다.

```swift
struct ContentView: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            NavigationLink("View Mint Color", value: Color.mint)
                .navigationDestination(for: Color.self) { color in 
                    NavigationLink("Push Recipe View") {
                        NavigationLink("Push another view", value: Color.pink)
                    }
                }
        }
    }
}
```

수정된 예제를 실행하면 뷰 기반 링크가 여전히 스택의 맨 위에 있습니다. 스택에서 이종 또는 동종 경로를 사용할 경우, 아래와 같이 시간이 지나면서 내비게이션 경로가 변하는 것을 관찰할 수 있습니다.

```swift
@Observable
class NavigationManager {
    var path: [Color] = [] {
        didSet {
            parint("didSet to \(path)")
        }
    }
}

struct ContentView: View {
    @State private var navigationManager = NavigationManager()


    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            NavigationLink("View Mint Color", value: Color.mint)
                .navigationDestination(for: Color.self) { color in
                    NavigationLink("Push Recipe View") {
                        RecipeDetailView(recipe: .applePie)
                    }
                }
        }
    }
}
```

사용자가 앱을 탐색하면, 다음과 같은 로그가 출력됩니다.

```
New path: []
New Path: [Color.mint]
```

로그가 출력되는 이유는 뷰 기반 내비게이션 링크가 앱이 관찰할 수 있는 상태 변화를 발생시키지 않기 때문입니다. 스택에 뷰 기반 링크가 쌓여 있는 상태에서 값을 푸시하려 하면, SwiftUI는 모든 뷰 대상(destination)을 팝하고 해당 값의 대상을 스택에 푸시합니다.



## Restore state for navigation paths

네비게이션 경로의 상태 복원(State restoration)은 앱이 다시 실행될 때 이전의 상호작용 지점으로 인터페이스를 복원할 수 있게 하여, 사용자가 앱을 사용할 때 연속성을 제공합니다. 

iOS에서는 윈도우나 씬(scene) 수준에서 상태 복원이 특히 중요합니다. 윈도우는 자주 생성되고 사라지기 때문입니다. 따라서 내비게이션 경로의 상태 복원도 앱의 상태를 윈도우나 씬 수준에서 복원하는 방식과 동일하게 고려해야 합니다. 씬 데이터를 저장하는 방법에 대해서는 [Restoring your app's state with SwiftUI to learn about storing scene data]()를 참고하세요.

_Codable_&#8203;을 사용하면 내비게이션 스택의 경로를 직접 저장하고 불러올 수 있습니다. 이때 경로 데이터 타입이 동종이냐 이종이냐에 따라 두 가지 방식 중 하나를 선택하게 됩니다. 아래 예제처럼 동종 타입의 경로는 그대로 저장할 수 있습니다.

```swift
@Observable
class NavigationManager {
    var path: [Recipe] = [] {
        didSet {
            save() 
        }
    }

    /// The URL for the JSON file that stores the navigation path.
    private static var dataURL: URL {
        .documentsDirectory.appending(path: "NavigationPath.json")
    }

    init() {
        do {
            // Load the data model from the 'NavigationPath' data file found in the Documents directory.
            let path = try load(url: NavigationManager.dataURL)
            self.path = path
        } catch {
            // Handle error.
        }
    }

    func save() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(path)
            try data.write(to: NavigationManager.dataURL)
        } catch {
            // Handle error.
        }
    }

    /// Load the navigation path from a previously saved state.
    func load(url: URL) throws -> [Recipe] {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let decoder = JSONDecoder()
        return try decoder.decode([Recipe].self, from: data)
    }
}

struct ContentView: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
                NavigationLink("Apple Pie", value: Recipe.applePie)
                NavigationLink("Chocolate Cake", value: Recipe.chocolateCake)
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color, text: color.description)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
```

위 예제에서는 _path_ 프로퍼티가 변경될 때 _didSet_ 프로퍼티 옵저버가 트리거되고, 그 안에서 _save_ 함수가 호출됩니다. 이 함수는 변경된 경로를 디스크에 저장하여, 나중에 _NavigationManager_&#8203;가 초기화될 때 이 경로를 복원할 수 있게 합니다.

이종 경로는 아래 예제처럼 _NavigationPath_&#8203;을 사용해 저장합니다.

```swift
@Observable
class NavigationManager {
    var path = NavigationPath() {
        didSet {
            save()
        }
    }

    /// The URL for the JSON file that stores the navigation path.
    private static var dataURL: URL {
        .documentsDirectory.appending(path: "NavigationPath.json")
    }

    init() {
        do {
            // Load the data model from the 'NavigationPath' data file found in the Documents directory.
            let path = try load(url: NavigationManager.dataURL)
            self.path = path
        } catch {
            // Handle error.
        }
    }

    func save() {
        guard let codableRepresentation = path.codable else { return }
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(codableRepresentation)
            try data.write(to: NavigationManager.dataURL)
        } catch {
            // Handle error.
        }
    }

    /// Load the navigation path from a previously saved data.
    func load(url: URL) throws -> NavigationPath {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let decoder = JSONDecoder()
        let path = try decoder.decode(NavigationPath.CodableRepresentation.self, from: data)
        return NavigationPath(path)
    }
}
```

위 예제에서 _save_ 메서드는 _path.codable_&#8203;이 _nil_&#8203;인지 여부를 확인합니다. 이 값은 경로의 내용을 직렬화 가능한 형식으로 표현한 것입니다. 경토 안에 타입 소거 요소 중 _Codable_&#8203;을 준수하지 않는 항목이 하나라도 있으면 _nil_&#8203;을 반환합니다.

이 검사는 매우 중요합니다. 왜냐하면 _NavigationPath_&#8203;는 데이터 타입이 _Codable_&#8203;을 따를 것을 요구하지 않기 떄문입니다. _NavigationPath_는 단지 _Hashable_&#8203;을 따르기만 하면 되므로, 컴파일 시점에 내비게이션 경로가 _Codable_&#8203;로 직렬화할 수 있는 유요한 표현인지 확인할 수 없습니다.

내비게이션 스택, 링크, 그리고 경로에 대해 더 알아보려면 [Bringing robust navigation structure to your SwiftUI app]()를 참고하세요.