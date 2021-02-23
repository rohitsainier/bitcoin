//
//  ViewController.swift
//  BitcoinInfo
//
//  Created by Rohit Saini on 23/02/21.
//

import UIKit
import Starscream

class ViewController: UIViewController{
    
    @IBOutlet weak var connectionLbl: UILabel!

    @IBOutlet weak var tableView: UITableView!
    
    private var socketVM: SocketViewModel = SocketViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configUI()
        
    }
    
    private func configUI(){
        socketVM.delegate = self
        socketVM.connect()
        tableView.register(UINib(nibName: "InfoCell", bundle: nil), forCellReuseIdentifier: "InfoCell")
    }
    
    @IBAction func cleatBtn(_ sender: UIButton) {
        socketVM.clearQueue()
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else{return}
            self.tableView.reloadData()
        }
    }
    
}

//MARK: - TableView DataSource and Delegate Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {

    // heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return socketVM.transactionQueue.count
    }
    
    // cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as? InfoCell
        else {
            return UITableViewCell()
        }
        if socketVM.transactionQueue.count <= 0{
            return UITableViewCell()
        }
        cell.hashLbkl.text = "\(socketVM.transactionQueue[indexPath.row].x.hash)"
        cell.amountLbl.text = "$\(socketVM.transactionQueue[indexPath.row].x.out.first?.value ?? 0)"
        cell.timeLbl.text = socketVM.getReadableDate(timeStamp: TimeInterval(socketVM.transactionQueue[indexPath.row].x.time))
        return cell
    }
}

extension ViewController: SocketEventDelegate{
    func didRecievedTransaction() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else{return}
            self.tableView.reloadData()
        }
    }
    
    func connected(msg: String) {
        connectionLbl.text = msg
        socketVM.subscribeTransaction()
    }
    
    func disconnected(msg: String) {
        connectionLbl.text = msg
    }
    
}


