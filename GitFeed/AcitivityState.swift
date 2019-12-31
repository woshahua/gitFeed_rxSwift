//
//  AcitivityState.swift
//  GitFeed
//
//  Created by Hang Gao on 2019/12/30.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ActivityState {
  let events = BehaviorRelay<[Event]>(value: [])
  let eventsFileURL = cachedFileURL("events.json")
  let modifiedFileURL = cachedFileURL("modified.txt")
  let lastModified = BehaviorRelay<String?>(value: nil)
  let repo = "ReactiveX/RxSwift"
}

func cachedFileURL(_ filenname: String) -> URL {
  // ???
  return FileManager.default
    // ???
    .urls(for: .cachesDirectory, in: .allDomainsMask)
  .first!
  .appendingPathComponent(filenname)
}
