//
//  ActivityAction.swift
//  GitFeed
//
//  Created by Hang Gao on 2019/12/30.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation

enum ActivityAction {
  case processEvents([Event])
  case updateEvents([Event])
  case updateModifiedString(String)
}
