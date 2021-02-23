//
//  SocketViewModel.swift
//  BitcoinInfo
//
//  Created by Rohit Saini on 23/02/21.
//

import Foundation
import Starscream


protocol SocketEventDelegate {
    func connected(msg: String)
    func disconnected(msg: String)
    func didRecievedTransaction(response:Transaction)
}

class SocketViewModel{
    var socket: WebSocket!
    var delegate:SocketEventDelegate?
    
    func connect(){
        let url = URL(string: "wss://ws.blockchain.info/inv")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func subscribeTransaction(){
        socket.write(string: "{\"op\":\"unconfirmed_sub\"}")
    }
    
}

extension SocketViewModel:WebSocketDelegate{
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connented")
        delegate?.connected(msg: "Connented")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Disconnented")
        delegate?.disconnected(msg: "Disconnented")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
        let jsonData = Data(text.utf8)
        do {
            let success = try JSONDecoder().decode(Transaction.self, from: jsonData) // decode the response into model
            delegate?.didRecievedTransaction(response: success)
        }
        catch let err {
            print(err)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print(data)
    }
    
    
}
