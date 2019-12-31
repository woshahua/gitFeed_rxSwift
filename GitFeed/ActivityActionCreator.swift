//
//  ActivityActionCreator.swift
//  GitFeed
//
//  Created by Hang Gao on 2019/12/30.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation
import RxSwift

class ActivityActionCreator {
  private let store = ActivityStore()
  private let bag = DisposeBag()
  
  
  func fetchEvents() {
    // why share replay: 1
    let response = Observable.from([store.state.repo])
      .map { urlString -> URL in
        return URL(string: "https://api.github.com/repos/\(urlString)/events")!
    }.map { [weak self] url -> URLRequest in
      var request = URLRequest(url: url)
      if let modifiedHeader = self?.store.state.lastModified.value {
        request.addValue(modifiedHeader, forHTTPHeaderField: "Last-Modified")
      }
      return request
    }.flatMap { reuquest -> Observable<(response: HTTPURLResponse, data: Data)> in
      return URLSession.shared.rx.response(request: reuquest)
    }.share(replay: 1)
  
    response.filter { response, _ in
      return 200..<300 ~= response.statusCode
    }
    .map { _, data -> [Event] in
      let decoder = JSONDecoder()
      let events = try? decoder.decode([Event].self, from: data)
      return events ?? []
    }
    .filter { objects in
      return !objects.isEmpty
    }.subscribe(onNext: { [weak self] newEvents in
      self?.store.dispatch(action: .processEvents(newEvents))
      }).disposed(by: bag)
    
    
    // seconde subscribtion
    response.filter { response, _ in
        return 200..<400 ~= response.statusCode
      }
    .flatMap { response, _ -> Observable<String> in
      guard let value = response.allHeaderFields["Last-Modified"] as? String else {
        return Observable.empty()
      }
      return Observable.just(value)
    }.subscribe(onNext: { [weak self] modifiedHeader in
      guard let strongSelf = self else { return }
      strongSelf.store.dispatch(action: .updateModifiedString(modifiedHeader))
      // ???
      try? modifiedHeader.write(to: strongSelf.store.state.modifiedFileURL, atomically: true, encoding: .utf8)
      }).disposed(by: bag)
  }
  
  func fetchPersistEvents() {
    let decoder = JSONDecoder()
    if let eventsData = try? Data(contentsOf: store.state.eventsFileURL),
      let persistedEvents = try? decoder.decode([Event].self, from: eventsData) {
      store.dispatch(action: .updateEvents(persistedEvents))
    }
    
    if let lastModifiedString = try? String(contentsOf: store.state.modifiedFileURL, encoding: .utf8) {
      store.dispatch(action: .updateModifiedString(lastModifiedString))
    }
  }
}

extension ActivityActionCreator {
  func numberOfSections() -> Int {
    return store.state.events.value.count
  }
  
  func event(at index: Int) -> Event {
    return store.state.events.value[index]
  }
}
