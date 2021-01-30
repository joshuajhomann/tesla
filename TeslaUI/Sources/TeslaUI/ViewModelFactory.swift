//
//  ViewModelFactory.swift
//  
//
//  Created by Joshua Homann on 1/17/21.
//

import Combine
import TeslaOwnerAPI

public final class ViewModelFactory: ObservableObject {
  private let teslaOwnerAPI: TeslaOwnerAPI

  public init(teslaOwnerAPI: TeslaOwnerAPI) {
    self.teslaOwnerAPI = teslaOwnerAPI
  }

  public func makeLoginViewModel() -> LoginViewModel {
    .init(teslaOwnerAPI: teslaOwnerAPI)
  }

  public func makeVehicleViewModel() -> VehicleViewModel {
    .init(teslaOwnerAPI: teslaOwnerAPI)
  }

  public func makeVehicleDetailViewModel(vehicle: VehiclesResponse.Vehicle) -> VehicleDetailViewModel {
    .init(vehicle: vehicle, teslaOwnerAPI: teslaOwnerAPI)
  }
}
