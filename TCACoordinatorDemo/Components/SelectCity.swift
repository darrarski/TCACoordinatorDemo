import ComposableArchitecture
import SwiftUI

struct SelectCityState: Equatable, NavigationItem {
  let navigationID = UUID()
  var city: String = ""
}

enum SelectCityAction: Equatable {
  case didChangeCity(String)
  case next
}

struct SelectCityEnvironment {
  let navigation: (NavigationAction) -> Void
}

let selectCityReducer = Reducer<SelectCityState, SelectCityAction, SelectCityEnvironment>.combine(
  Reducer { state, action, env in
    switch action {
    case .didChangeCity(let city):
      state.city = city
      return .none

    case .next:
      env.navigation(.set([TicketsMainState()]))
      return .none
    }
  },
  Reducer { state, action, env in
    env.navigation(.update(state))
    return .none
  }
)

struct SelectCityViewState: Equatable {
  let city: String

  init(state: SelectCityState) {
    city = state.city
  }
}

struct SelectCityView: View {
  let store: Store<SelectCityState, SelectCityAction>
  
  var body: some View {
    WithViewStore(store.scope(state: SelectCityViewState.init(state:))) { viewStore in
      Form {
        TextField("City", text: viewStore.binding(
          get: \.city,
          send: SelectCityAction.didChangeCity
        ))
        Button(action: { viewStore.send(.next) }) {
          HStack {
            Spacer()
            Text("Next")
            Spacer()
          }
        }
      }.navigationBarTitle("SelectCity", displayMode: .inline)
    }
  }
}
