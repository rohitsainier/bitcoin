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
    func didRecievedTransaction()
}

class SocketViewModel{
    var socket: WebSocket!
    var delegate:SocketEventDelegate?
    var transactionQueue = [Transaction]()
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
    //ToDo: we can use any conversion api here to convert amount into dollors but now i just created a dummy func for that purposes
    func convertBtcIntoDollor(value: Int) -> Int{
        return value / 50000
    }
    
    func clearQueue(){
        transactionQueue.removeAll()
        delegate?.didRecievedTransaction()
    }
    
    func getReadableDate(timeStamp:Int) -> String{
        let date = Date(timeIntervalSince1970: Double(timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        return dateFormatter.string(from: date)
    }
    
}

extension SocketViewModel:WebSocketDelegate{
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected")
        delegate?.connected(msg: "Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("DisConnected")
        delegate?.disconnected(msg: "Disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
        let jsonData = Data(text.utf8)
        do {
            let transaction = try JSONDecoder().decode(Transaction.self, from: jsonData) // decode the response into model
            if transactionQueue.count < 5 && convertBtcIntoDollor(value: transaction.x.out.first?.value ?? 0) > 100{
                transactionQueue.append(transaction)
            }
            else if transactionQueue.count >= 5 && convertBtcIntoDollor(value: transaction.x.out.first?.value ?? 0) > 100{
                transactionQueue.remove(at: 0)
                transactionQueue.append(transaction)
            }
            delegate?.didRecievedTransaction()
        }
        catch let err {
            print(err)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print(data)
    }
    
    
}
