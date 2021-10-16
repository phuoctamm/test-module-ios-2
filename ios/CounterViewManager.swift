//
//  CounterViewManager.swift
//  TestModule
//
//  Created by Phuoc tam on 10/15/21.
//

import Foundation

@objc(CounterViewManager)
class CounterViewManager: RCTViewManager {
  override func view() -> UIView! {
    return CounterView()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
