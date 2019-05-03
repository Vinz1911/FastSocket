//
//  FastSocketTests.swift
//  FastSocketTests
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import XCTest
import Network
@testable import FastSocket

class FastSocketTests: XCTestCase {
    var timer: DispatchSourceTimer?
    
    func testDownload() {
        let exp = expectation(description: "Wait for speed test to finish")
        let buffer = "50000"
        var datacount = 0
        let socket = FastSocket(host: "socket.weist.it", port: 8080)
        socket.on.ready = {
            socket.send(message: buffer)
        }
        socket.on.data = { data in
            print("RECEIVED THIS COUNT: \(data.count)")
            XCTAssertEqual(data.count, Int(buffer))
            exp.fulfill()
        }
        socket.on.dataRead = { count in
            datacount += count
            print(datacount)
        }
        socket.on.close = {
            print("connection closed")
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: 10.0)
    }

    func testUpload() {
        let exp = expectation(description: "Wait for speed test to finish")
        let buffer = Data(count: 50000)
        var datacount = 0
        let socket = FastSocket(host: "socket.weist.it", port: 8080)
        socket.on.ready = {
            socket.send(message: buffer)
        }
        socket.on.string = { text in
            print("RECEIVED THIS COUNT: \(text)")
            XCTAssertEqual(buffer.count, Int(text))
            exp.fulfill()
        }
        socket.on.dataWritten = { count in
            datacount += count
            print(datacount)
        }
        socket.on.close = {
            print("connection closed")
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: 10.0)
    }
    
    func testClose() {
        let exp = expectation(description: "Wait for connection close")
        let socket = FastSocket(host: "socket.weist.it", port: 8080)
        socket.on.ready = {
            socket.disconnect()
        }
        socket.on.close = {
            print("Connection Closed!")
            exp.fulfill()
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: 15.0)
    }

    func testFrameErrorZeroData() {
        let frame = Frame()
        let data = Data(count: 0)
        XCTAssertThrowsError(try frame.parse(data: data)) { error in
            XCTAssertEqual(error as! FastSocketError, FastSocketError.zeroData)
        }
    }
    
    func testFrameErrorUnknown() {
        let frame = Frame()
        var data = Data(count: 1)
        data[0] = 0x3
        XCTAssertThrowsError(try frame.parse(data: data)) { error in
            XCTAssertEqual(error as! FastSocketError, FastSocketError.unknownOpcode)
        }
    }
    
    func testFrameOverflow() {
        let frame = Frame()
        let data = Data(count: 17000000)
        XCTAssertThrowsError(try frame.create(data: data, opcode: .binary)) { error in
            XCTAssertEqual(error as! FastSocketError, FastSocketError.writeBufferOverflow)
        }
    }
    
    func testClosureCall() {
        let frameClosures = FrameClosures()
        let transferClosures = TransferClosures()
        let fastSocketClosures = FastSocketClosures()
        
        frameClosures.dataFrame(Data())
        frameClosures.stringFrame(Data())
        
        transferClosures.ready()
        transferClosures.close()
        transferClosures.data(Data())
        transferClosures.dataRead(Int())
        transferClosures.dataWritten(Int())
        transferClosures.error(FastSocketError.none)
        
        fastSocketClosures.ready()
        fastSocketClosures.close()
        fastSocketClosures.data(Data())
        fastSocketClosures.string(String())
        fastSocketClosures.dataRead(Int())
        fastSocketClosures.dataWritten(Int())
        fastSocketClosures.error(FastSocketError.none)
    }
    
    func testSendStringError() {
        let socket = FastSocket(host: "socket.weist.it", port: 8080)
        socket.on.error = { error in
            XCTAssertEqual(error as! FastSocketError, FastSocketError.sendToEarly)
        }
        socket.send(message: "")
    }
    
    func testSendDataError() {
        let socket = FastSocket(host: "socket.weist.it", port: 8080)
        socket.on.error = { error in
            XCTAssertEqual(error as! FastSocketError, FastSocketError.sendToEarly)
        }
        socket.send(message: Data())
    }
    
    func testError() {
        XCTAssertEqual(FastSocketError.errorDomain, "fastsocket.error")
        XCTAssertEqual(FastSocketError.none.errorUserInfo["NSLocalizedDescription"], "null")
        XCTAssertEqual(FastSocketError.handShakeFailed.errorUserInfo["NSLocalizedDescription"], "handshake failure, not protocol compliant")
        XCTAssertEqual(FastSocketError.timeoutError.errorUserInfo["NSLocalizedDescription"], "connection timeout error")
        XCTAssertEqual(FastSocketError.networkUnreachable.errorUserInfo["NSLocalizedDescription"], "network is down or not reachable")
        XCTAssertEqual(FastSocketError.sendFailed.errorUserInfo["NSLocalizedDescription"], "send failure, data was not written")
        XCTAssertEqual(FastSocketError.sendToEarly.errorUserInfo["NSLocalizedDescription"], "socket is not ready, could not send")
        XCTAssertEqual(FastSocketError.socketClosed.errorUserInfo["NSLocalizedDescription"], "socket was closed")
        XCTAssertEqual(FastSocketError.socketUnexpectedClosed.errorUserInfo["NSLocalizedDescription"], "socket was unexpected closed")
        XCTAssertEqual(FastSocketError.writeBeforeClear.errorUserInfo["NSLocalizedDescription"], "previous data not finally written!, cannot write on socket")
        XCTAssertEqual(FastSocketError.parsingFailure.errorUserInfo["NSLocalizedDescription"], "message parsing error, no valid UTF-8")
        XCTAssertEqual(FastSocketError.zeroData.errorUserInfo["NSLocalizedDescription"], "data is empty cannot parse into message")
        XCTAssertEqual(FastSocketError.readBufferIssue.errorUserInfo["NSLocalizedDescription"], "readbuffer issue, is empty or wrong data")
        XCTAssertEqual(FastSocketError.unknownOpcode.errorUserInfo["NSLocalizedDescription"], "unknown opcode, cannot parse message")
        XCTAssertEqual(FastSocketError.readBufferOverflow.errorUserInfo["NSLocalizedDescription"], "readbuffer overflow!")
        XCTAssertEqual(FastSocketError.writeBufferOverflow.errorUserInfo["NSLocalizedDescription"], "writebuffer overflow!")
        XCTAssertEqual(FastSocketError.none.errorCode, 0)
    }
    
    func testTimer() {
        let exp = expectation(description: "Timer")
        var isCalledTwice = false
        self.timer = Timer.interval(interval: 1.0, withRepeat: true) {
            guard isCalledTwice else {
                isCalledTwice = true
                return
            }
            self.timer?.cancel()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
}
