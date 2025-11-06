---
date: '2025-12-15T14:33:28+09:00'
draft: false
title: '[번역] SwiftUI / Managing User Interface State (애플 공식 문서)'
description: "앱의 뷰 계층 구조 안에 뷰 전용 데이터를 캡슐화하여 뷰를 재사용할 수 있도록 하세요."
tags: ["State", "Binding", "Bindable"]
categories: ["SwiftUI"]
cover:
    image: images/docs_1.jpg
    caption: ""
---

## Overview

해당 데이터가 필요한 뷰들의 가장 가까운 공통 조상 뷰에 상태(state)로 데이터를 저장해서, 여러 뷰가 공유하는 단일한 진실의 원천(single source of truth)을 만드세요. 이 데이터를 Swift 프로퍼티로 읽기 전용으로 제공하거나, 바인딩(binding)을 사용해 상태와 양방향으로 연결할 수 있습니다. SwiftUI는 이 데이터의 변경을 감시하고, 필요할 때마다 영향을 받는 뷰들을 업데이트합니다.

{{< figure src="managing-user-interface-state.png" width="650px" align="center" >}}

상태 프로퍼티를 영구적인 저장 용도로 사용하면 안됩니다. 상태 변수의 생명 주기는 뷰의 생명 주기와 동일하기 때문입니다. 대신 버튼의 하이라이트 상태, 필터 설정, 현재 선택된 리스트 항목처럼 사용자 인터페이스에만 영향을 주는 일시적인 상태를 관리할 때 사용하세요. 또한 앱의 데이터 모델을 수정하기 전, 프로토타입을 만드는 동안 이러한 저장 방식을 임시로 사용하는 것도 편리할 수 있습니다.


## Manage mutable values as state

뷰가 수정 가능한 데이터를 저장해야 하는 경우, [State]() 프로퍼티 래퍼를 사용해 변수를 선언하세요. 예를 들어, 팟캐스트가 재생 중인지 추적하기 위해 팟캐스트 플레이어 뷰 안에 _isPlaying_&#8203;이라는 불리언 값을 만들 수 있습니다.

```swift
struct PlayerView: View {
    @State private var isPlaying: Bool = false

    var body: some View {
        // ...
    }
}
```

프로퍼티를 상태로 표시하면, 프레임워크가 그 내부 저장소를 관리하게 됩니다. 뷰는 프로퍼티 이름을 통해 @State의 [wrappedValue]()에 있는 데이터를 읽고 쓸 수 있습니다. 값을 변경하면 SwiftUI가 해당 부분의 뷰를 자동으로 업데이트합니다. 예를 들어, _PlayerView_&#8203;에 버튼을 추가해 탭할 때 저장된 값을 토글하도록 하고, 그 값에 따라 다른 이미지를 표시할 수 있습니다.

```swift
Button(action: {
    self.isPlaying.toggle()
}) {
    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
}
```

상태 변수를 _private_&#8203;으로 선언하여 그 범위를 제한하세요. 이렇게 하면 해당 변수가 선언된 뷰 계층 구조 내에 캡슐화되어 유지됩니다.


## Declare Swift properties to store immutable values

뷰가 수정하지 않는 데이터를 뷰에 제공하려면 일반 Swift 프로퍼티로 선언하세요. 예를 들어, 팟캐스트 플레이어에 에피소드 제목과 프로그램 이름이 포함된 구조체 타입의 상수를 추가할 수 있습니다.

```swift
struct PlayerView: View {
    let episode: Episode // The queued episode.
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack {
            // Display information about the episode.
            Text(episode.title)
            Text(episode.showTitle)

            Button(action: {
                self.isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
            }
        }
    }
}
```

_PlayerView_&#8203;에서 _episode_ 프로퍼티는 상수이지만, 이 뷰의 부모 뷰에서는 상수일 필요가 없습니다. 사용자가 부모 뷰에서 다른 에피소드를 선택하면 SwiftUI가 상태 변화를 감지하고, 새로운 입력값으로 _PlayerView_&#8203;를 다시 생성합니다.


## Share access to state with bindings

뷰가 자식 뷰와 상태를 함께 제어해야 할 경우, 자식 뷰에서 [Binding]() 프로퍼티 래퍼로 프로퍼티를 선언하세요. 바인딩(binding)은 기존 저장소에 대한 참조를 나타내며, 해당 데이터의 단일한 진실의 원천(single source of truth)를 유지합니다. 예를 들어, 팟캐스트 플레이어 뷰의 버튼을 _PlayButton_&#8203;이라는 자식 뷰로 리팩토링한다면, _isPlaying_ 프로퍼티에 대한 바인딩을 전달할 수 있습니다.

```swift
struct PlayButton: View {
    @Binding var isPlaying: Bool

    var body: some View {
        Button(action: {
            self.isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
        }
    }
}
```

