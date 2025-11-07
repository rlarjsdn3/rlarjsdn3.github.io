---
date: '2024-10-15T13:31:43+09:00'
draft: false
title: '[번역] Clean Architecture and MVVM on iOS (Oleh kudinov)'
description: ""
tags: ["Clean Architecture", "Swift"]
categories: ["Articles"]
cover:
    image: cover.webp
    caption: ""
---

소프트웨어를 개발할 때는 디자인 패턴뿐만 아니라 아키텍처 패턴을 잘 사용하는 것도 중요합니다. 소프트웨어 엔지니어링에서 무수히 많은 다양한 아키텍처 패턴이 있습니다. 모바일 소프트웨어 엔지니어링에서 가장 널리 쓰이는 아키텍처 패턴으로 MVVM, 클린 아키텍처와 리덕스(redux) 패턴이 있습니다. 

이 글에서는 **MVVM**&#8203;과 **클린 아키텍처**&#8203;를 iOS 앱에 적용하는 방법을 [예제 프로젝트](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)로 보여드릴 겁니다. 

리덕스를 배우는 데에도 관심이 있다면 [Advanced iOS App Architecture](https://www.kodeco.com/books/advanced-ios-app-architecture) 도서를 참조하세요.

클린 아키텍처에 대한 자세한 정보는 [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)를 참조하세요.

{{< figure src="image-2.webp" width="650px" align="center" >}}

**클린 아키텍처** 그래프에서 보다시피, 애플리케이션에는 서로 다른 레이어가 있습니다. <span style="background-color: lightgray">안쪽 레이어는 바깥쪽 레이어에 의존성을 가져서는 아니됩니다.</span> 바깥쪽에서 안쪽으로 향하는 화살표는 [의존성 규칙](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)을 나타냅니다. 의존성은 바깥쪽 레이어에서 안쪽으로만 존재할 수 있습니다.

모든 레이어를 그룹화하면 **프리젠테이션(presentation)**&#8203;, **도메인(domain)**&#8203;, **데이터(data) 레이어**&#8203;가 있습니다. 

{{< figure src="image-3.webp" width="650px" align="center" >}}

**도메인 레이어(비즈니스 로직)**&#8203;는 양파의 가장 안쪽에 위치한 부분으로, 다른 레이어에 의존성이 없고, 완전히 격리(isolated)되어 있습니다. 도메인 레이어는 _엔터티(비즈니스 모델)_&#8203;, _유스 케이스_&#8203;와 _리포지토리 인터페이스_&#8203;를 가집니다. 이 레이어는 다른 프로젝트에서 재사용될 가능성이 있습니다. 이러한 분리는 별도의 의존성(써드파티 포함)을 필요로 하지 않기 때문에 테스트 타겟에서 호스트 앱을 사용하지 않아도 되게 합니다. 이로 인해 도메인 유스 케이스 테스트가 몇 초 내로 완료될 수 있습니다. **Note:** 도메인 레이어는 프리젠테이션 레이어의 UIKit 또는 SwiftUI의 뷰, 데이터 레이어의 매핑 코더블(Codable)처럼 다른 레이어의 **어느 요소도** 포함하면 안됩니다. 

좋은 아키텍처가 _유스 케이스_&#8203;를 중심으로 하는 이유는 설계자가 프레임워크, 도구와 환경에 구애받지 않고 _유스 케이스_&#8203;를 지원하는 구조를 안전하게 설명할 수 있기 때문입니다. 이것을 [Screaming Architecture]()라고 합니다.

**프리젠테이션 레이어**는 _UI(UIViewController 또는 SwiftUI View)_를 가집니다. 뷰는 하나 이상의 _유스 케이스_&#8203;를 실행하는 _뷰-모델(프리젠터)_&#8203;에 의해 통합됩니다. 프리젠테이션 레이어는 오직 **도메인 레이어만 의존**&#8203;합니다.

**데이터 레이어**&#8203;는 _리포지토리 구현_&#8203;과 _하나 이상의 데이터 소스_&#8203;를 가집니다. 리포지토리는 다양한 데이터 소스에서 데이터를 통합하는 역할을 합니다. 데이터 소스는 원격이나 로컬(e.g. 영속 저장소)이 될 수 있습니다. 데이터 레이어는 오직 **도메인 레이어만 의존**&#8203;합니다. 이 레이어에서는 네트워크 JSON 데이터에서 도메인 모델로 매핑(e.g. [Decodable conformance](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Data/Network/DataMapping/MoviesResponseDTO%2BMapping.swift))하는 작업도 추가할 수 있습니다.

아래 그래프는 각 레이어의 모든 요소를 **의존성 방향**&#8203;과 **데이터 흐름**&#8203;(요청/응답)과 함께 보여주고 있습니다. 리포지토리 인터페이스(프로토콜)를 사용하는 지점에서 **의존성 역전**&#8203;이 일어난다는 걸 볼 수 있습니다. 각 레이어의 설명은 글 초반에 언급한 [예제 프로젝트](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)를 기반으로 합니다.

{{< figure src="image-4.webp" width="650px" align="center" >}}

### Data Flow

1. _**뷰**&#8203;(UI)_&#8203;는 _**뷰-모델**&#8203;(프리젠터)_&#8203;의 메서드를 호출합니다.

2. _**뷰-모델**&#8203;_&#8203;은 _**유스 케이스**&#8203;_&#8203;를 실행합니다.

3. _**유스 케이스**&#8203;_&#8203;는 _**사용자**&#8203;_&#8203;와 _**리포지토리**&#8203;_&#8203;의 데이터를 결합합니다.

4. 각 _**리포지토리**_&#8203;는 _**원격 데이터** (네트워크)_&#8203;, _**영속 DB** 저장소_&#8203;나 _인-메모리 데이터 (원격 또는 캐시)_&#8203;에서 데이터를 반환합니다. 

5. 정보 흐름은 항목의 리스트를 표시하는 _**뷰**(UI)_&#8203;로 되돌아갑니다.

### Dependency Direction

**프리젠테이션 레이어** → **도메인 레이어** ← **데이터 리포지토리 레이어**

_**프리젠테이션 레이어(MVVM)**_ = _뷰-모델(프리젠터)_ + _뷰(UI)_

_**도메인 레이어**_ = _엔터티_ + _유스 케이스_ + _리포지토리 인터페이스_

_**데이터 리포지토리 레이어**_ = _리포지토리 구현_ + _API(네트워크)_ + _영속성 DB_

<br>

### Example Project: "Movies App"

{{< figure src="image-5.webp" width="650px" align="center" >}}


#### Domain Layer

[예제 프로젝트](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)에서 [도메인 레이어](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/tree/master/ExampleMVVM/Domain)를 찾을 수 있습니다. 도메인 레이어는 [엔터티](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/tree/master/ExampleMVVM/Domain/Entities), 영화를 검색하고 검색에 성공한 최근 쿼리를 저장하는 _SearchMoviesUseCase_를 가집니다. 또한, **의존성 역전**&#8203;을 위해 필요한 _데이터 리포지토리 인터페이스_를 가집니다.

```swift
protocol SearchMoviesUseCase {
	func execute(requestValue: SearchMoviesUseCaseRequestValue,
    			 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {

	private let moviesRepository: MoviesRepository
    private let moviesQueriesRespository: MoviesQueriesRepository
    
    init(moviesRepository: MoviesRepository, moviesQueriesRepository: MoviesQueriesRepository) {
    	self.moviesRepository = moviesRepository
        self.moviesQueriesRepository = moviesQueriesRepository 
    }
    
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
    			 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
     	return moviesRepository.fetchMoviesList(query: requestValue, page: requestValue.page) { result in
        
        	if case .success = result {
            	self.moviesQueriesRepository.saveRecentQuery(query: requestValue.query) { _ in }
            }
            
            completion(result)
        
        }
	}

}

// Repository Interface
protocol MoviesRepository {
	func fetchMoviesList(query: MovieQuery, page: Int, completion: @escaping (Result<MoviePage, Error>) -> Void) -> Cancellable?
}

protocol MoviesQueriesRepository {
	func fetchRecentQueries(maxCount: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void)
    func saveRecentQuery(query: MovieQuery: completion: @escaping (Result<MovieQuery, Error>) -> Void)
    
}
```

**Note:** 유스 케이스를 생성하는 다른 방법으로 모든 유스 케이스 구현이 _start()_ 메서드가 포함되어 있는 [UseCase](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Domain/UseCases/Protocol/UseCase.swift) 프로토콜을 준수하게 합니다. 예제 프로젝트에서 [FetchRecentMovieQueriesUseCase](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Domain/UseCases/FetchRecentMovieQueriesUseCase.swift)가 이러한 접근법을 따르고 있습니다. 유스 케이스는 **상호작용자(interactor)**&#8203;라고도 불립니다.

**Note:** _유스 케이스_는 다른 _유스 케이스_를 의존할 수 있습니다.


#### Presentation Layer

[프리젠테이션 레이어](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/tree/master/ExampleMVVM/Presentation)는 _MoviesListViewModel_을 가지며, _MoviesListView_에서 관찰(observe)되는 항목(item)이 있습니다. _MoviesListViewModel_은 UIKit을 임포트하지 않습니다. 뷰-모델을 UIKit, SwiftUI나 WatchKit과 같은 UI 프레임워크로부터 거리를 두게 하는 건 재사용과 리팩토링을 쉽게 해줍니다. 예를 들어, 훗날 뷰를 UIKit에서 SwiftUI로 리팩토링을 하는 게 더 쉬워집니다. 왜냐하면 **뷰-모델**&#8203;을 바꿀 필요가 없기 때문입니다.

```swift
// Note: We canbit gave any UI frameworks(like UIKit or SwiftUI) imports here.

protocol MoviesListViewModelInput {
	func didSearch(query: String)
    func didSelect(at indexPath: IndexPath)
}

protocol MoviesListViewModelOutput {
	var items: Observable<[MoviesListItemViewModel]> { get }
    var error: Observable<String> { get }
}

protocol MoviesListViewModel: MoviesListViewModelInput, MoviesListViewModelOutput { }

struct MoviesListViewModelActions {
	// Note: if you would need to edit movie inside Details screen and update this
    // MoviesList screen with Updated movie then you would need this closure:
    // showMovieDetais: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
	let showMovieDetails: (Movie) -> Void
}

final class DefaultMoviesListViewModel: MoviesListViewModel {

	private let searchMoviesUseCase: SearchMoviesUseCase
    private let actions: MoviesListModelActions?
    
    private var movies: [Movie] = []
    
    // MARK: - INPUT
    let items: Observable<[MoviesListItemViewModel]> = Observable([])
    let error: Observable<String> = Observable("")
    
    init(searchMoviesUseCase: SearchMoviesUseCase,
    	 actions: MoviesListViewModelActions) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.actions = actions
    }
    
    private func load(movieQuery: MovieQuery) {
    
    	searchMoviesUseCase.execute(movieQuery: movieQuery) { result in
    		switch result {
            	case .success(let moviesPage):
                	// Note: We must map here from Domain Entities into Item View Models
                	self.items.value += moviesPage.movies.map(MoviesListItemViewModel.init)
                    self.movies += moviesPage.movies
                case .failure:
                	self.error.value = NSLocalizedString("Failed loading movies", comment: "")
            }
        }
    }
}

// MARK: - INPUT. View event methods
extension MoviesListViewModel {

    func didSearch(query: String) {
        laod(movieQuery: MovieQuery(query: query))
    }
    
    func didSelect(at indexPath: IndexPath) {
    	actions.showMovieDetails(movies[indexPath.row])
    }

}

// Note: This item view model is to display data and does not contain any domain model
struct MoviesListItemViewModel: Equatable {
	let title: String
}

extension MoviesListItemViewModel {
	init(movie: Movie) {
    	self.title = movie.title ?? ""
    }
}
```

**Note:** **뷰-모델**&#8203;을 쉽게 목킹([예제](https://github.com/kudoleh/iOS-Modular-Architecture/blob/master/DevPods/MoviesSearch/MoviesSearch/Tests/Presentation/MoviesScene/MoviesListViewTests.swift))하여 쉽게 _MoviesListViewController_를 테스트할 수 있도록 하기 위해 _MoviesListViewModelInput_과 _MoviesListViewModelOutput_ 인터페이스를 사용합니다. 또한, 다른 뷰를 보여주어야 할 때 [MoviesSearchFlowCoordinator](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Presentation/MoviesScene/Flows/MoviesSearchFlowCoordinator.swift)에게 이를 수행하라고 알려주는 _MoviesListViewModelActions_ 클로저를 가집니다. 액션 클로저가 호출되면 코디네이터(coordinator)는 영화 상세 화면을 보여줍니다. 추후 필요하다면 액션을 더 쉽게 추가하고자 구조체를 사용하여 액션을 묶습니다.

[프리젠테이션 레이어](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/tree/master/ExampleMVVM/Presentation)는 _MoviesListViewModel_의 데이터(항목)와 바인딩하는 _MoviesListViewController_도 가집니다. 

UI는 비즈니스 로직이나 애플리케이션 로직(비즈니스 모델과 유스 케이스)에 접근할 수 없으며, 오직 뷰-모델만이 가능합니다. 이것이 **관심사의 분리(separation of concerns)**&#8203;입니다. 비즈니스 모델을 곧바로 뷰(UI)로 전달할 수 없습니다. 이러한 이유로 뷰-모델 안에서 비즈니스 모델을 뷰-모델로 매핑하여 뷰에 전달합니다. 

영화 검색을 하기 위해 뷰에서 뷰-모델로 가는 검색 이벤트 호출을 추가합니다.

```swift
import UIKit

final class MoviesListViewController: UIViewController, StoryboardInstantiable, UISearchBarDelegate {

	private let viewModel: MoviesListViewModel!
    
    final class func create(with viewModel: MoviesListViewModel) -> MoviesListViewController {
    	let vc = MoviesListViewController.instantiateViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
    	super.viewDidLoad()
        
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: MoviesListViewModel) {
    	viewModel.items.observe(on: self) { [weak self] items in
        	self?.moviesTableViewController?.items = items
        }
        viewModel.error.observe(on: self) { [weak self] error in
        	self?.showError(error)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    	guard let searchText = searchBar.text, !searchText.isEmpty else { return }
    	viewModel.didSearch(query: searchText)
    }
}
```

**Note:** 항목을 관찰하고 변경될 때 뷰를 다시 로드합니다. 여기서는 간단한 [Observable](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Presentation/Utils/Observable.swift)을 사용하며, 아래 MVVM 섹션에서 자세히 설명합니다.


또한, 플로우 코디네이터에서 영화 상세 화면을 표시하고자 [MoviesSearchFlowCoordinator](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Presentation/MoviesScene/Flows/MoviesSearchFlowCoordinator.swift) 안에서 _showMovieDetails(movie:)_ 함수를 _MoviesListViewModel_의 액션에 할당합니다.

```swift
protocol MoviesSearchFlowCoordinatorDependencies {
	func makeMoviesListViewController() -> UIViewController
    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController 
}

final class MoviesSearchFlowCoordinator {

	private weak navigationController: UINavigationController?
    private let dependencies: MoviesSearchFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController,
    	 dependencies: MoviesSearchFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
    	// Note: here we keep strong reference with actions closures, this way this flow do not need to be strong referneced 
        let actions = MoviesListViewModelActions(showMovieDetails: showMovieDetails)
        let vc = dependencies.makeMoviesListViewController(actions: actions)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showMovieDetails(movie: Movie) {
    	let vc = dependencies.makeMoviesDetailsViewController(movie: movie)
        navigationController?.pushViewController(vc, animated: true)
    }
}
```

**Note:** 뷰 컨트롤러의 크기와 책임을 줄이고자 프리젠테이션 로직을 **플로우 코디네이터**&#8203;에서 처리합니다. **플로우 코디네이터**&#8203;를 (액션 클로저를 통해) **강하게 참조**하여 필요로 하는 동안 **플로우 코디네이터**&#8203;가 해제되지 않게 합니다.

이러한 접근법 덕분에 뷰-모델을 수정하지 않더라도 동일한 뷰-모델을 다양한 뷰에 쉽게 사용할 수 있습니다. iOS 13.0 이상 버전에서는 UIKit 대신 SwiftUI 뷰를 생성하여 동일한 뷰-모델에 바인딩하고, 그렇지 않으면 UIKit 뷰를 생성합니다. [예제 프로젝트](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)에서 _MoviesQueriesSuggestionsList_에 대한 SwiftUI 예제도 추가하였습니다. Xcode 11 베타 이상 버전이 요구됩니다.

```swift
// MARK: - Movies Queries Suggestions List
func makeMoviesQueriesSuggestionsListViewController(didSelect: @escaping MoviesQueryListViewModelDidSelectAction) -> UIViewController {
	if #available(iOS 13.0, *) { // SwiftUI
    	let view = MoviesQueryListView(viewModelWrapper: makeMoviesQueryListViewModelWrapper(didSelect: didSelect))
        return UIHostingController(rootView: view)
    } else { // UIKit
    	return MoviesQueriesTableViewController.create(with: makeMoviesQueryListViewModel(didSelect: didSelect))
    }
}
```

#### Data Layer

[데이터 레이어](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/tree/master/ExampleMVVM/Data)는 _DefaultMoviesRepository_를 가집니다. 이 리포지토리는 도메인 레이어 안에 정의되어 있는 인터페이스를 준수합니다 (**의존성 역전**&#8203;). 또한, JSON 데이터([디코더블 준수](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Data/Network/DataMapping/MoviesResponseDTO%2BMapping.swift))와 [코어 데이터 엔터티](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Data/PersistentStorages/MoviesResponseStorage/EntityMapping/MoviesResponseEntity%2BMapping.swift)를 도메인 모델로 매핑하는 작업도 추가할 수 있습니다.

```swift
final class DefualtMoviesRepository {

	private let dataTransferService: DataTransfer
    
    init(dataTransferService: DataTransfer) {
    	self.dataTransferService = dataTransferService
    }

}

extension DefaultMoviesRepository: MoviesRepository {

	public func fetchMoviesList(query: MovieQuery, page: Int, completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
    
    	let endpoint = APIEndpoints.getMovies(with: MoviesResponseDTO(query: query.query, 
        		  													  page: page))
        return dataTransferSerice.request(with: endpoint) { (response: Result<MoviesResponseDTO, Error>) in
            switch response {
            case .success(let moviesResponseDTO):
                completion(.success(moviesResponseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Data Transfer Object (DTO)
// It is used as intermediate to encode/decode JSON response into domain, inside DataTransferService
struct MoviesRequestDTO: Encodable {
	let query: String
    let page: Int
}

struct MoviesResponseDTO: Decodable {
	private enum CodingKeys: String, CodingKey {
    	case page
        case totalPages = "total_pages"
        case movies = "results"
    }
    let page: Int
    let totalPages: Int
    let movies: [MovieDTO]
}
...
// MARK: - Mappings to Domain

extension MoviesResponseDTO {
	func toDomain() -> MoviesPage {
    	return .init(page: pages,
        			 totalPages: totalPages,
                     movies: movies.map { $0.toDomain() } )
    }
}
...
```

**Note:** 데이터 전송 객체(DTO)는 JSON 응답을 도메인으로 매핑하는 중간 객체로 사용됩니다. 또한, 엔드 포인트(endpoint) 응답을 캐싱하고자 한다면, 데이터 전송 객체를 데이터베이스 객체(persistent object)로 매핑하여 영속성 저장소에 저장할 수 있습니다. (e.g. DTO → NSManagedObject)

일반적으로, 데이터 리포지토리에는 API 데이터 서비스와 영속 데이터 저장소가 주입될 수 있습니다. 데이터 리포지토리는 이러한 두 가지 의존성을 활용하여 데이터를 반환합니다. 먼저 영속성 저장소에 캐싱된 데이터 출력을 요청합니다 (_NSManagedObject_는 DTO 객체를 통해 도메인으로 매핑되며, _cached_ 데이터 클로저에서 처리됩니다). 그리고 최신 데이터를 반환하는 API 데이터 서비스를 호출합니다. 그 다음 영속 저장소는 최신 데이터로 업데이트됩니다 (DTO는 데이터베이스 객체로 매핑되어 저장됩니다). 마지막으로 DTO는 도메인으로 매핑되며, _updated data/completion_ 클로저에서 처리됩니다. 이러한 방법으로 사용자는 데이터를 즉시 볼 수 있습니다. 인터넷 연결이 없더라도, 사용자는 여전히 영속 저장소의 최신 데이터를 볼 수 있습니다. [예제](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Data/Repositories/DefaultMoviesRepository.swift)

저장소와 API는 전적으로 다른 구현으로 대체되어질 수 있습니다 (예를 들어, 코어 데이터에서 Realm으로). 앱의 나머지 모든 레이어는 이 변경에 영향을 받지 않습니다. DB가 세부 사항에 불과하기 때문입니다.

#### Infrastructure Layer (Network)

네트워크 프레임워크를 감싼 래퍼입니다. [Alamofire](https://github.com/Alamofire/Alamofire)(나 다른 프레임워크)가 될 수 있습니다. 네트워크 파라미터(예를 들어, 베이스URL)와 함께 구성되어질 수 있습니다. 또한, 엔드 포인트 정의와 (Decodable을 사용하여) 데이터 매핑 메서드를 지원합니다. 

```swift
struct APIEndpoints {

	static func getMovies(with movieReqeustDTO: MoviesRequestDTO) -> Endpoint<MoviesResponseDTO> {
    
    	return Endpoint(path: "search/movie/",
        				method: .get,
                        queryParametersEncodable: moviesRequestDTO)
    }
}

let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.apiBaseURL)!,
								  queryParameters: ["api_key": appConfigurations.apiKey])
let apiDataNetwork = DefaultNetworkService(session: URLSession.shard,
									       config: config)

let endpoint = APIEndpoints.getMovies(with: MovieRequestDTO(query: query.query,
															page: page))
dataTransferService.request(with: endpoint) { (response: Result<MoviesResponseDTO, Error>) in
	let moviesPage = try? response.get()
}
```

**Note:** 더 자세한 내용은 [https://github.com/kudoleh/SENetworking](https://github.com/kudoleh/SENetworking)를 참조하세요.

### MVVM

**모델-뷰-뷰모델** 패턴 (MVVM)은 UI와 도메인 간 명확한 관심사의 분리를 제공합니다. 

클린 아키텍처와 함께 사용한다면 프리젠테이션과 UI 레이어 간의 관심사를 분라하는 데 도움을 줄 수 있습니다.

서로 다른 뷰 구현은 동일한 뷰-모델과 함께 사용될 수 있습니다. 예를 들어, _CarsAroundListView_와 _CarsAroundMapView_ 모두 _CarsAroundViewModel_을 사용할 수 있습니다. 또한, 한 뷰는 UIKit으로 구현하고 다른 뷰는 SwiftUI로 구현할 수 있습니다. 뷰 모델 안에 UIKit, WatchKit과 SwiftUI를 임포트하지 않도록 하는 것이 중요합니다. 이렇게 하면 필요할 때 다른 플랫폼에서도 쉽게 재사용될 수 있습니다.

{{< figure src="image-6.webp" width="650px" align="center" >}}

**뷰**와 **뷰-모델** 간 **데이터 바인딩**&#8203;은 클로저, 델리게이트나 옵저버블(e.g RxSwift)로 처리될 수 있습니다. 최소 지원 iOS 시스템이 13이라면 Combine과 SwiftUI도 사용될 수 있습니다. **뷰**&#8203;는 **뷰-모델**&#8203;과 직접적인 관계를 가지며, 뷰 안에서 이벤트가 발생할 때 뷰-모델에게 알립니다. 뷰-모델은 뷰에 대한 직접적인 참조가 없고, 오직 데이터 바인딩만 합니다.

이 예제에서는 써드파티 의존을 피하고자 클로저와 _didSet_의 간단한 조합을 사용합니다.

```swift
public final class Observable<Value> {

	private var closure: ((Value) -> ())?
    
    public var value: Value {
    	didSet { closure?(value) } 
    }

	public init(_ value: Value) {
    	self.value = value
    }
    
    public func observe(_ closure: @escaping (Value) -> Void) {
    	self.closure = closure
        closure(value)
    }

}
```

**Note:** 정말 간단한 버전의 옵저버블입니다. 다양한 옵저버와 옵저버 제거를 포함한 전체 구현은 보려면 [Observable](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Presentation/Utils/Observable.swift)을 참조하세요. 

뷰 컨트롤러에서 데이터 바인딩을 하는 예제입니다.

```swift
final class ExampleViewController: UIViewController {

	private var viewModel: MoviesListViewModel!
    
    private func bind(to viewModel: MoviesListViewModel) {
    	self.viewModel = viewModel
        viewModel.items.observe(on: self) { [weak self] items in
        	self?.tableViewController?.items = itmes
            // Important: You cannot use viewModel inside this closure, it will cause retain cycle momory leak (viewModel.items.value not allowed)
            // self?.tableViewController.items = viewModel.items.value // This would be retain cycle. You can access viewModel only with self?.viewModel
        }
        // Or in one line
        viewModel.items.observe(on: self) { [weak self] in self?.tableViewController?.items = $0 }
    }
}
```

**Note:** 옵저빙 클로저에서 뷰-모델에 접근하는 건 순환 참조(메모리 누수)을 유발하기에 허용되지 않습니다. 오직 self 키워드(self?.viewModel)로 뷰-모델에 접근할 수 있습니다.

테이블 뷰 셀(재사용 가능한 셀)에서 데이터 바인딩을 하는 예제입니다.

```swift
final class MoviesListItemCell: UITableViewCell {
	
	private var viewModel: MoviesListItemViewModel! { didSet { unbind(from: oldValue) } }
    
    func fill(with viewModel: MoviesListItemViewModel) {
    	eslf.viewModel = viewModel
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: MoviesListItemViewModel) {
    	viewModel.posterImage.observe(on: self) { [weak self] in self?.imageView.image = $0.flatMap(UIImage.init) }
    }
    
    private func unbind(from item: MoviesListItemViewMdoel) {
    	item?.posterImage.remove(observer: self)
    }
}
```

**Note:** 뷰가 재사용되어야 한다면 꼭 바인딩 제거를 해주어야 합니다. (e.g. UITableViewCell)

**MVVM 템플릿**&#8203;은 [여기](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/tree/master/MVVM%20Templates)에서 찾을 수 있습니다.


### MVVMs Communication

#### Delegation

하나의 MVVM(화면)의 뷰-모델은 델리게이트 패턴을 사용하여 다른 MVVM(화면)의 다른 뷰-모델과 통신합니다. 

{{< figure src="image-7.webp" width="650px" align="center" >}}

예를 들어, _ItemsListViewModel_과 _ItemEditViewModel_이 있다고 가정해보겠습니다. 먼저 _ItemEditViewModelDidEditItem(item)_ 메서드가 있는 _ItemEditViewModelDelegate_ 프로토콜을 생성하세요. 그리고 _ItemsListViewModel_이 해당 프로토콜을 준수하게 하세요. 

```swift
// Step 1: Define delegate and add it to first ViewModel as weak property
protocol MoviesQueryListViewModelDelegate: AnyObject {
	func moviesQueriesListDidSelect(movieQuery: MovieQuery)
}
...
final class DefaultMoviesQueryListViewModel: MoviesListViewModel {
	private weak var delegate: MoviesQueryListViewModelDelgate?
    
    func didSelect(item: MoviesQueryListViewItemModel) {
    	// Note: We have to map here from View Item Model to Domain Entity
        delegate?.moviesQueriesListDidSelect(movieQuery: MovieQuery(query: item.query))
    }
}

// Step 2: Make second ViewModel to conform to this delegate
extension MoviesListViewModel: MoviesQueryListViewModelDelegate {
	func moviesQueriesListDidSelect(movieQuery: MovieQuery) {
    	update(movieQuery: movieQuery)
    }
}
```

**Note:** 이 케이스에서 프로토콜을 _Responder_로도 이름지을 수 있습니다. 

#### Closures

통신을 하는 다른 방법으로 플로우 코디네이터에 의해 주입되거나 할당된 클로저를 사용하는 것이 있습니다. 예제 프로젝트에서는 [MoviesListViewModel](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Presentation/MoviesScene/MoviesList/ViewModel/MoviesListViewModel.swift)이 _MoviesQueriesSuggestions_ 뷰를 보여주기 위해 어떤 방식으로_showMoviesQueriesSuggestions_ 액션 클로저를 사용하는지 볼 수 있습니다. 또한, *(_ didSelect: MovieQuery) -> Void* 매개변수를 넘겨주어 해당 뷰에서 다시 호출될 수 있도록 합니다. 통신은 [MoviesSearchFowCoordinator](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Presentation/MoviesScene/Flows/MoviesSearchFlowCoordinator.swift) 내에서 연결됩니다.

```swift
// MovieQueryList.swift

// Step 1: Define action closure to communicate to another ViewModel, e.g. here we not notify MovieList when query is selected
typealias MoviesQueryListViewModelDidSelectAction = (MovieQuery) -> Void

// Step 2: Call action closure when needed
class MoviesQueryListViewModel {
	init(didSelect: MoviesQueryListViewModelDidSelectAction? = nil) {
    	self.didSelect = didSelect
    }
    func didSelect(item: MovieQueryListItemViewModel) {
    	didSelect?(MovieQuery(query: item.query))
    }
}

// MoviesQueryList.swift

// Step 3: When presenting MoviesQueryListView we need to pass this action closure as parameter (_ didSelect: MovieQuery) -> Void
struct MoviesListViewModelActions {
	let showMovieQueriesSuggestions: (@escaping (_ didSelect: MovieQuery) -> Void) -> Void
}

class MoviesListViewModel {
	var actions: MoviesListViewModelActions?
    
    func showQueriesSuggestions() {
    	actions?.showMovieQueriesSuggestions { self.update(movieQuery: $0) }
    }
}

// FlowCoordinator.swift

// Step 4: Inside FlowCoordinator we connect communication of two viewModels, by injecting actions closures as self function
class MoviesSearchFlowCoordinator {
	func start() {
    	let actions = MoviesListViewModelActions(showMovieQueriesSuggestions: self.showMovieQueriesSuggestions)
        let vc = dependencies.makeMoviesListViewController(actions: actions)
        present(vc)
    }
    
    private func showMovieQueriesSuggestions(didSelect: @escaping (MovieQuery) -> Void) {
    	let vc = dependencies.makeMoviesQueriesSuggestionsListViewController(didSelect: didSelect)
		present(vc)
	}
}
```


### Layer Separation into frameworks(Modules)

이제 예제 프로젝트의 각 레이어(도메인, 프리젠테이션, UI, 데이터, 네트워크)는 개별 프레임워크로 쉽게 나누어질 수 있습니다.

```
_New Project_ → _Create Project..._ → Cocoa Touch Framework
```

 그리고 _CocoaPod_을 사용하여 해당 프레임워크를 메인 앱에 포함시킬 수 있습니다. 이러한 작업 예제를 보려면 [여기](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/MVVM%20Modular%20Layers%20Pods.zip)를 참조하세요. **Note:** 권한 문제로 인해 **ExampleMVVM.xcworkspace**&#8203;를 삭제하고, **pod install** 명령어를 실행하여 새로운 워크스페이스를 만들어야 합니다.
 
{{< figure src="image-8.png" width="650px" align="center" >}}

### Dependency Injection Container

**의존성 주입**&#8203;은 한 객체가 다른 객체의 의존성을 지원하는 기술입니다. 애플리케이션의 [DIContainer](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Application/DIContainer/AppDIContainer.swift)는 모든 주입의 중심 단위입니다. 

#### Using dependencies factory protocols

옵션 중 하나로 [DIContainer](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Application/DIContainer/MoviesSceneDIContainer.swift)에 의존성 생성을 위임하는 의존성 프로토콜을 선언하는 것입니다. 이것을 하려면 _MoviesSearchFlowCoordinatorDependencies_ 프로토콜을 정의하고, _MoviesSceneDIContainer_가 해당 프로토콜을 준수하게 합니다. 그리고 해당 DIContainer를 _MoviesSearchFlowCoordinator_에 주입하여 _MoviesListViewController_를 생성하고 보여주게 합니다. 

```swift
// Define Dependencies protocol for class or structure that needs it
protocol MoviesSearchFlowCoordinatorDependencies {
	func makeMoviesListViewController() -> MoviesListViewController
}

class MoviesSearchFlowCoordinator {

	private let dependencies: MoviesSearchFlowCoordinatorDependencies
    
    init(dependencies: MoviesSearchFlowCoordinatorDependencies) {
    	self.dependencies = dependencies
    }
...
}

// Make the DIContainer ot conform to this protocol
extension MoviesSceneDIContainer: MoviesSearchFlowCoordinatorDependencies { }

// And inject MoviesSceneDIContainer `self` into class that needs it
final class MoviesSceneDIContainer{
	...
    // MARK: - Flow Coordinators
    func makeMoviesSearchFlowCoordinator(navigationController: UINavigationController) {
    	return MoviesSearchFlowCoordinator(navigationController: navigagtionController,
        								   dependencies: dependencies)
    }
}
```

#### Using closures

다른 옵션으로 클로저를 사용하는 방법이 있습니다. 클래스에 주입을 필요로 하는 클로저를 선언하세요. 그리고 이 클로저를 _MoviesSearchFlowCoordinator_에 주입하세요.

```swift
// Define makeMoviesListViewController closure that returns MoviesListViewController
class MoviesSearchFlowCoordinator {

	private var makeMoviesListViewController: () -> MoviesListViewController
    
    init(navigationController: UINavigationController,
    	 makeMoviesListViewController: @escaping () -> MoviesListViewController) }
    	...
        self.makeMoviesListViewController = makeMoviesListViewController
	}
	...
}

// And inject MoviesSceneDIContainer's `self`.makeMoviesListViewController function into class that needs it
final class MoviesSceneDIContainer {
	...
    // NARK: - Flow Coordinators
    func makeMoviesSearchFlowCoordinator(navigationController: UINavigationController) {
    	return MoviesSearchFlowCoordinator(navigationController: navigationController,
        								   makeMoviesListViewController: self.makeMoviesListViewController)
    }
    
    // MARK: - Movies List
    func makeMoviesListViewController() -> MoviesListViewController {
    	...
    }
}
```

### Source code

[kudoleh/iOS-Clean-Architecture-MVVM](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM?source=post_page-----c9d167d9f5b3--------------------------------)

### Companies with many iOS Engineers

_Clean Architecture + MVVM_ is successfully used at [fintech company Revolut with >70 iOS engineers.](https://medium.com/revolut/the-fundamentals-of-ios-at-revolut-57422078c903)


### Resources

[Advanced iOS App Architecture](https://www.kodeco.com/books/advanced-ios-app-architecture)

[The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

[The Clean Code](https://www.amazon.de/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)


### Conclusion

모바일 개발에서 가장 많이 사용되는 아키텍처 패턴은 **클린 아키텍처, MVVM과 리덕스**&#8203;입니다. 

MVVM과 클린 아키텍처는 당연히 개별적으로 사용될 수 있습니다. 다만, MVVM은 오직 프리젠테이션 레이어에서만 관심사의 분리를 제공하는 반면에, 클린 아키텍처는 쉽게 **테스트**&#8203;와 **재사용**&#8203;을 하고, **이해할 수** 있게 코드를 모듈 레이어로 쪼갭니다. 

유스 케이스가 리포지토리를 호출하는 것 외에 다른 작업을 하지 않더라도, 유스 케이스 생성을 소홀히 하지 않는 게 중요합니다. 이렇게 하면, 새로운 개발자가 유스 케이스를 볼 때 아키텍처를 쉽게 이해할 수 있습니다. 

클린 아키텍처가 시작점으로는 유용할 수 있지만, 시원한 해결책(silver bullet)이 될 수는 없습니다. 프로젝트에서 개발자의 요구 사항을 충족시켜주는 아키텍처를 선택해야 합니다.

클린 아키텍처는 테스트 주도 개발(TDD)과 정말 잘 어울립니다. 이 아키텍처는 프로젝트를 더 테스트하기 쉽게 만들고, 레이어는 쉽게 교체될 수 있습니다 (UI와 데이터).

[도메인 주도 디자인](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)(DDD)도 마찬가지로 [클린 아키텍처](https://blog.cleancoder.com/uncle-bob/2011/11/22/Clean-Architecture.html)와 잘 어울립니다.

소프트웨어 개발에서 알아두면 좋을 다양한 아키텍처 패턴이 있습니다. [The 5 Patterns You Need to Know](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3)

**더 많은 엔지니어링 모범 사례:**

* 테스트없이 코드를 작성하지 마세요. (TDD를 시도하세요)

* 지속적으로 리팩토링을 하세요.

* 과도한 엔지니어링을 피하고, 실용적으로 바라보세요.

* 가능한 한 프로젝트에서 써드파티 프레임워크 의존성 사용을 피하세요.



### More on Mobile Archtiecture topic

#### [Modular Architecture](https://tech.olx.com/modular-architecture-in-ios-c1a1e3bff8e9)

어떻게 앱을 완전히 격리된 모듈로 분리하여 프로젝트를 개선할 수 있을까요 (e.g. **네트워크 서비스, 트랙킹 서비스, 채팅 기능, 지불 기능...**&#8203;)? 그리고 어떻게 모든 팀이 이러한 모듈과 함께 신속하고 독립적으로 작업할 수 있을까요🤔?

모듈 아키텍처에 대한 자세한 정보는 [modularation of the app](https://tech.olx.com/modular-architecture-in-ios-c1a1e3bff8e9)을 참조해주세요.












