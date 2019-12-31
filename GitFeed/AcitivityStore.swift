//
//  AcitivityStore.swift
//  GitFeed
//
//  Created by Hang Gao on 2019/12/30.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation
import RxSwift

class ActivityStore {
  private(set) var state = ActivityState()
  
  func dispatch(action: ActivityAction) {
    switch action {
    case let .updateEvents(events):
      state.events.accept(events)
    case let .processEvents(events):
      var updatedEvents = events + state.events.value
      if updatedEvents.count > 50 {
        updatedEvents = [Event](updatedEvents.prefix(upTo: 50))
      }
      state.events.accept(updatedEvents)
      let encoder = JSONEncoder()
      if let eventData = try? encoder.encode(updatedEvents) {
        try? eventData.write(to: state.eventsFileURL, options: .atomicWrite)
      }
    case let .updateModifiedString(lastModified):
      state.lastModified.accept(lastModified)
    }
  }
}
