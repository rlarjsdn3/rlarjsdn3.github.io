---
date: '2025-11-30T12:33:21+09:00'
draft: false
title: '[번역] Core Location / Supporting Live Updatesin SwiftUI and Mac Catalyst Apps (애플 공식 문서)'
description: "라이프사이클 이벤트 지원을 추가하여 백그라운드 이벤트를 활성화하세요."
tags: ["CLLocationManager", "CLBackgroundActivitySession", ""]
categories: ["Core Location"]
cover:
    image: images/docs_1.jpg
    caption: ""
---

## Overview

iOS 17 이상에서는 _Core Location_&#8203;이 _Swift Concurrency_&#8203;의 _async/await_ 기능을 사용한 실시간 업데이트를 지원합니다. 실시간 업데이트를 적용하려면 SwiftUI 및 Mac Catalyst 앱에서 라이프사이클 이벤트를 지원해야 하며, 이를 통해 `@main` 앱이 백그라운드 런-루프의 생성과 재개를 명시적으로 지원하도록 구현해야 합니다. 이 기능을 통해 시스템은 _Core Location_ 이벤트를 앱에 전달할 수 있으며, 앱이 백그라운드에서 다시 돌아오거나 실행될 때, 혹은 크래시 후 재실행될 때에도 이벤트 전달이 다시 이어질 수 있습니다. 


## Adding lifecycle events to SwiftUI

라이프사이클 이벤트를 지원하도록 하려면 앱에 세 가지 컨포넌트를 추가해야 합니다:

1. [CLLocationManager]()와 [CLBackgroundActivitySession]() 인스턴스를 관리하는 [ObservableObject]() 프로토콜을 준수하는 공유 상태 객체

2. 백그라운드에서 복귀하거나 앱이 다시 실행될 때 백그라운드 작업을 재개하도록 처리하는 [application(_:didFinishLaunchingWithOptions:)]() 메서드를 제공하는 _AppDelegate_ 객체

3. _AppDelegate_ 객체가 포함된 SwiftUI 또는 Mac Catalyst 앱의 `@main` 구조체

SwiftUI 또는 Mac Catalyst 앱에서 _App Delegate_를 지원하려면, 아래 예제와 같이 [ObservableObject]() 프로토콜을 준수하는 공유 상태 객체를 _App Delegate_에 추가하고, [UIApplicationDelegateAdaptor]()를 `@main` 구조체 내에 유지하도록 해야 합니다.

```swift
import SwiftUI

// Shared state that manages the `CLLocationManager` and `CLBackgroundActivitySession`
@MainActor class LocationsHandler: ObservableObject {

    static let shared = LocationsHandler()
    private let manager: CLLocationManager
    private var background: CLBackgroundActivitySession?

    @Published var lastLocation = CLLocation()
    @Published var isStationary = false
    @Published var count = 0

    @Published
    var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet { UserDefaults.standard.set(updateStarted, forKey: "liveUpdatesStarted") }
    }

    @Published
    var backgroundActivity: Bool = UserDefaults.standard.bool(forKey: "BGActivitySessionStarted") {
        didSet { 
            backgroundActivity ? self.background = CLBackgroundActivitySession() : self.background?.invalidate()
            UserDefaults.standardset(backgroundActivity, forKey: "BGActivitySessionStarted")
        }
    }

    private init() {
        self.manager = CLLocationManager() // Creating a location manager instance is safe to call here in `MainActor`.
    }

    func startLocationUpdates() {
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
        self.logger.info("Starting location updates")
        Task() {
            do {
                self.updatesStarted = true
                let updates = CLLocationUpdates.liveUpdates()
                for try await update in updates {
                    if !self.updateStarted { break }
                    if let loc = update.location {
                        self.lastLocation = loc
                        self.isStationary = update.isStationary
                        self.count += 1
                        print("Location \(self.count): \(self.lastLocation)")
                    }
                }
            } catch {
                print("Could not start location updates")
            }
            return
        }
    }

    func stopLocationUpdates() {
        print("Stopping location updates")
        self.updatesStarted = false
        self.backgroundActivity = false
    }
}
```

다음으로, SwiftUI의 [ObservableObject]() 프로토콜을 준수하는 UIKit의 _AppDelegate_ 클래스의 인스턴스를 생성합니다. 이렇게 하면 _AppDelegate_가 SwiftUI의 앱 수준(app-level) 공유 상태에 참여할 수 있고, 필요할 때 _Core Location_ 작업을 다시 이어서 재개하도록 관리할 수 있습니다.

```swift
import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let locationsHandler = LocationHandler.shared

        // If location updates were previously active, restart them after the background launch.
        if locationsHandler.updatesStarted {
            locationsHandler.startLocationUpdates()
        }
        // If a background activity session was previously active, reinstantiate it after the background launch.
        if locationsHandler.backgroundActivity {
            locationsHandler.backgroundActivity = true
        }
        return true
    }
}
```

마지막으로 [UIApplicationDelegateAdaptor]()를 사용하여 _AppDelegate_ 기능을 앱의 `@main` 구조체에 포함시키세요.

```swift
@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```