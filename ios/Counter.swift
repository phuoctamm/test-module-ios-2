//
//  Counter.swift
//  TestModule
//
//  Created by Phuoc tam on 10/15/21.
//

import Foundation

@objc(Counter)
class Counter: NSObject {

  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }

  private var count = 0

  @objc
  func increment() {
    count += 1
    print("count is \(count)")
  }

  @objc
  func getCount(_ callback: RCTResponseSenderBlock) {
    callback([count])
  }

}

