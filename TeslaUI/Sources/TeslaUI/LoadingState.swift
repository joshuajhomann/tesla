//
//  File.swift
//  
//
//  Created by Joshua Homann on 1/17/21.
//

import Foundation

enum InputLoadingState<Content> {
  case loading, awaitingInput, error(Error), loaded(Content)
  var isLoading: Bool {
    switch self {
    case .loading: return true
    default: return false
    }
  }
}

enum CollectionLoadingState<Content: Collection, SomeError: Error> {
  case loading(placeholder: Content), loaded(content: Content), empty, error(SomeError)
}

enum LoadingState<Content, SomeError: Error> {
  case loading, loaded(content: Content), error(SomeError)
  var content: Content? {
    switch self {
    case let .loaded(content): return content
    default: return nil
    }
  }
}
