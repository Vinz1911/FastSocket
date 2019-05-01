//
//  Typealiases.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

/// typealias for a normal closure
public typealias Callback = () -> Void
/// typealias for a closure which returns some data
public typealias CallbackData = (Data) -> Void
/// typealias for a closure which return an optional error
public typealias CallbackError = (Error?) -> Void
/// typealias for a closure which returns an integer
public typealias CallbackInt = (Int) -> Void
/// typealias for a closure which returns a string
public typealias CallbackString = (String) -> Void
