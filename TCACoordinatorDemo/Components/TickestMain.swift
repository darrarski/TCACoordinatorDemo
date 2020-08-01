import ComposableArchitecture
import SwiftUI

struct TicketsMainState: Equatable, NavigationItem {
  let navigationID = UUID()
}

enum TicketsMainAction: Equatable {
  case dummy
}

struct TicketsMainEnvironment {
  let navigation: (NavigationAction) -> Void
}

let ticketsMainReducer = Reducer<TicketsMainState, TicketsMainAction, TicketsMainEnvironment>.combine(
  Reducer { state, action, env in
    switch action {
    case .dummy:
      return .none
    }
  },
  Reducer { state, action, env in
    env.navigation(.update(state))
    return .none
  }
)

struct TicketsMainViewState: Equatable {
  init(state: TicketsMainState) {}
}

struct TicketsMainView: View {
  let store: Store<TicketsMainState, TicketsMainAction>
  
  var body: some View {
    WithViewStore(store.scope(state: TicketsMainViewState.init(state:))) { viewStore in
      Form {
        EmptyView()
      }.navigationBarTitle("TicketsMainView", displayMode: .inline)
    }
  }
}
