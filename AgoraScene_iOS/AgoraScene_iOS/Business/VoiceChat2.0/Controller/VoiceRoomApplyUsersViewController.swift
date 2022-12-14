//
//  VoiceRoomApplyUsersViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/9/11.
//

import UIKit
import ZSwiftBaseLib
import ProgressHUD

public class VoiceRoomApplyUsersViewController: UITableViewController {
    
    private var apply: VoiceRoomApplyEntity?
    
    private var roomId: String?
    
    lazy var empty: VREmptyView = {
        VREmptyView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 360), title: "No one raised hands yet", image: nil).backgroundColor(.white)
    }()
    
    public convenience init(roomId:String) {
        self.init()
        self.roomId = roomId
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubview(self.empty, belowSubview: self.tableView)
        self.tableView.tableFooterView(UIView()).registerCell(VoiceRoomApplyCell.self, forCellReuseIdentifier: "VoiceRoomApplyCell").rowHeight(73).backgroundColor(.white).separatorInset(edge: UIEdgeInsets(top: 72, left: 15, bottom: 0, right: 15)).separatorColor(UIColor(0xF2F2F2)).showsVerticalScrollIndicator(false).backgroundColor(.clear)
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refresh()
    }

    // MARK: - Table view data source

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.apply?.apply_list?.count ?? 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "VoiceRoomApplyCell", for: indexPath) as? VoiceRoomApplyCell
        if cell == nil {
            cell = VoiceRoomApplyCell(style: .default, reuseIdentifier: "VoiceRoomApplyCell")
        }
        // Configure the cell...
        cell?.selectionStyle = .none
        cell?.refresh(item: self.apply?.apply_list?[safe: indexPath.row])
        cell?.agreeClosure = { [weak self] in
            self?.agreeUserApply(user: $0)
            self?.apply?.apply_list?[safe: indexPath.row]?.member?.invited = true
            self?.tableView.reloadData()
        }
        return cell ?? VoiceRoomApplyCell()
    }

    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.apply?.cursor != nil,(self.apply?.apply_list?.count ?? 0) - 2 == indexPath.row, (self.apply?.total ?? 0) >= (self.apply?.apply_list?.count ?? 0) {
            self.fetchUsers()
        }
    }
    
}


extension VoiceRoomApplyUsersViewController {
    
    @objc func refresh() {
        self.apply = nil
        self.fetchUsers()
    }
    
    @objc private func fetchUsers() {
        VoiceRoomBusinessRequest.shared.sendGETRequest(api: .fetchApplyMembers(roomId: self.roomId ?? "", cursor: self.apply?.cursor ?? "", pageSize: 15), params: [:], classType: VoiceRoomApplyEntity.self) { model, error in
            self.tableView.refreshControl?.endRefreshing()
            if model != nil,error == nil {
                if self.apply == nil {
                    self.apply = model
                } else {
                    self.apply?.cursor = model?.cursor
                    self.apply?.apply_list?.append(contentsOf: model?.apply_list ?? [])
                }
                self.tableView.reloadData()
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
            self.empty.isHidden = (self.apply?.apply_list?.count ?? 0 != 0)
        }
    }
    
    private func agreeUserApply(user: VoiceRoomApply?) {
        ProgressHUD.show()
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .agreeApply(roomId: self.roomId ?? ""), params: ["uid":user?.member?.uid ?? ""]) { dic, error in
            ProgressHUD.dismiss()
            if dic != nil,error == nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("Agree success!".localized())
                } else {
                    self.view.makeToast("Agree failed!".localized())
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
}
