//
//  Transaction.swift
//  BitcoinInfo
//
//  Created by Rohit Saini on 23/02/21.
//

import Foundation
// MARK: - PageResponse
struct Transaction: Codable {
    let op: String
    let x: X
}

// MARK: - X
struct X: Codable {
    let lockTime, ver, size: Int
    let inputs: [Input]
    let time, txIndex, vinSz: Int
    let hash: String
    let voutSz: Int
    let relayedBy: String
    let out: [Out]
    
    enum CodingKeys: String, CodingKey {
        case lockTime = "lock_time"
        case ver, size, inputs, time
        case txIndex = "tx_index"
        case vinSz = "vin_sz"
        case hash
        case voutSz = "vout_sz"
        case relayedBy = "relayed_by"
        case out
    }
}

// MARK: - Input
struct Input: Codable {
    let sequence: Int
    let prevOut: Out
    let script: String
    
    enum CodingKeys: String, CodingKey {
        case sequence
        case prevOut = "prev_out"
        case script
    }
}

// MARK: - Out
struct Out: Codable {
    let spent: Bool
    let txIndex, type: Int
    let addr: String
    let value, n: Int
    let script: String
    
    enum CodingKeys: String, CodingKey {
        case spent
        case txIndex = "tx_index"
        case type, addr, value, n, script
    }
}


