//
//  StoryViewersContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 1/26/23.
//  Copyright © 2023 EthanHess. All rights reserved.
//

import UIKit

class StoryViewersContainer: UIView {
    
    var userCache : [String: User] = [:]
    var viewerIDs : [String] = [] //Will load user one at a time as user scrolls, may be more efficient
    
    let table : UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        backgroundColor = Colors().aquarium
        layer.cornerRadius = 5
    }
    
    fileprivate func renderTable() {
        //register
        let cellID = "theCell"
        table.register(StoryViewerCell.self, forCellReuseIdentifier: cellID)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        let tableFrame = CGRectMake(20, 60, frame.size.width - 40, frame.size.height - 80)
        table.frame = tableFrame
        addSubview(table)
        
        addTopViews()
    }
    
    //Alpha slider + chat toggle button
    fileprivate func addTopViews() {
        
    }
    
    func loadViewers(_ viewers: [String]) {
        renderTable()
        self.viewerIDs = viewers
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
        return viewerIDs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theCell = tableView.dequeueReusableCell(withIdentifier: "theCell") as! StoryViewerCell
        
        let idAtIndexPath = viewerIDs[indexPath.row]
        theCell.subviewConfig()
        if let theUser = userCache[idAtIndexPath] {
            theCell.user = theUser
        } else {
            FirebaseController.fetchUserWithUID(userID: idAtIndexPath) { user in
                if user != nil {
                    theCell.user = user
                    self.userCache[idAtIndexPath] = user
                }
            }
        }
        
        return theCell
    }
}
