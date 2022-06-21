//
//  SearchUserViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 12/30/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

//Replaces the collection view, since Table would be better

class SearchUserViewController: UIViewController {
    
    let cellID = "cell"
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerTableView()
    }
    
    fileprivate func registerTableView() {
        let frame = CGRect(x: 10, y: 100, width: view.frame.size.width - 20, height: view.frame.size.height - 150)
        tableView.frame = frame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserSearchTableViewCell.self, forCellReuseIdentifier: cellID)
        view.addSubview(tableView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theCell = tableView.dequeueReusableCell(withIdentifier: cellID) as! UserSearchTableViewCell
        return theCell
    }
}
