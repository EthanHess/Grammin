//
//  StoryViewersContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 1/26/23.
//  Copyright © 2023 EthanHess. All rights reserved.
//

import UIKit

class StoryViewersContainer: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var viewers : [User] = []
    
    let table : UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        renderTable()
    }
    
    fileprivate func renderTable() {
        //register
        let cellID = "theCell"
        table.register(StoryViewerCell.self, forCellReuseIdentifier: cellID)
        table.dataSource = self
        table.delegate = self
        
    }
    
    func loadViewers(_ viewers: [User]) {
        self.viewers = viewers
        refreshData()
    }
    
    fileprivate func refreshData() {
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

typealias TableFunctions = UITableViewDelegate & UITableViewDataSource

extension StoryViewersContainer: TableFunctions {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theCell = tableView.dequeueReusableCell(withIdentifier: "theCell") as! StoryViewerCell
        
        //Config
        
        return theCell
    }
}
