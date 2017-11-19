//
//  ViewController.swift
//  MockURLResponderSampleApp
//
//  Created by Josep Rodríguez López on 19/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var label: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		label.text = "Loading..."

		URLSession.shared.dataTask(with: URL(string: "https://www.google.com/")!) { (data, response, error) in
			DispatchQueue.main.async {
				guard let data = data, let body = String(data: data, encoding: .ascii) else {
					self.label.text = "Couldn't receive data"
					return
				}
				
				self.label.text = body
			}
		}.resume()
	}
}

