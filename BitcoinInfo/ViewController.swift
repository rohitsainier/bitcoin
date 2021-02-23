//
//  ViewController.swift
//  BitcoinInfo
//
//  Created by Rohit Saini on 23/02/21.
//

import UIKit
import Starscream

class ViewController: UIViewController {
    
    @IBOutlet weak var connectionLbl: UILabel!
    
    private var socketVM: SocketViewModel = SocketViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        socketVM.delegate = self
        socketVM.connect()
    }
}

extension ViewController: SocketEventDelegate{
    func connected(msg: String) {
        connectionLbl.text = msg
        socketVM.subscribeTransaction()
    }
    
    func disconnected(msg: String) {
        connectionLbl.text = msg
    }
    
    func didRecievedTransaction(response: Transaction) {
        print(response.op)
    }
    
    
}


