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
    func convertBtcIntoDollor(value: Int) -> Int{
        return value / 50000
    }
    
    func clearQueue(){
        transactionQueue.removeAll()
        delegate?.didRecievedTransaction()
    }
    
    func getReadableDate(timeStamp: TimeInterval) -> String? {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        
        if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else if dateFallsInCurrentWeek(date: date) {
            if Calendar.current.isDateInToday(date) {
                dateFormatter.dateFormat = "h:mm a"
                return dateFormatter.string(from: date)
            } else {
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter.string(from: date)
            }
        } else {
            dateFormatter.dateFormat = "dd-mm-yyyy hh:mm:ss"
            return dateFormatter.string(from: date)
        }
    }
    
    func dateFallsInCurrentWeek(date: Date) -> Bool {
        let currentWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: Date())
        let datesWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: date)
        return (currentWeek == datesWeek)
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
