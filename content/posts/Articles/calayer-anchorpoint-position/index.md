---
date: '2025-02-28T22:34:21+09:00'
draft: false
title: "CALayer의 anchorPoint 톺아보기"
description: ""
tags: ["CALayer", "anchorPoint", "position"]
categories: ["Articles"]
cover:
    image: images/ca.jpg
---
## 개요

[CALayer](https://developer.apple.com/documentation/quartzcore/calayer)는 이미지 기반의 콘텐츠를 관리하고, 해당 콘텐츠에 애니메이션을 적용할 수 있도록 하는 객체입니다. 레이어는 뷰의 백킹-스토어(backing-store) 역할을 할 뿐만 아니라, 뷰 없이도 콘텐츠를 직접 표시할 수 있습니다. 레이어의 주요 역할은 제공된 시각적 콘텐츠를 관리하는 것이지만, 배경 색상, 테두리와 그림자를 설정할 수 있는 자체적인 시각적 속성도 가지고 있습니다.

이뿐만 아니라 [CALayer](https://developer.apple.com/documentation/quartzcore/calayer)는 다양한 속성을 활용하여 이동(Translate), 크기(Scale)나 회전(Roate) 등 레어어에 변형을 가할 수 있습니다. 그리고 이러한 변형은 모두 기본적으로 레이어의 정중앙을 기준으로 일어나게 됩니다. 일반적으로 이 기준은 크게 문제가 되지 않지만, 항상 예외가 존재하기 마련입니다. 이 기준점을 변경하는 데 도움을 주는 [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint)와 [position](https://developer.apple.com/documentation/quartzcore/calayer/position) 속성 및 그 관계에 대해 자세히 살펴보겠습니다.

## Position

[position](https://developer.apple.com/documentation/quartzcore/calayer/position) 속성은 상위 레이어의 좌표계를 기준으로 레이어의 위치를 나타낸 값입니다. 이 속성의 값은 포인트(point) 단위로 지정되며, 항상 [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성의 값에 상대적으로 결정됩니다. 

[position](https://developer.apple.com/documentation/quartzcore/calayer/position) 속성을 제대로 이해하려면 [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성과의 관계를 함께 살펴봐야 합니다.


## AnchorPoint

> **Note**:
> [UIView]()에 대해 기준점을 잡고 싶으시다면 [anchorPoint]() 속성을 참조하세요.

[anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성은 이름에서 알 수 있듯이, 레이어의 바운즈(bounds)에서 기준점(anchor point)을 정의합니다. 이 속성의 값은 비율 기반 좌표 공간(unit coordinate space)을 사용하여 지정해야 합니다. 이 속성의 기본값은 (0.5, 0.5)입니다. 

뷰에 대한 모든 기하학적 변형은 지정된 기준점을 중심으로 일어납니다. 예를 들어, 기본 기준점에서 레이어에 회전 변형을 적용하면, 레이어는 정중앙을 기준으로 회전하게 됩니다. 다른 지점으로 기준점을 변경하면 레이어는 새로운 지점을 기준으로 회전합니다.

개념은 정말 쉽습니다. 하지만 [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성에 새로운 값을 할당할 때는 주의가 필요합니다. [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성에 새로운 값을 할당하면 레이어의 위치가 의도치 않게 변경될 수 있습니다. 이는 **상위 레이어의 좌표계를 기준으로 한 [position]()이 [anchorPoint]()에 따른 하위 레이어가 위치하는 좌표를 결정**하기 때문입니다. 즉, [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성은 단독으로 레이어의 위치를 변경하는 것이 아니라, [position](https://developer.apple.com/documentation/quartzcore/calayer/position) 속성의 영향을 받아 레이어의 최종 위치를 결정합니다.

> **Note**:
> [position](https://developer.apple.com/documentation/quartzcore/calayer/position)의 기본값은 레이어의 정중앙 좌표값이고, [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint)의 기본값은 (0.5, 0.5)입니다.

아래는 이를 보여주는 코드와 그림입니다. 너비와 높이가 100, 100인 빨간색 뷰에 파란색 레이어를 추가하고, 파란색 레이어의 기준점을 (0.5, 0.5)에서 (0, 0)으로 변경해보겠습니다.

```swift
let blueLayer = CALayer()
blueLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
blueLayer.backgroundColor = UIColor.systemBlue.cgColor
//blueLayer.position = CGPoint(x: 50, y: 50)
blueLayer.anchorPoint = CGPoint(x: 0, y: 0)
self.view.layer.addSublayer(blueLayer)
```

{{< figure src="image-1.png" width="350px" align="center" >}}

우리는 단순히 기준점을 변경했지만, 레이어의 위치가 예상과 다르게 변경되는 결과를 얻었습니다. 이는 [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성을 (0, 0)으로 변경했음에도 불구하고, [position](https://developer.apple.com/documentation/quartzcore/calayer/position) 속성이 (50, 50)으로 유지되었기 때문입니다. [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성은 [position](https://developer.apple.com/documentation/quartzcore/calayer/position) 속성에 의해 레이어의 최종 위치가 결정된다는 점을 기억해야 합니다. 

아래는 anchorPoint 속성을 각각 (0, 0), (0, 1), (1, 0), (1, 1)로 변경했을 때의 코드와 이에 따른 변화를 나타낸 그림입니다.

### (0, 0)

```swift
//blueLayer.position = CGPoint(x: 50, y: 50)
blueLayer.anchorPoint = CGPoint(x: 0, y: 0)
```

{{< figure src="image-1.png" width="350px" align="center" >}}

### (0, 1)

```swift
//blueLayer.position = CGPoint(x: 50, y: 50)
blueLayer.anchorPoint = CGPoint(x: 0, y: 1)
```

{{< figure src="image-2.png" width="350px" align="center" >}}


### (1, 0)

```swift
//blueLayer.position = CGPoint(x: 50, y: 50)
blueLayer.anchorPoint = CGPoint(x: 1, y: 0)
```

{{< figure src="image-3.png" width="350px" align="center" >}}


### (1, 1)

```swift
//blueLayer.position = CGPoint(x: 50, y: 50)
blueLayer.anchorPoint = CGPoint(x: 1, y: 1)
```

{{< figure src="image-4.png" width="350px" align="center" >}}

---

그렇다면 기준점(anchorPoint)을 변경하고, 레이어의 위치는 그대로 유지하려면 어떻게 해야 할까요? 감이 잡히셨나요? 정답은 [position](https://developer.apple.com/documentation/quartzcore/calayer/position) 속성을 함께 변경하는 것입니다.

아래는 [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint)와 [position](https://developer.apple.com/documentation/quartzcore/calayer/position) 속성을 조정하여 레이어의 위치를 유지하는 코드입니다. 또한, [CAAnimation]()을 적용하여 기준점이 올바르게 변경되었는지 확인해보겠습니다.

```swift
blueLayer.position = CGPoint(x: 0, y: 0)
blueLayer.anchorPoint = CGPoint(x: 0, y: 0)
```

{{< figure src="image-5.png" width="350px" align="center" >}}

```swift
let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
scaleAnimation.fromValue = 1.0
scaleAnimation.toValue = 1.5
scaleAnimation.duration = 1.0
scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
scaleAnimation.repeatCount = .infinity
scaleAnimation.autoreverses = true
self.blueLayer.add(scaleAnimation, forKey: "scale")
```

{{< figure src="image-6.gif" width="350px" align="center" >}}

기준점에 맞게 제대로 애니메이션되는 걸 볼 수 있습니다.



## 활용 사례

그렇다면 이 개념을 어떻게 활용할 수 있을까요? 제 경험을 예로 들어 설명해보겠습니다. [TSAlertController](https://github.com/rlarjsdn3/TSAlertController-iOS)
)에서 `actionSheet`를 위로 드래그할 때, (0.5, 1.0) 지점을 기준으로 스트레칭(stretching) 효과를 주는 제스처를 구현하고자 했습니다. 그리고 뷰(레이어)의 위치는 유지되어야 합니다. 이를 위해 [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성을 (0.5, 1.0)으로 변경하는 동시에, 새로운 [anchorPoint](https://developer.apple.com/documentation/quartzcore/calayer/anchorpoint) 속성으로 뷰의 보정 너비와 높이값을 구하고 [position](https://developer.apple.com/documentation/quartzcore/calayer/position) 속성을 조정했습니다.

{{< figure src="image-7.gif" width="350px" align="center" >}}

```swift
extension CALayer {
    
    /// 레이어의 `anchorPoint`를 변경하면서 현재 위치(`position`)를 유지하는 메서드입니다.
    ///
    /// `anchorPoint`를 변경하면 `position` 값이 자동으로 변하기 때문에,
    /// 이를 보정하여 레이어가 시각적으로 동일한 위치에 유지되도록 조정합니다.
    ///
    /// - Parameter anchorPoint: 새롭게 설정할 `anchorPoint` 값 (`CGPoint`)
    ///
    func setAnchorPoint(anchorPoint: CGPoint) {
        let newPoint = CGPoint(x: self.bounds.width * anchorPoint.x,
                               y: self.bounds.height * anchorPoint.y)
        
        let oldPoint = CGPoint(x: self.bounds.width * self.anchorPoint.x,
                               y: self.bounds.height * self.anchorPoint.y)
        
        var position = self.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.position = position
        self.anchorPoint = anchorPoint
    }
}
```

```swift
view.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 1.0))
```


## 참고 자료

* [Changing my CALayer's anchorPoint moves the view](https://stackoverflow.com/questions/1968017/changing-my-calayers-anchorpoint-moves-the-view)

* [Understanding UIKit: CALayer Anchor Point](https://ikyle.me/blog/2022/understanding-uikit-calayer-anchor-point)


