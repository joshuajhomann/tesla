import Combine
import SwiftUI
import TeslaOwnerAPI

public final class VehicleViewModel: ObservableObject {
  typealias LoadingState = CollectionLoadingState<[VehiclesResponse.Vehicle], TeslaOwnerAPI.Error>
  @Published private(set) var loadingState: LoadingState = .loading(placeholder: [])
  private var loadSubject = PassthroughSubject<Void, Never>()
  init(teslaOwnerAPI: TeslaOwnerAPI) {
    teslaOwnerAPI
      .getVehicles()
      .map(LoadingState.loaded(content:))
      .catch { error in Just<LoadingState>(.error(error)) }
      .receive(on: DispatchQueue.main)
      .assign(to: &$loadingState)
  }
  func load() {
    loadSubject.send()
  }
}

public struct VehicleView: View {
  @ObservedObject var viewModel: VehicleViewModel
  @EnvironmentObject private var viewModelFactory: ViewModelFactory
  @ViewBuilder public var body: some View {
    switch viewModel.loadingState {
    case.loading:
      ProgressView()
    case let .loaded(vehicles):
      TabView {
        ForEach(vehicles) { vehicle in
            ScrollView {
              VehicleDetailView(viewModel: viewModelFactory.makeVehicleDetailViewModel(vehicle: vehicle))
            }
          }
        }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    case let .error(error):
      Text(error.message)
        .padding()
    case .empty:
      Text("You have no vehicles for this account")
    }
  }
  public init(viewModel: VehicleViewModel) {
    self.viewModel = viewModel
  }
}
