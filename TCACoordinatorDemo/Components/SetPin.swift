import ComposableArchitecture
import SwiftUI

struct SetPinState: Equatable, NavigationItem {
  let navigationID = UUID()
  let navigationTitle = "SetPin"
  var pin: String = ""
}

enum SetPinAction: Equatable {
  case didChangePin(String)
  case next
}

struct SetPinEnvironment {
  let navigation: (NavigationAction) -> Void
}

let setPinReducer = Reducer<SetPinState, SetPinAction, SetPinEnvironment>.combine(
  Reducer { state, action, env in
    switch action {
    case .didChangePin(let pin):
      state.pin = pin
      return .none

    case .next:
      env.navigation(.push(ConfirmPinState()))
      return .none
    }
  },
  Reducer { state, action, env in
    env.navigation(.update(state))
    return .none
  }
)

struct SetPinViewState: Equatable {
  let pin: String

  init(state: SetPinState) {
    pin = state.pin
  }
}

struct SetPinView: View {
  let store: Store<SetPinState, SetPinAction>
  
  var body: some View {
    WithViewStore(store.scope(state: SetPinViewState.init(state:))) { viewStore in
      Form {
        TextField("PIN", text: viewStore.binding(
          get: \.pin,
          send: SetPinAction.didChangePin
        ))
        Button(action: { viewStore.send(.next) }) {
          HStack {
            Spacer()
            Text("Next")
            Spacer()
          }
        }
      }
    }
  }
}
