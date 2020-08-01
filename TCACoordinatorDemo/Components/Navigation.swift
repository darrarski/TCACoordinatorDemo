import ComposableArchitecture
import SwiftUI
import UIKit

struct NavigationState {
  var items: [NavigationItem]
}

protocol NavigationItem {
  var navigationID: UUID { get }
}

enum NavigationAction {
  case update(NavigationItem)
  case set([NavigationItem])
  case push(NavigationItem)
  case pop
  case popToRoot
}

typealias NavigationReducer = Reducer<NavigationState, NavigationAction, Void>

let navigationReducer = NavigationReducer { state, action, _ in
  switch action {
  case .update(let item):
    state.items = state.items.map { $0.navigationID == item.navigationID ? item : $0 }
    return .none

  case .set(let items):
    state.items = items
    return .none

  case .push(let item):
    state.items.append(item)
    return .none

  case .pop:
    state.items.removeLast()
    return .none

  case .popToRoot:
    state.items = [state.items.first].compactMap { $0 }
    return .none
  }
}

typealias NavigationStore = Store<NavigationState, NavigationAction>
typealias NavigationViewStore = ViewStore<NavigationState, NavigationAction>
typealias NavigationDispatcher = (NavigationAction) -> Void
typealias NavigationItemViewFactory = (NavigationItem, @escaping NavigationDispatcher) -> AnyView

final class NavigationItemViewController: UIHostingController<AnyView> {
  var item: NavigationItem { didSet { rootView = viewFactory(item, navigationDispatcher) } }
  let viewFactory: NavigationItemViewFactory
  let navigationDispatcher: NavigationDispatcher

  init(
    item: NavigationItem,
    viewFactory: @escaping NavigationItemViewFactory,
    navigationDispatcher: @escaping NavigationDispatcher
  ) {
    self.item = item
    self.viewFactory = viewFactory
    self.navigationDispatcher = navigationDispatcher
    super.init(rootView: viewFactory(item, navigationDispatcher))
  }

  required init?(coder aDecoder: NSCoder) {
    nil
  }
}

final class NavigationController: UINavigationController {
  var itemViewControllers: [NavigationItemViewController] {
    get { viewControllers.compactMap { $0 as? NavigationItemViewController } }
    set { viewControllers = newValue }
  }
}

struct NavigationControllerView: UIViewControllerRepresentable {
  let store: NavigationStore
  let viewFactory: NavigationItemViewFactory
  @ObservedObject var viewStore: NavigationViewStore

  init(
    store: NavigationStore,
    viewFactory: @escaping NavigationItemViewFactory
  ) {
    self.store = store
    self.viewFactory = viewFactory
    self.viewStore = NavigationViewStore(store, removeDuplicates: {
      $0.items.map(\.navigationID) == $1.items.map(\.navigationID)
    })
  }

  func makeUIViewController(context: Context) -> NavigationController {
    let navigationController = NavigationController()
    navigationController.delegate = context.coordinator
    return navigationController
  }

  func updateUIViewController(_ navigationController: NavigationController, context: Context) {
    let navigationIDs = viewStore.items.map(\.navigationID)
    let presentedViewControllers = navigationController.itemViewControllers
    let presentedNavigationIDs = presentedViewControllers.map(\.item.navigationID)
    guard presentedNavigationIDs != navigationIDs else { return }
    let newViewControllers = viewStore.items.map { item -> NavigationItemViewController in
      let viewController = presentedViewControllers.first(where: { $0.item.navigationID == item.navigationID })
      viewController?.item = item
      return viewController ?? NavigationItemViewController(
        item: item,
        viewFactory: viewFactory,
        navigationDispatcher: viewStore.send(_:)
      )
    }
    let animate = !navigationController.viewControllers.isEmpty
    navigationController.setViewControllers(newViewControllers, animated: animate)
  }

  func makeCoordinator() -> NavigationControllerCoordinator {
    NavigationControllerCoordinator(view: self)
  }
}

final class NavigationControllerCoordinator: NSObject, UINavigationControllerDelegate {
  let view: NavigationControllerView

  init(view: NavigationControllerView) {
    self.view = view
    super.init()
  }

  func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    guard let navigationController = navigationController as? NavigationController else { return }
    let presentedViewControllers = navigationController.itemViewControllers
    let presentedNavigationItems = presentedViewControllers.map(\.item)
    let presentedNavigationIDs = presentedNavigationItems.map(\.navigationID)
    let navigationIDs = view.viewStore.items.map(\.navigationID)
    guard presentedNavigationIDs != navigationIDs else { return }
    view.viewStore.send(.set(presentedNavigationItems))
  }
}
