//
//  ViewController.swift
//  UDApp
//
//  Created by Virl on 20/09/15.
//  Copyright © 2015 Underdark. All rights reserved.
//

import UIKit

import Underdark;

class ViewController: UIViewController
{
	@IBOutlet weak var navItem: UINavigationItem!

	@IBOutlet weak var framesCountLabel: UILabel!
	@IBOutlet weak var speedLabel: UILabel!
	
	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var progressHeight: NSLayoutConstraint!
	
	let node: Node
	
	//MARK: - Initialization
	
	required init?(coder aDecoder: NSCoder)
	{
		node = Node();

		super.init(coder: aDecoder)
		
		node.controller = self;
	}
	
	deinit
	{
		node.stop();
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		progressHeight.constant = 9
		
		node.start();
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}

	func updatePeersCount()
	{
		navItem.title = "\(node.peersCount)" + ((node.peersCount == 1) ? " peer" : " peers");
	}
	
	func updateFramesCount()
	{
		framesCountLabel.text = "\(node.framesCount) frames";
		
		let speed = Int( Double(node.bytesCount) / (node.timeEnd - node.timeStart + 0.0001) )
		speedLabel.text = "\(speed / 1024) kb/sec"
	}
	
	//MARK: - Actions

	func frameData(dataLength:Int) -> UDData
	{
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
		let result = UDLazyData(queue: queue, block: { () -> NSData? in
			let data = NSMutableData(length: dataLength);
			arc4random_buf(data!.mutableBytes, data!.length)
			//SecRandomCopyBytes(kSecRandomDefault, UInt(s.length), UnsafePointer<UInt8>(s.mutableBytes))
			
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.node.framesCount++
				self.updateFramesCount()
			})
			
			return data
		})
		
		return result
	}
	
	@IBAction func sendFramesSmall(sender: AnyObject)
	{
		node.broadcastFrame(frameData(1))
		
		for var i = 0; i < 100; ++i
		{
			node.broadcastFrame(frameData(1024));
		}
	}
	
	@IBAction func sendFramesLarge(sender: AnyObject)
	{
		node.broadcastFrame(frameData(1))

		for var i = 0; i < 5; ++i
		{
			node.broadcastFrame(frameData(10 * 1024 * 1024));
		}
	}
} // ViewController

