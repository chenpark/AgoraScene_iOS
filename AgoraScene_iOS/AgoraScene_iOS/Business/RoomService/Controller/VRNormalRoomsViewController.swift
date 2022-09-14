//
//  VRNormalRoomsViewController.swift
//  AgoraScene_iOS
//
//  Created by 朱继超 on 2022/9/14.
//

import UIKit
import ZSwiftBaseLib

public class VRNormalRoomsViewController: UIViewController {
    
    public var didSelected: ((VRRoomEntity) -> ())?
    
    public var totalCountClosure: ((Int) -> ())?
            
    lazy var empty: VREmptyView = {
        VREmptyView(frame: CGRect(x: 0, y: 10, width: ScreenWidth, height: self.view.frame.height - 10 - CGFloat(ZBottombarHeight) - 30), title: "No Chat Room yet", image: nil)
    }()
    
    lazy var roomList: VRRoomListView = {
        VRRoomListView(frame: CGRect(x: 0, y: 10, width: ScreenWidth, height: self.view.frame.height - 10 - CGFloat(ZBottombarHeight) - 30), style: .plain)
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchRooms(cursor: self.roomList.rooms?.cursor ?? "")
        self.view.addSubViews([self.empty,self.roomList])
        // Do any additional setup after loading the view.
        self.roomListEvent()
    }
    

    

}

extension VRNormalRoomsViewController {
    
    private func fetchRooms(cursor: String) {
        VoiceRoomBusinessRequest.shared.sendGETRequest(api: .fetchRoomList(cursor: cursor, pageSize: page_size,type: 1), params: [:], classType: VRRoomsEntity.self) { rooms, error in
            if error == nil {
                guard let total = rooms?.total else { return }
                if total > 0 {
                    self.fillDataSource(rooms: rooms)
                    self.roomList.reloadData()
                }
                if self.totalCountClosure != nil {
                    self.totalCountClosure!(total)
                }
                self.empty.isHidden = (total > 0)
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func fillDataSource(rooms: VRRoomsEntity?) {
        if self.roomList.rooms == nil {
            self.roomList.rooms = rooms
        } else {
            self.roomList.rooms?.total = rooms?.total
            self.roomList.rooms?.cursor = rooms?.cursor
            self.roomList.rooms?.rooms?.append(contentsOf: rooms?.rooms ?? [])
        }
    }
    
    private func roomListEvent() {
        self.roomList.didSelected = { [weak self] in
            guard let `self` = self else { return }
            if self.didSelected != nil { self.didSelected!($0) }
        }
        self.roomList.loadMore = { [weak self] in
            if self?.roomList.rooms?.total ?? 0 > self?.roomList.rooms?.rooms?.count ?? 0 {
                self?.fetchRooms(cursor: self?.roomList.rooms?.cursor ?? "")
            }
        }
    }
}