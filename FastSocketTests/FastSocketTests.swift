//
//  FastSocketTests.swift
//  FastSocketTests
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import XCTest
@testable import FastSocket

class FastSocketTests: XCTestCase {

    func testDownload() {
        let exp = expectation(description: "Wait for speed test to finish")
        var sockets = [FastSocket]()
        var datacount = 0
        for i in 0...9 {
            sockets.append(FastSocket(host: "socket.weist.it", port: 3333))
            sockets[i].on.ready = {
                sockets[i].send(string: "1000000")
            }
            sockets[i].on.binary = { data in
                print("RECEIVED FROM: \(i) THIS COUNT: \(data.count)")
                sockets[i].send(string: "1000000")
            }
            sockets[i].on.dataRead = { count in
                datacount += count
                print(datacount)
            }
            sockets[i].connect()
        }
        wait(for: [exp], timeout: 100.0)
    }

    func testUpload() {
        let exp = expectation(description: "Wait for speed test to finish")
        let buffer = Data(count: 10000)
        var sockets = [FastSocket]()
        var datacount = 0
        for i in 0...9 {
            sockets.append(FastSocket(host: "socket.weist.it", port: 3333))
            sockets[i].on.ready = {
                sockets[i].send(data: buffer)
            }
            sockets[i].on.text = { text in
                print("RECEIVED FROM: \(i) THIS COUNT: \(text)")
                sockets[i].send(data: buffer)
            }
            sockets[i].on.dataWritten = { count in
                datacount += count
                print(datacount)
            }
            sockets[i].connect()
        }
        wait(for: [exp], timeout: 100.0)
    }
    
    func testClose() {
        let exp = expectation(description: "Wait for connection close")
        let socket = FastSocket(host: "socket.weist.it", port: 3333)
        socket.on.ready = {
            print("connection established")
            socket.disconnect()
        }
        socket.on.close = {
            print("connection successfully closed")
            exp.fulfill()
        }
        socket.connect()
        wait(for: [exp], timeout: 100.0)
    }
}
