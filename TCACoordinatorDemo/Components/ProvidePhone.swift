import ComposableArchitecture
import SwiftUI

struct ProvidePhoneState: Equatable, NavigationItem {
  let navigationID = UUID()
  let navigationTitle = "ProvidePhoneNumber"
  var phone: String = ""
}

enum ProvidePhoneAction: Equatable {
  case didChangePhone(String)
  case next
}

struct ProvidePhoneEnvironment {
  let navigation: (NavigationAction) -> Void
}

let providePhoneReducer = Reducer<ProvidePhoneState, ProvidePhoneAction, ProvidePhoneEnvironment>.combine(
  Reducer { state, action, env in
    switch action {
    case .didChangePhone(let phone):
      state.phone = phone
      return .none

    case .next:
      env.navigation(.set([SetPinState()]))
      return .none
    }
  },
  Reducer { state, action, env in
    env.navigation(.update(state))
    return .none
  }
)

struct ProvidePhoneViewState: Equatable {
  let phone: String

  init(state: ProvidePhoneState) {
    phone = state.phone
  }
}

struct ProvidePhoneView: View {
  let store: Store<ProvidePhoneState, ProvidePhoneAction>
  
  var body: some View {
    WithViewStore(store.scope(state: ProvidePhoneViewState.init(state:))) { viewStore in
      Form {
        TextField("Phone", text: viewStore.binding(
          get: \.phone,
          send: ProvidePhoneAction.didChangePhone
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
