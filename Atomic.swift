//
//  Atomic.swift
//  SwiftDDP
//
//  Created by John Tumminaro on 9/6/17.
//

import Foundation
import Darwin

final internal class AtomicDict<K: Hashable,V> {
    private let entries: Atomic<[K: V]> = Atomic([:])
    
    internal var count: Int {
        return entries.withValue { $0.count }
    }
    
    internal var isEmpty: Bool {
        return entries.withValue { $0.isEmpty }
    }
    
    internal init() {
        
    }
    
    internal func value(forKey key: K) -> V? {
        return entries.withValue { $0[key] }
    }
    
    internal func set(value: V, forKey key: K) {
        entries.modify { (dict) in
            var newDict = dict
            newDict[key] = value
            return newDict
        }
    }
    
    internal func removeValue(forKey key: K) {
        entries.modify { (dict) in
            var newDict = dict
            newDict.removeValue(forKey: key)
            return newDict
        }
    }
    
    internal func clear() {
        entries.value = [:]
    }
    
    internal func copy() -> [K: V] {
        return entries.value
    }
    
    internal subscript(key: K) -> V? {
        get {
            return value(forKey: key)
        }
        set {
            guard let newValue = newValue else {
                removeValue(forKey: key)
                return
            }
            set(value: newValue, forKey: key)
        }
    }
}

final internal class Lock {
    internal var _lock = pthread_mutex_t()
    
    /// Initializes the variable with the given initial value.
    internal init() {
        let result = pthread_mutex_init(&_lock, nil)
        assert(result == 0, "Failed to init mutex in \(self)")
    }
    
    internal func lock() {
        let result = pthread_mutex_lock(&_lock)
        assert(result == 0, "Failed to lock mutex in \(self)")
    }
    
    internal func tryLock() -> Int32 {
        return pthread_mutex_trylock(&_lock)
    }
    
    internal func unlock() {
        let result = pthread_mutex_unlock(&_lock)
        assert(result == 0, "Failed to unlock mutex in \(self)")
    }
    
    deinit {
        let result = pthread_mutex_destroy(&_lock)
        assert(result == 0, "Failed to destroy mutex in \(self)")
    }
    
}

extension Lock {
    internal func withCriticalScope<Result>(body: () throws -> Result) rethrows -> Result {
        lock()
        defer { unlock() }
        return try body()
    }
}

/// An atomic variable.
internal final class Atomic<Value> {
    internal let lock = Lock()
    internal var _value: Value
    
    /// Atomically gets or sets the value of the variable.
    internal var value: Value {
        get {
            return lock.withCriticalScope {
                _value
            }
        }
        
        set(newValue) {
            lock.withCriticalScope {
                _value = newValue
            }
        }
    }
    
    /// Initializes the variable with the given initial value.
    internal init(_ value: Value) {
        _value = value
    }
    
    
    /// Atomically replaces the contents of the variable.
    ///
    /// Returns the old value.
    @discardableResult internal func swap(newValue: Value) -> Value {
        return modify { _ in newValue }
    }
    
    /// Atomically modifies the variable.
    ///
    /// Returns the old value.
    @discardableResult internal func modify( action: (Value) throws -> Value) rethrows -> Value {
        return try lock.withCriticalScope {
            let oldValue = _value
            _value = try action(_value)
            return oldValue
        }
    }
    
    /// Atomically performs an arbitrary action using the current value of the
    /// variable.
    ///
    /// Returns the result of the action.
    internal func withValue<Result>( action: (Value) throws -> Result) rethrows -> Result {
        return try lock.withCriticalScope {
            try action(_value)
        }
    }
}

