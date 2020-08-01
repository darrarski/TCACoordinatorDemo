import ComposableArchitecture
import SwiftUI

struct ConfirmPinState: Equatable, NavigationItem {
  let navigationID = UUID()
  var pinConfirmation: String = ""
}

enum ConfirmPinAction: Equatable {
  case didChangePinConfirmation(String)
  case next
}

struct ConfirmPinEnvironment {
  let navigation: (NavigationAction) -> Void
}

let confirmPinReducer = Reducer<ConfirmPinState, ConfirmPinAction, ConfirmPinEnvironment>.combine(
  Reducer { state, action, env in
    switch action {
    case .didChangePinConfirmation(let pinConfirmation):
      state.pinConfirmation = pinConfirmation
      return .none

    case .next:
      env.navigation(.set([SelectCityState()]))
      return .none
    }
  },
  Reducer { state, action, env in
    env.navigation(.update(state))
    return .none
  }
)

struct ConfirmPinViewState: Equatable {
  let pinConfirmation: String

  init(state: ConfirmPinState) {
    pinConfirmation = state.pinConfirmation
  }
}

struct ConfirmPinView: View {
  let store: Store<ConfirmPinState, ConfirmPinAction>

  var body: some View {
    WithViewStore(store.scope(state: ConfirmPinViewState.init(state:))) { viewStore in
      Form {
        TextField("Confirm PIN", text: viewStore.binding(
          get: \.pinConfirmation,
          send: ConfirmPinAction.didChangePinConfirmation
        ))
        Button(action: { viewStore.send(.next) }) {
          HStack {
            Spacer()
            Text("Next")
            Spacer()
          }
        }
      }.navigationBarTitle("ConfirmPin", displayMode: .inline)
    }
  }
}
