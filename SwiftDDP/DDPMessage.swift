// Copyright (c) 2016 Peter Siegesmund <peter.siegesmund@icloud.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/**
Enum value representing the types of DDP messages that the server can send
*/

// Handled Message Types
public enum DDPMessageType:String {
    
    // case Connect = "connect"     // (client -> server)
    case connected  = "connected"
    case failed     = "failed"
    case ping       = "ping"
    case pong       = "pong"
    // case Sub     = "sub"         // (client -> server)
    // case Unsub   = "unsub"       // (client -> server)
    case nosub      = "nosub"
    case added      = "added"
    case changed    = "changed"
    case removed    = "removed"
    case ready      = "ready"
    case addedBefore = "addedBefore"
    case movedBefore = "movedBefore"
    // case Method  = "method"       // (client -> server)
    case result     = "result"
    case updated    = "updated"
    case error      = "error"
    case unhandled  = "unhandled"
}

    // Method or Nosub error
    // Such an Error is used to represent errors raised by the method or subscription,
    // as well as an attempt to subscribe to an unknown subscription or call an unknown method.
    
    // Other erroneous messages sent from the client to the server can result in receiving a top-level msg: 'error' message in response. These conditions include:
    
    // - sending messages which are not valid JSON objects
    // - unknown msg type
    // - other malformed client requests (not including required fields)
    // - sending anything other than connect as the first message, or sending connect as a non-initial message
    //   The error message contains the following fields:
    
    // - reason: string describing the error
    // - offendingMessage: if the original message parsed properly, it is included here

/**
A struct to parse, encapsulate and facilitate handling of DDP message strings
*/

public struct DDPMessage {
    
    /**
    The message's properties, stored as an Dictionary
    */
    
    public var json: [String: Any]
    
    /**
    Initialize a message struct, with a Json string
    */
    
    public init(message: String) {
        if let JSON = message.dictionaryValue() { self.json = JSON }
        else {
            self.json = ["msg":"error", "reason":"SwiftDDP JSON serialization error.",
                "details": "SwiftDDP JSON serialization error. JSON string was: \(message). Message will be handled as a DDP message error."]
        }
    }
    
    /**
    Initialize a message struct, with a dictionary of strings
    */
    
    public init(message: [String: Any]) {
        self.json = message
    }
    
    /**
    Converts a Dictionary to a JSON string
    */
    
    //
    // Computed variables
    //
    
    /**
    Returns the DDP message type, of type DDPMessageType enum
    */
    
    public var type: DDPMessageType {
        if let msg = message,
            let type = DDPMessageType(rawValue: msg) {
                return type
        }
        return .unhandled
    }
    
    /**
    Returns a boolean value indicating if the message is an error message or not
    */
    
    public var isError: Bool {
        if (self.type == .error) { return true }    // if message is a top level error ("msg"="error")
        if let _ = self.error { return true }       // if message contains an error object, as in method or nosub
        return false
    }
    
    // Returns the root-level keys of the JSON object
    internal var keys: [String] {
        return Array(json.keys)
    }
    
    public func hasProperty(_ name:String) -> Bool {
        if let property = json[name], ((property as! NSObject) != NSNull()) {
            return true
        }
        return false
    }
    
    /**
    The optional DDP message
    */
    
    public var message:String? {
        get { return json["msg"] as? String }
    }
    
    /**
    The optional DDP session string
    */
    
    public var session:String? {
        get { return json["session"] as? String }
    }
    
    /**
    The optional DDP version string
    */
    
    public var version:String? {
        get { return json["version"] as? String }
    }
    
    /**
    The optional DDP support string
    */
    
    public var support:String? {
        get { return json["support"] as? String }
    }
    
    /**
    The optional DDP message id string
    */
    
    public var id:String? {
        get { return json["id"] as? String }
    }
    
    /**
    The optional DDP name string
    */
    
    public var name:String? {
        get { return json["name"] as? String }
    }
    
    /**
    The optional DDP param string
    */
    
    public var params:String? {
        get { return json["params"] as? String }
    }
    
    /**
    The optional DDP error object
    */
    
    public var error: DDPError? {
        get { if let e = json["error"] as? [String: Any] { return DDPError(json: e) } else { return nil }}
    }
    
    /**
    The optional DDP collection name string
    */
    
    public var collection:String? {
        get { return json["collection"] as? String }
    }
    
    /**
    The optional DDP fields dictionary
    */
    
    public var fields: [String: Any]? {
        get { return json["fields"] as? [String: Any] }
    }
    
    /**
    The optional DDP cleared array. Contains an array of fields that should be removed
    */
    
    public var cleared:[String]? {
        get { return json["cleared"] as? [String] }
    }
    
    /**
    The optional method name
    */
    
    public var method:String? {
        get { return json["method"] as? String }
    }
    
    /**
    The optional random seed JSON value (an arbitrary client-determined seed for pseudo-random generators)
    */
    
    public var randomSeed:String? {
        get { return json["randomSeed"] as? String }
    }
    
    /**
    The optional result object, containing the result of a method call
    */
    
    public var result:Any? {
        get { return json["result"] }
    }
    
    /**
    The optional array of ids passed to 'method', all of whose writes have been reflected in data messages)
    */
    
    public var methods:[String]? {
        get { return json["methods"] as? [String] }
    }
    
    /**
    The optional array of id strings passed to 'sub' which have sent their initial batch of data
    */
    
    public var subs:[String]? {
        get { return json["subs"] as? [String] }
    }
    
    /**
    The optional reason given for an error returned from the server
    */
    
    public var reason:String? {
        get { return json["reason"] as? String }
    }
    
    /**
    The optional original error message
    */
    
    public var offendingMessage:String? {
        get { return json["offendingMessage"] as? String }
    }
}

private let authErrorCodeSet = Set<Int>([401, 403])

/**
A struct encapsulating a DDP error message
*/

public struct DDPError: Error {
    
    fileprivate var json: [String: Any]?
    
    /**
    The integer error code
    */
    
    public var error: Int? {
        if let intCode = json?["error"] as? Int {
            return intCode
        } else if let intString = json?["error"] as? String {
            return Int(intString)
        }
        return nil
    }
    
    /**
     Whether it is an authentication error
     */
    
    public var isAuthError: Bool {
        guard let error = error else { return false }
        return authErrorCodeSet.contains(error)
    }
    
    /**
    The detailed message given for an error returned from the server
    */
    
    public var reason: String? { return json?["reason"] as? String }
    
    /**
    The string providing error details
    */
    
    public var details: String? { return json?["details"] as? String }
    
    /**
    If the original message parsed properly, it is included here
    */
    
    public var offendingMessage: String? { return json?["offendingMessage"] as? String }
    
    /**
    Helper variable that returns true if the struct has both an error code and a reason
    */
    
    var isValid:Bool {
        if let _ = error { return true }
        if let _ = reason { return true }
        return false
    }
    
    init(json: Any?) {
        self.json = json as? [String: Any]
    }
}

/**
 Support LocalizedError to pass messages through to UI.
 */
extension DDPError: LocalizedError {
    public var errorDescription: String? { return self.reason }
}

