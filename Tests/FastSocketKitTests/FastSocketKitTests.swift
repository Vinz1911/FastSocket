import Network
import XCTest
@testable import FastSocketKit

class FastSocketKitTests: XCTestCase {
    /// the host address
    var host: String = "94.130.72.153"
    /// the port
    var port: UInt16 = 7878
    /// timeout for all tests
    var timeout: TimeInterval = 15.0

    /// a test for sending strings and responding data from the backend
    /// this is the definition of a download speedtest
    func testStringSendAndRespond() {
        let exp = expectation(description: "Wait for speed test to finish")
        let buffer = "50000"
        var datacount = 0
        let socket = FastSocket(host: host, port: port)
        socket.on.ready = {
            socket.send(message: buffer)
        }
        socket.on.message = { message in
            if case let message as Data = message {
                XCTAssertEqual(message.count, Int(buffer))
                exp.fulfill()
            }
        }
        socket.on.bytes = { bytes in
            if case .input(let count) = bytes {
                datacount += count
                debugPrint("Data Count: \(datacount)")
            }
        }
        socket.on.close = {
            debugPrint("connection closed")
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test for sending data and responding strings from the backend
    /// this is the definition of a upload speedtest
    func testDataSendAndRespond() {
        let exp = expectation(description: "Wait for speed test to finish")
        let buffer = Data(count: 50000)
        var datacount = 0
        let socket = FastSocket(host: host, port: port)
        socket.on.ready = {
            socket.send(message: buffer)
        }
        socket.on.message = { message in
            if case let message as String = message {
                XCTAssertEqual(buffer.count, Int(message))
                exp.fulfill()
            }
        }
        socket.on.bytes = { bytes in
            if case .output(let count) = bytes {
                datacount += count
                debugPrint("Data Count: \(datacount)")
            }
        }
        socket.on.close = {
            debugPrint("connection closed")
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test for multiple sending data to the backend and receive
    /// multiple strings from the backend
    func testMultipleSendDataAndReceiveString() {
        let exp = expectation(description: "Wait for speed test to finish")
        let buffer = Data(count: 1024)
        var messages = 0
        let sendValue = 1000
        var index = 0
        let socket = FastSocket(host: host, port: port)
        socket.on.ready = {
            func send() {
                socket.send(message: buffer) {
                    if index != sendValue {
                        send()
                    }
                    index += 1
                }
            }
            send()
        }
        socket.on.message = { message in
            if case let message as String = message {
                if messages == sendValue {
                    debugPrint("RECEIVED THIS COUNT: \(message)")
                    debugPrint("Responded Times: \(messages)")
                    exp.fulfill()
                }
                messages += 1
            }
        }
        socket.on.close = {
            debugPrint("connection closed")
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test for multiple sending strings to the backend and receive
    /// multiple data from the backend
    func testMultipleSendStringAndReceiveData() {
        let exp = expectation(description: "Wait for speed test to finish")
        let buffer = "1024"
        var messages = 0
        let sendValue = 1000
        var index = 0
        let socket = FastSocket(host: host, port: port)
        socket.on.ready = {
            func send() {
                socket.send(message: buffer) {
                    if index != sendValue {
                        send()
                    }
                    index += 1
                }
            }
            send()
        }
        socket.on.message = { message in
            if case let message as Data = message {
                if messages == sendValue {
                    debugPrint("RECEIVED THIS COUNT: \(message.count)")
                    debugPrint("Responded Times: \(messages)")
                    exp.fulfill()
                }
                messages += 1
            }
        }
        socket.on.close = {
            debugPrint("connection closed")
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test to look if the client can close a connection
    func testClose() {
        let exp = expectation(description: "Wait for connection close")
        let socket = FastSocket(host: host, port: port)
        socket.on.ready = {
            socket.disconnect()
        }
        socket.on.close = {
            debugPrint("Connection Closed!")
            exp.fulfill()
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test to measure how long the handshake takes
    /// and the connection is ready to be used
    func testPerformance() {
        let exp = expectation(description: "Wait for connection close")
        let socket = FastSocket(host: host, port: port)
        var startTime = Date().timeIntervalSince1970
        socket.on.ready = {
            debugPrint(Date().timeIntervalSince1970 - startTime)
            exp.fulfill()
        }
        socket.on.close = {
            debugPrint("Connection Closed!")
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        startTime = Date().timeIntervalSince1970
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test to look if the timeout stops trying to connect
    /// if the host doesnt respond
    func testTimeout() {
        let exp = expectation(description: "Wait for connection close")
        let socket = FastSocket(host: "telekom.de", port: port)
        socket.on.error = { error in
            guard let error = error else { return }
            XCTAssertEqual(error as! FastSocketError, FastSocketError.timeoutError)
            exp.fulfill()
        }
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test to look if the framework recognize empty host addresses
    func testFastSocketError() {
        let socket = FastSocket(host: "", port: port)
        socket.on.error = { error in
            guard let error = error else { return }
            XCTAssertEqual(error as! FastSocketError, FastSocketError.emptyHost)
        }
        socket.connect()
    }
    /// a test to look if the framing recognize empty data
    func testFrameErrorZeroData() {
        let frame = Frame()
        let data = Data(count: 0)
        XCTAssertThrowsError(try frame.parse(data: data){ _ in }) { error in
            XCTAssertEqual(error as! FastSocketError, FastSocketError.zeroData)
        }
    }
    /// a test to look if the framing recognize a memory overflow
    func testFrameErrorOverflow() {
        let frame = Frame()
        let data = Data(count: Constant.maximumFrameLength)
        XCTAssertThrowsError(try frame.create(message: data)) { error in
            XCTAssertEqual(error as! FastSocketError, FastSocketError.writeBufferOverflow)
        }
    }
    /// a test to look if the closures work
    func testClosureCall() {
        let closures = FastSocketCallback()
        closures.ready()
        closures.close()
        closures.message("")
        closures.bytes(.input(.zero))
        closures.bytes(.output(.zero))
        closures.error(FastSocketError.none)
    }
    /// a test to look if the framework recognize early send error
    /// that will be thrown if you try to send a string before a connection is established
    func testSendStringError() {
        let socket = FastSocket(host: host, port: port)
        socket.on.error = { error in
            XCTAssertEqual(error as! FastSocketError, FastSocketError.sendToEarly)
        }
        socket.send(message: "")
    }
    /// a test to look if the framework recognize early send error
    /// that will be thrown if you try to send data before a connection is established
    func testSendDataError() {
        let socket = FastSocket(host: host, port: port)
        socket.on.error = { error in
            XCTAssertEqual(error as! FastSocketError, FastSocketError.sendToEarly)
        }
        socket.send(message: Data())
    }
    /// a test to compare the errors description
    func testError() {
        XCTAssertEqual(FastSocketError.errorDomain, "fastsocket.error")
        XCTAssertEqual(FastSocketError.none.errorUserInfo["NSLocalizedDescription"], "null")
        XCTAssertEqual(FastSocketError.handshakeInitializationFailed.errorUserInfo["NSLocalizedDescription"], "cannot create handshake data, please retry")
        XCTAssertEqual(FastSocketError.handshakeVerificationFailed.errorUserInfo["NSLocalizedDescription"], "handshake verification failed, hash values are different. this can happen if theres a proxy network between...")
        XCTAssertEqual(FastSocketError.emptyHost.errorUserInfo["NSLocalizedDescription"], "host address cannot be empty!")
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
    /// a test to look if the dispatch timer works
    func testTimer() {
        let exp = expectation(description: "Timer")
        var timer: DispatchSourceTimer?
        var isCalledTwice = false
        timer = Timer.interval(interval: 1.0, withRepeat: true) {
            guard isCalledTwice else {
                isCalledTwice = true
                return
            }
            timer?.cancel()
            exp.fulfill()
        }
        wait(for: [exp], timeout: timeout)
    }
    /// measue parser performance
    func testMeasureParserPerformance() {
        let frame = Frame()
        let data = Data(count: Constant.maximumFrameLength - Constant.overheadSize)
        let message = try! frame.create(message: data)
        measure {
            try! frame.parse(data: message) { message in }
        }
    }
}
