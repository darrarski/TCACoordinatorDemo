import ComposableArchitecture
import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = UIHostingController(
      rootView: NavigationControllerView(
        store: NavigationStore(
          initialState: NavigationState(
            items: [ProvidePhoneState()]
          ),
          reducer: navigationReducer.debug(),
          environment: ()
        ),
        viewFactory: { item, navigationDispatcher in
          switch item {
          case let item as TicketsMainState:
            return AnyView(TicketsMainView(
              store: Store(
                initialState: item,
                reducer: ticketsMainReducer,
                environment: TicketsMainEnvironment(
                  navigation: navigationDispatcher
                )
              )
            ))

          case let item as ProvidePhoneState:
            return AnyView(ProvidePhoneView(
              store: Store(
                initialState: item,
                reducer: providePhoneReducer,
                environment: ProvidePhoneEnvironment(
                  navigation: navigationDispatcher
                )
              )
            ))

          case let item as SetPinState:
            return AnyView(SetPinView(
              store: Store(
                initialState: item,
                reducer: setPinReducer,
                environment: SetPinEnvironment(
                  navigation: navigationDispatcher
                )
              )
            ))

          case let item as ConfirmPinState:
            return AnyView(ConfirmPinView(
              store: Store(
                initialState: item,
                reducer: confirmPinReducer,
                environment: ConfirmPinEnvironment(
                  navigation: navigationDispatcher
                )
              )
            ))

          case let item as SelectCityState:
            return AnyView(SelectCityView(
              store: Store(
                initialState: item,
                reducer: selectCityReducer,
                environment: SelectCityEnvironment(
                  navigation: navigationDispatcher
                )
              )
            ))

          default:
            fatalError("Unexpected navigation item: \(item)")
          }
      }
      ).edgesIgnoringSafeArea(.all)
    )
    window?.makeKeyAndVisible()
  }
}
