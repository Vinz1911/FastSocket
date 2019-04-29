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
- [X] track every 8192 send & received bytes
- [X] custom error management
- [X] allows you to chose the network interface!
- [X] Zer0 dependencies, native swift implementation with Network.framework

## Build Status:

|      Branch      |                                                                                                         Build Status                                                                                                        |                                                                            Coverage                                                                           |
|:----------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|      master      | [![CircleCI](https://circleci.com/gh/Vinz1911/FastSocket/tree/master.svg?style=shield&circle-token=d3bc94f649f0ee8087e17007476032517b1eac6a)](https://circleci.com/gh/Vinz1911/FastSocket/tree/master)                      | [![codecov](https://codecov.io/gh/Vinz1911/FastSocket/branch/master/graph/badge.svg?token=1sEt52DskP)](https://codecov.io/gh/Vinz1911/FastSocket)             |
|      develop     | [![CircleCI](https://circleci.com/gh/Vinz1911/FastSocket/tree/develop.svg?style=shield&circle-token=d3bc94f649f0ee8087e17007476032517b1eac6a)](https://circleci.com/gh/Vinz1911/FastSocket/tree/develop )                   | [![codecov](https://codecov.io/gh/Vinz1911/FastSocket/branch/develop/graph/badge.svg?token=1sEt52DskP)](https://codecov.io/gh/Vinz1911/FastSocket)            |

## Installation:

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'FastSocket', :git => 'https://github.com/Vinz1911/FastSocket.git'
```

### Carthage

Add the following line to your `Cartfile`

```ruby
github "Vinz1911/FastSocket"
```

### Swift Package

    Not yet supported

## Import:

```swift
// import the Framework
import FastSocket
let socket = FastSocket(host: "example.com", port: 8081)

```

## Closures:

```swift
socket.on.ready = {
    // this is called after the connection
    // was successfully established and is ready
}
socket.on.data = { data in
    // this is called everytime
    // a data message was received
}
socket.on.string = { string in
    // this is called everytime
    // a text message was received
}
socket.on.dataRead = { count in
    // this is called every 8192 bytes
    // are readed from the socket
}
socket.on.dataWritten = { count in
    // this is called every 8192 bytes
    // are written on the socket
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

## Connect:

```swift
// try to connect to the host
// timeout after 3.0 seconds
socket.connect()
```

## Disconnect:

```swift
// closes the connection
socket.disconnect()

```

## Send Messages:
```swift
// send a text based message to the backend
socket.send(string: String)

// send a binary based message to the backend
socket.send(data: Data)
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
