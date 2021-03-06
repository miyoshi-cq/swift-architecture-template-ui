import Combine
import OrderedCollections
import UIKit
import Utility

public final class ListViewModel<T, Parameter>: ViewModel where T: Hashable {
    public typealias Items = OrderedDictionary<String, [T]>

    public let loadSubject: PassthroughSubject<(parameter: Parameter?, isAdditional: Bool), Never> =
        .init()
    public let loadingState: CurrentValueSubject<LoadingState<Items, AppError>, Never> =
        .init(.standby)

    private let fetchPublisher: ((parameter: Parameter?, isAdditional: Bool))
        -> AnyPublisher<Items, AppError>

    public init(
        fetchPublisher: @escaping ((parameter: Parameter?, isAdditional: Bool))
            -> AnyPublisher<Items, AppError>
    ) {
        self.fetchPublisher = fetchPublisher
    }

    public func bind() -> AnyCancellable {
        self.loadSubject
            .filter { _ in
                if case .loading = self.loadingState.value {
                    return false
                } else {
                    return true
                }
            }
            .handleEvents(receiveOutput: { _ in
                self.loadingState.send(.loading(self.loadingState.value.value))
            })
            .flatMap { [weak self] query -> AnyPublisher<LoadingState<Items, AppError>, Never> in

                guard let self = self else {
                    return Just(LoadingState<Items, AppError>.failed(.unknown))
                        .eraseToAnyPublisher()
                }

                return self.fetchPublisher(query)
                    .map { new in
                        let current = self.loadingState.value.value ?? [:]

                        guard new.isEmpty == false else {
                            return LoadingState<Items, AppError>.standby
                        }

                        if query.isAdditional {
                            let result = current.merging(new, uniquingKeysWith: +)
                            return LoadingState<Items, AppError>.done(result)
                        } else {
                            return LoadingState<Items, AppError>.done(new)
                        }
                    }
                    .catch { error in
                        Just(LoadingState<Items, AppError>.failed(error))
                    }
                    .eraseToAnyPublisher()
            }
            .subscribe(self.loadingState)
    }
}
