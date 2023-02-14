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
        let tv = UITableView(frame: .zero, style: .grouped)
        return tv
    }()
    
    //Change alpha
    let slider : UISlider = {
        let sl = UISlider()
        return sl
    }()
    
    //This should be done on main thread (updating title)
    let segController : UISegmentedControl = {
        let sc = UISegmentedControl()
        sc.insertSegment(withTitle: "Viewers", at: 0, animated: true)
        sc.insertSegment(withTitle: "Chat", at: 1, animated: true)
        return sc
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
        let stackView = UIStackView(arrangedSubviews: [slider, segController])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: table.topAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
        
        slider.addTarget(self, action: #selector(sliderValueChanged(sender: )), for: .valueChanged)
        segController.addTarget(self, action: #selector(segmentSelected(sender: )), for: .valueChanged)
    }
    
    @objc fileprivate func sliderValueChanged(sender: UISlider) {
        let newVal = sender.value
        self.backgroundColor = Colors().aquarium.withAlphaComponent(CGFloat(newVal))
    }
    
    @objc fileprivate func segmentSelected(sender: UISegmentedControl) {
        let newVal = sender.selectedSegmentIndex
        if newVal == 0 {
            table.isHidden = false
        } else {
            table.isHidden = true
            loadChat()
        }
    }
    
    fileprivate func loadChat() {
        
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
