//
//  ContentView.swift
//  Tesla WatchKit Extension
//
//  Created by Joshua Homann on 1/15/21.
//

import SwiftUI
import TeslaUI

struct ContentView: View {
  @StateObject var viewModelFactory = ViewModelFactory(teslaOwnerAPI: .init())
  var body: some View {
    NavigationView {
      LoginView(viewModel: viewModelFactory.makeLoginViewModel())
        .environmentObject(viewModelFactory)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