위 예제에서 보다시피, 바인딩의 _wrapped value_는 상태와 마찬가지로 프로퍼티를 직접 참조하여 읽거나 쓸 수 있습니다. 하지만 상태 프로퍼티와 달리, 바인딩은 자체 저장소를 가지고 있지 않습니다. 대신 다른 곳에 저장된 상태 프로퍼티를 참조하여, 그 저장소와의 양방향 연결을 제공합니다.

_PlayButton_&#8203;을 인스턴스화할 때, 부모 뷰에 선언된 상태 변수 앞에 달리 기호($)를 붙여 바인딩을 전달하세요.

```swift
struct PlayerView: View {
    var episode: Episode
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack {
            Text(episode.title)
            Text(episode.showTitle)
            PlayButton(isPlaying: $isPlaying) // Pass a binding.
        }
    }
}
```

`$` 접두사는 _wrapped value_&#8203;의 [projectedValue]()를 요청하는데, 상태의 경우 이는 내부 저장소에 대한 바인딩을 의미합니다. 마찬가지로 바인딩 앞에 `$`를 붙이면 또 다른 바인딩을 얻을 수 있으며, 이를 통해 뷰 계층 구조의 여러 단계에 걸쳐 바인딩을 전달할 수 있습니다.

상태 변수 안의 특정 값에 대해서도 바인딩을 얻을 수 있습니다. 예를 들어, 플레이어의 부모 뷰에서 _episode_&#8203;를 상태 변수로 선언하고, _episode_ 구조체 안에 토글로 제어하고 싶은 _isFavorite_&#8203;라는 불리언 값이 있다면, _$episode.isFavorite_&#8203;로 접근하여 _episode_&#8203;의 즐겨찾기 상태에 대한 바인딩을 얻을 수 있습니다.

```swift
struct Podcaster: View {
    @State private var episode = Episode(title: "Some Episode",
                                         showTitle: "Greate Show",
                                         isFavorite: false)
                                
    var body: some View {
        VStack {
            Toggle("Favorite", isOn: $episode.isFavorite) // Bind to the Boolean.
            PlayerView(episode: episode)
        }
    }
}
```


## Animate state transitions

뷰의 상태가 변경되면 SwiftUI는 영향을 받는 뷰를 즉시 업데이트합니다. 만약 시각적인 전환을 부드럽게 만들고 싶다면, 상태 변화를 발생시키는 코드를 [withAnimation(_:_:)]() 함수로 감싸서 SwiftUI에 애니메이션 처리를 지시할 수 있습니다. 예를 들어, _isPlaying_ 불리언으로 제어되는 변화를 애니메이션으로 표현할 수 있습니다.

```swift
withAnimation(.easeInOut(duration: 1)) {
    self.isPlaying.toggle()
}
```

애니메이션 함수의 후행 클러저 안에서 _isPlaying_ 값을 변경하면, SwiftUI는 그 값에 의존하는 모든 요소(예: 버튼 이미지의 크기 변화 효과 등)를 애니메이션으로 처리합니다.

```swift
Image(systemName: isPlaying ? "pause.circle" : "play.circle")
    .scaleEffect(isPlaying ? 1 : 1.5)
```

SwiftUI는 지정한 곡선과 지속 시간(또는 별도로 지정하지 않은 경우 기본값)을 사용해, 스케일 효과의 입력 값을 1에서 1.5로 시간에 따라 점진적으로 전환합니다. 반면, 같은 불리언 값이 어떤 시스템 이미지를 표시할지를 결정하더라도 이미지 콘텐츠 자체는 애니메이션의 영향을 받지 않습니다. 이는 SwiftUI가 _pause.circle_&#8203;과 _play.circle_&#8203;이라는 두 문자열 사이를 의미 있게 점진적으로 전환할 방법을 모르기 때문입니다.

애니메이션은 상태 프로퍼티에 추가할 수도 있고, 위 예시처럼 바인딩에 추가할 수도 있습니다. 어떤 방식을 사용하든, SwiftUI는 내부에 저장된 값이 변경될 때 발생하는 모든 뷰의 변화를 애니메이션으로 처리합니다. 예를 들어, _PlayerView_&#8203;에 배경색을 추가하고 그 위치가 애니메이션 블록보다 상위 뷰 계층에 있다면, SwiftUI는 그 배경색의 변화 또한 함께 애니메이션합니다.

```swift
VStack {
    Text(episode.title)
    Text(episode.showTitle)
    PlayButton(isPlaying: $isPlaying)
}
.background(isPlaying ? Color.green : Color.red) // Transitions with animation.
```

상태 변화로 인한 애니메이션을 모든 뷰에 적용하는 것이 아니라, 특정 뷰에만 애니메이션을 적용하고 싶다면 [animation(_:value:)]() 뷰 제어자를 사용하세요.