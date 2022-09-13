//
//  VoiceRoomGiftersController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/9/9.
//

import UIKit
import ZSwiftBaseLib

public class VoiceRoomGiftersViewController: UITableViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView(UIView()).registerCell(VoiceRoomGifterCell.self, forCellReuseIdentifier: "VoiceRoomGifterCell").rowHeight(73).backgroundColor(.white).separatorInset(edge: UIEdgeInsets(top: 72, left: 15, bottom: 0, right: 15)).separatorColor(UIColor(0xF2F2F2)).showsVerticalScrollIndicator(false)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    public override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "VoiceRoomGifterCell") as? VoiceRoomGifterCell
        if cell == nil {
            cell = VoiceRoomGifterCell(style: .default, reuseIdentifier: "VoiceRoomGifterCell")
        }
        // Configure the cell...
        cell?.selectionStyle = .none
        return cell ?? VoiceRoomGifterCell()
    }
    


}
