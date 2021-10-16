//
//  RCTDeepArManager.swift
//  TestModule
//
//  Created by Phuoc tam on 10/16/21.
//

import Foundation

@objc(RCTDeepArManager)
class RCTDeepArManager: RCTViewManager {
  override func view() -> UIView! {
    return RCTDeepAr();
  }
  
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
