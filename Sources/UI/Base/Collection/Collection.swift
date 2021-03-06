import Combine
import OrderedCollections
import UIKit
import Utility

public protocol CollectionList: List {
    associatedtype Cell: CollectionLayout
    associatedtype Header: CollectionHeaderLayout
    associatedtype Footer: CollectionFooterLayout
    associatedtype Parameter

    typealias Items = OrderedDictionary<String, [Cell.ViewData]>

    var screenTitle: String { get }
    var hideTabbar: Bool { get }
    var composableLayout: UICollectionViewCompositionalLayout { get }
    var topViewSubject: PassthroughSubject<Parameter, Never> { get }
    var fetchPublisher: ((parameter: Parameter?, isAdditional: Bool))
        -> AnyPublisher<Items, AppError> { get }

    var floatingButton: UIButton? { get }
}

public extension CollectionList {
    var floatingButton: UIButton? { nil }
    var hideTabbar: Bool { false }
    var topViewSubject: PassthroughSubject<String, Never> { .init() }
}

public protocol CollectionLayout: UICollectionViewCell {
    associatedtype ViewData: Hashable
    var viewData: ViewData? { get set }
}

public protocol CollectionHeaderLayout: UICollectionReusableView {
    func updateHeader(text: String)
}

public protocol CollectionFooterLayout: UICollectionReusableView {}
