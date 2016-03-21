//
//  Node.swift
//  UDApp
//
//  Created by Virl on 20/09/15.
//  Copyright © 2015 Underdark. All rights reserved.
//

import UIKit

import Underdark;

class Node: NSObject, UDTransportDelegate
{
	let appId: Int32 = 234235;
	let nodeId: Int64;
	let queue = dispatch_get_main_queue()
	var transport: UDTransport? = nil;
	
	var links: [UDLink] = [];
	
	weak var controller: ViewController?;
	var peersCount = 0;
	var framesCount = 0;
	
	var bytesCount = 0;
	var timeStart : NSTimeInterval = 0
	var timeEnd : NSTimeInterval = 0
	
	override init()
	{
		var buf : Int64 = 0;
		repeat
		{
			arc4random_buf(&buf, sizeofValue(buf))
		} while buf == 0;

		if(buf < 0) {
			buf = -buf;
		}

		nodeId = buf;
		
		super.init()

		let transportKinds = [UDTransportKind.Wifi.rawValue, UDTransportKind.Bluetooth.rawValue];

		transport = UDUnderdark.configureTransportWithAppId(appId, nodeId: nodeId, delegate: self, queue: queue, kinds: transportKinds);
	}
	
	func start()
	{
		controller?.updateFramesCount();
		controller?.updatePeersCount();
		
		transport?.start();
	}
	
	func stop()
	{
		transport?.stop();
		
		framesCount = 0;
		controller?.updateFramesCount();
	}
	
	func broadcastFrame(frameData: UDData)
	{
		if(links.isEmpty) { return; }
		
		controller?.updateFramesCount();
		
		for link in links
		{
			link.sendData(frameData);
		}
	}
	
	// MARK: - UDTransportDelegate
	
	func transport(transport: UDTransport!, linkConnected link: UDLink!)
	{
		links.append(link);
		peersCount += 1
		controller?.updatePeersCount();
	}
	
	func transport(transport: UDTransport!, linkDisconnected link: UDLink!)
	{
		links = links.filter() { $0 !== link };
		peersCount -= 1
		controller?.updatePeersCount();
	}
	
	func transport(transport: UDTransport!, link: UDLink!, didReceiveFrame data: NSData!)
	{
		if(data.length == 1) {
			framesCount = 0
			bytesCount = 0
			timeStart = NSDate.timeIntervalSinceReferenceDate()
			timeEnd = NSDate.timeIntervalSinceReferenceDate()
		}
		else {
			framesCount += 1
			bytesCount += data.length
			timeEnd = NSDate.timeIntervalSinceReferenceDate()
		}
		
		controller?.updateFramesCount();
	}
}
