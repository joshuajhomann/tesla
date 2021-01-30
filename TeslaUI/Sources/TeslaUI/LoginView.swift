//
//  LoginView.swift
//  
//
//  Created by Joshua Homann on 1/17/21.
//

import Combine
import TeslaOwnerAPI
import KeychainSwift
import SwiftUI

public final class LoginViewModel: ObservableObject {
  @Published private(set) var loadingState: InputLoadingState<Token> = .awaitingInput
  @Published var showVehicles = false
  @Published var email: String = ""
  @Published var password: String = ""
  private var token = CurrentValueSubject<Token?, Never>(nil)
  private var tapLogin = PassthroughSubject<Void, Never>()
  public init(teslaOwnerAPI: TeslaOwnerAPI) {
    let keychain = KeychainSwift()
    token.send(
      keychain
        .getData(String(reflecting: Token.self))
        .flatMap { try?  JSONDecoder().decode(Token.self, from: $0) }
     )
    email = keychain
      .getData("email")
      .flatMap { String(data: $0, encoding: .utf8) } ?? ""
    password = keychain
      .getData("password")
      .flatMap { String(data: $0, encoding: .utf8) } ?? ""
    token
      .compactMap { $0 }
      .handleEvents(receiveOutput: { [weak self] token in
        guard let self = self,
          let data = try? JSONEncoder().encode(token) else {
          return
        }
        keychain.set(self.email, forKey: "email")
        keychain.set(self.password, forKey: "password")
        keychain.set(data, forKey: String(reflecting: Token.self))
        teslaOwnerAPI.token = token
        self.showVehicles = true
      })
      .map { InputLoadingState.loaded($0) }
      .assign(to: &$loadingState)
    tapLogin
      .map { [weak self] _ -> AnyPublisher<InputLoadingState<Token>, Never> in
        guard let self = self else {
          return Empty<InputLoadingState, Never>(completeImmediately: true)
          .eraseToAnyPublisher()
        }
        return teslaOwnerAPI
          .getToken(for: self.email, password: self.password)
          .map { InputLoadingState.loaded($0) }
          .catch { error in
            Just(InputLoadingState.error(error)).eraseToAnyPublisher()
          }
          .prepend(InputLoadingState.loading)
          .eraseToAnyPublisher()
      }
      .switchToLatest()
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveOutput: { [token] state in
        guard case let .loaded(newToken) = state else { return }
        token.send(newToken)
      })
      .assign(to: &$loadingState)
  }
  func login() {
    guard !email.isEmpty && !password.isEmpty && !loadingState.isLoading else { return }
    tapLogin.send()
  }
}

public struct LoginView: View {
  public typealias ViewModel = LoginViewModel
  @ObservedObject var viewModel: ViewModel
  @EnvironmentObject private var viewModelFactory: ViewModelFactory
  public var body: some View {
    VStack {
      TextField("Email", text: $viewModel.email)
        .textContentType(.username)
        .padding()
      SecureField("Password", text: $viewModel.password)
        .textContentType(.password)
        .padding()
      NavigationLink(
        destination: VehicleView(viewModel: viewModelFactory.makeVehicleViewModel()).environmentObject(viewModelFactory),
        isActive: $viewModel.showVehicles,
        label: { Button("Login") { viewModel.login() } }
      )
    }
    .navigationTitle("Login")
  }

  public init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }
}
