//
//  File.swift
//  
//
//  Created by Joshua Homann on 1/24/21.
//

import Combine
import SwiftUI
import TeslaOwnerAPI

public final class CommandButtonViewModel: ObservableObject {
  @Published private(set) var isExecuting = false
  private(set) var tapSubject = PassthroughSubject<Void, Never>()
  private var subscription: Set<AnyCancellable> = []
  init(action: @escaping () -> AnyPublisher<Void, Never>) {
    tapSubject
      .filter { [weak self] in !(self?.isExecuting ?? true) }
      .map { _ in action() }
      .switchToLatest()
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { _ in
        self.isExecuting = false
      }, receiveValue: { })
      .store(in: &subscription)
  }

  func tap() {
    tapSubject.send()
  }
}

public struct CommandButton<ViewModel: CommandButtonViewModel, Content: View>: View {
  @StateObject private var viewModel: ViewModel
  private var title: () -> Content
  public var body: some View {
    Button {
      viewModel.tap()
    } label: {
      HStack {
        title()
        if viewModel.isExecuting {
          ProgressView()
        }
      }
    }
  }
  init(
    action: @escaping () -> AnyPublisher<Void, Never>,
    @ViewBuilder title: @escaping () -> Content
  ) {
    _viewModel = .init(wrappedValue: .init(action: action))
    self.title = title
  }
}
