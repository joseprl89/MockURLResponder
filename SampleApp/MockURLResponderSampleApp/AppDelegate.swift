//
//  AppDelegate.swift
//  MockURLResponderSampleApp
//
//  Created by Josep Rodríguez López on 19/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import UIKit
import MockURLResponder

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		MockURLResponder.Configuration.mockingBehaviour = .dropNonMockedNetworkCalls
		MockURLResponder.setUp()
		return true
	}
}

