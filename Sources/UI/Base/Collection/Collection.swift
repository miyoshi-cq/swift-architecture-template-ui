import Combine
import OrderedCollections
import UIKit
import Utility

public protocol CollectionList: List {
    associatedtype Cell: CollectionLayout
    associatedtype Header: CollectionHeaderLayout
    associatedtype Parameter

    typealias Items = OrderedDictionary<String, [Cell.ViewData]>

    var screenTitle: String { get }
    var backGroundColor: UIColor { get }
    var composableLayout: UICollectionViewCompositionalLayout { get }
    var topViewSubject: PassthroughSubject<Parameter, Never> { get }
    var fetchPublisher: ((parameter: Parameter?, isAdditional: Bool))
        -> AnyPublisher<Items, AppError> { get }
}

public extension CollectionList {
    var backGroundColor: UIColor { UIColor.rgba(244, 244, 244, 1) }
}

public protocol CollectionLayout: UICollectionViewCell {
    associatedtype ViewData: Hashable
    var viewData: ViewData? { get set }
}

public protocol CollectionHeaderLayout: UICollectionReusableView {
    func updateHeader(text: String)
}
