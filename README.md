<div align="center">
    <h1>
        <br>
            <a href="https://github.com/Vinz1911/FastSocket"><img src="http://weist.it/content/assets/images/fastsocket.svg" alt="FastSocket" width="600"></a>
        <br>
            FastSocket
        <br>
    </h1>
</div>

`FastSocket` is a proprietary bi-directional message based communication protocol on top of TCP (optionally over other layers in the future). The idea behind this project was, to create a TCP communication like the [WebSocket Protocol](https://tools.ietf.org/html/rfc6455) with less overhead and the ability to track every 8192 bytes read or written on the socket without waiting for the whole message to be transmitted. This allows it to use it as **protocol for speed tests** for measuring the TCP throughput performance. Our server-sided implementation is written in [golang](https://golang.org/) and it's optimized for maximum speed and performance.

## Features:

- [X] send and receive text and data messages
- [X] async, non-blocking & very fast
- [X] threading is handled by the framework itself
- [X] track send & received bytes
- [X] allows you to chose the network interface!
- [X] zer0 dependencies, native swift implementation with Network.framework
- [X] custom error management
- [X] all errors are routed through the error closure
- [X] maximum frame size 16777216 bytes (with overhead)
- [X] content length base framing instead of fin byte termination
- [X] send/receive multiple messages at once (currently only in debug mode)
- [X] TLS support
- [X] XCFramework support
- [X] Swift Packages support

## License:
[![License](https://img.shields.io/badge/license-GPLv3-blue.svg?longCache=true&style=flat)](https://github.com/Vinz1911/FastSocket/blob/master/LICENSE)

## Swift Version:
[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg?logo=swift&style=flat)](https://swift.org) [![Swift 5.1](https://img.shields.io/badge/SPM-Support-orange.svg?logo=swift&style=flat)](https://swift.org)

## Build Status:
|  Branch |                                                                                     Build Status                                                                                    |                                                                                                    Coverage                                                                                                   |                                                                                              Maintainability                                                                                              |
|:-------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|  master |   [![Travis Master](https://img.shields.io/travis/Vinz1911/FastSocket/master.svg?label=master&logo=travis&style=flat)](https://travis-ci.org/Vinz1911/FastSocket/builds)   | [![Code Climate Coverage](https://img.shields.io/codeclimate/coverage/Vinz1911/FastSocket.svg?color=brightgreen&logo=code%20climate&style=flat)](https://codeclimate.com/github/Vinz1911/FastSocket) | [![Code Climate Maintainability](https://img.shields.io/codeclimate/maintainability/Vinz1911/FastSocket.svg?logo=Code%20Climate&style=flat)](https://codeclimate.com/github/Vinz1911/FastSocket) |
| develop |  [![Travis Develop](https://img.shields.io/travis/Vinz1911/FastSocket/develop.svg?label=develop&logo=travis&style=flat)](https://travis-ci.org/Vinz1911/FastSocket/builds) |                                                                                                                                                                                                               |                                                                                                                                                                                                           |

## Installation:
### XCFramework
Download the latest Framework Version from the [Release](https://github.com/Vinz1911/FastSocket/releases) section. 
Copy the FastSocket.xcframework to your `Frameworks and Libraries` section.

### Swift Packages
Full support for [SwiftPackageManager](https://developer.apple.com/documentation/swift_packages). Just add the repo to your project in the project settings under Swift Packages.

## Import:
```swift
// import the Framework
import FastSocket
// normal init with TCP (unsecure) transfer type
let socket = FastSocket(host: "example.com", port: 8080)
// enhanced init with the ability to set TLS (secure) as transfer type
let socket = FastSocket(host: "example.com", port: 443, type: .tls)
```

## Closures:
```swift
socket.on.ready = {
    // this is called after the connection
    // was successfully established and is ready
}
socket.on.message = { message in
    // this is called everytime
    // a message was received
}
socket.on.bytes = { count in
    // this is called every 8192 bytes
    // are readed from the socket
}
socket.on.close = {
    // this is called after
    // the socket was closed
}
socket.on.error = { error in
    // this is called everytime
    // an error appeared
}
```

## Cast Messages:
```swift
socket.on.message = { message in
    // it's only possible to cast messages
    // as Data or as String
    if case let message as Data = message {
        // cast message as data
        print("Data count: \(message.count)")
    }
    if case let message as String = message {
        // cast message as string
        print("Message: \(message)")
    }
}
```

## Read Bytes Count:
```swift
socket.on.bytes = { bytes in
    // input bytes are the ones, which are
    // readed from the socket, this function
    // returns the byte count
    if case .input(let count) = bytes {
        print("Bytes count: \(count)")
    }
    // output bytes are the ones, which are
    // written on the socket, this function
    // returns the byte count
    if case .output(let count) = bytes {
        print("Bytes count: \(count)")
    }
}
```

## Connect:
```swift
// try to connect to the host
// timeout after 5.0 seconds
socket.connect()
```

## Disconnect:
```swift
// closes the connection
socket.disconnect()

```

## Send Messages:
```swift
// the send func is a generic func
// it allows to send `String` and `Data`
socket.send(message: T)
```

## Additional Parameters:
```swift
// FastSocket was build in top of Apple's Network.framework
// that allows us to use lot of TCP features like fast open or
// to select the network interface type

// set the traffics service class
socket.parameters.serviceClass = .interactiveVoice

// enable fast open
socket.parameters.allowFastOpen = true

// select the interface type
// if it's not available, it will cancel with an error
socket.parameters.requiredInterfaceType = .cellular
```

## Authors:
[Vinzenz Weist](https://github.com/Vinz1911)
[Juan Romero](https://github.com/rukano)
