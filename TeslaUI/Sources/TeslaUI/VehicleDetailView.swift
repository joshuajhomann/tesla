//
//  File.swift
//  
//
//  Created by Joshua Homann on 1/23/21.
//

import Combine
import SwiftUI
import TeslaOwnerAPI

public final class VehicleDetailViewModel: ObservableObject {
  typealias LoadingState = TeslaUI.LoadingState<VehicleDataContainer.Response, TeslaOwnerAPI.Error>
  @Published private(set) var loadingState: LoadingState = .loading
  @Published private(set) var isLocked = true
  private let refreshSubject = PassthroughSubject<Void, Never>()
  private let vehicle: VehiclesResponse.Vehicle
  private let teslaOwnerAPI: TeslaOwnerAPI
  let reload: () -> Void
  init(vehicle: VehiclesResponse.Vehicle, teslaOwnerAPI: TeslaOwnerAPI) {
    self.vehicle = vehicle
    self.teslaOwnerAPI = teslaOwnerAPI
    reload = refreshSubject.send
    refreshSubject
      .map { _ -> AnyPublisher<LoadingState, Never> in
        let fetch = vehicle.state == "unavailable"
          ? teslaOwnerAPI
            .execute(command: .wake, for: vehicle.id)
            .map { _ in teslaOwnerAPI.getVehicle(id: vehicle.id) }
            .switchToLatest()
            .eraseToAnyPublisher()
          : teslaOwnerAPI
            .getVehicle(id: vehicle.id)
            .eraseToAnyPublisher()
        return fetch
          .map(LoadingState.loaded(content:))
          .catch { error in Just<LoadingState>(.error(error)) }
          .prepend(.loading)
          .eraseToAnyPublisher()
      }
      .switchToLatest()
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveOutput: { [weak self] loadingState in
        guard let self = self, let locked = loadingState.content?.vehicleState.locked else { return }
        self.isLocked = locked
      })
      .assign(to: &$loadingState)

  }
  private func execute(command: TeslaOwnerAPI.Command, defaultValue: Bool) -> AnyPublisher<Void, Never> {
    return teslaOwnerAPI
      .execute(command: command, for: vehicle.id)
      .map { _ in () }
      .replaceError(with: ())
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  func toggleLock() -> AnyPublisher<Void, Never> {
    guard let vehicleState = loadingState.content?.vehicleState else {
      return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    return teslaOwnerAPI
      .execute(command: vehicleState.locked ? .unlock : .lock, for: vehicle.id)
      .map { _ in () }
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveOutput: { [weak self] _ in
        self?.isLocked.toggle()
      })
      .replaceError(with: ())
      .eraseToAnyPublisher()
  }
  func flash() -> AnyPublisher<Void, Never> {
    execute(command: .flash, defaultValue: true)
  }
  func honk() -> AnyPublisher<Void, Never> {
    execute(command: .flash, defaultValue: true)
  }
  func trunk() -> AnyPublisher<Void, Never> {
    execute(command: .trunk, defaultValue: true)
  }
  func frunk() -> AnyPublisher<Void, Never> {
    execute(command: .frunk, defaultValue: true)
  }
}

public struct VehicleDetailView: View {
  public typealias ViewModel = VehicleDetailViewModel
  @ObservedObject var viewModel: ViewModel
  @State private var showDetail = false
  @ViewBuilder public var body: some View {
    switch viewModel.loadingState {
    case .loading:
      ProgressView("Loading...")
        .onAppear { viewModel.reload() }
    case let .loaded(vehicle):
      VStack(alignment: .center) {
        NavigationLink(
          destination: viewModel.loadingState.content.map { AnyView(VehicleInfoView(state: $0)) } ?? AnyView(EmptyView()),
          isActive: $showDetail,
          label: {
            Label { Text("Name: ").bold() + Text(vehicle.displayName ?? "Unnamed") } icon: {
              Image(systemName: "info.circle")
            }
          })
        Text("State: ").font(.caption).bold() + Text(vehicle.state).font(.caption)
        CommandButton { viewModel.toggleLock() } title: {
          if viewModel.isLocked {
            Label("Lock", systemImage: "lock")
          } else {
            Label("Unlock", systemImage: "lock.open")
          }
        }
        CommandButton { viewModel.frunk() } title: {
          Label("Frunk", systemImage: "arrowshape.turn.up.backward")
        }
        CommandButton { viewModel.trunk() } title: {
          Label("Trunk", systemImage: "arrowshape.turn.up.left.2")
        }
        CommandButton { viewModel.honk() } title: {
          Label("Honk", systemImage: "speaker.wave.2.circle")
        }
        CommandButton { viewModel.flash() } title: {
          Label("Flash", systemImage: "sun.min")
        }
        Button { viewModel.reload() } label: {
          Label("Reload", systemImage: "arrow.triangle.2.circlepath")
        }
      }
      .padding()
    case let .error(error):
      VStack {
        Text(error.message)
        Button("Retry") {
          viewModel.reload()
        }
      }
    }
  }
  public init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }
}
