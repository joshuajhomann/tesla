//
//  File.swift
//  
//
//  Created by Joshua Homann on 1/24/21.
//

import Combine
import MapKit
import SwiftUI
import TeslaOwnerAPI


struct VehicleInfoView: View {
  var state: VehicleDataContainer.Response
  @ViewBuilder var body: some View {
    Text(state.vehicleState.carVersion)
    Text(state.vehicleState.autoparkStateV3)
    Text("User present: \(String(describing: state.vehicleState.isUserPresent))")
    Text("Odometer: \(Int(state.vehicleState.odometer))")
  }
}
