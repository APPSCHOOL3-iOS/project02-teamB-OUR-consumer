//
//  AlramViewModel.swift
//  project02-teamB-OUR-consumer
//
//  Created by 박형환 on 2023/08/22.
//

import SwiftUI
import Firebase
import Combine


typealias ASection = String
typealias NotiItem = [ASection : [NotificationItem]]

class AlarmViewModel: ObservableObject{
    
    private var service: AlarmFireService
    private var userId: ID?
    var user: User?

    @Published var hasUnreadData: Bool = false // 뱃지 표시 여부
    @Published var personalNotiItem: NotiItem = [:]
    @Published var publicNotiItem: NotiItem = [:]
    
    struct Dependency{
        let alarmFireSerivce: AlarmFireService
        
    }
    
    init(dependency: Dependency){
        self.service = dependency.alarmFireSerivce
        
        self.userId = dependency.alarmFireSerivce.userId
        
        if let userID = self.userId{
            dependency.alarmFireSerivce.fetchUser(userId: userID, completion: {[weak self] user in
                guard let self else { return }
                self.user = user
            })
        }
        
        if let hasUnreadData = UserDefaults.standard.value(forKey: "hasUnreadData") as? Bool {
            self.hasUnreadData = hasUnreadData
        }
        observingNotification()
    }
    
    
    func observingNotification(){
        service.observingNotification(completion: { [weak self] snapshot, error in
            guard let self else { return }
            if let snapshot = snapshot?.documentChanges{
                let value = snapshot.compactMap { change in
                    let value = try? change.document.data(as: NotificationDTO.self)
                    return value
                }.filter{ value in value.userId != self.userId}
                
                if !value.isEmpty{
                    let items = self.mappingTOexistList(dto: value)
                    // UserDefaults에 알람 상태를 저장합니다.
                    UserDefaults.standard.setValue(self.hasUnreadData, forKey: "hasUnreadData")
                    // 읽지 않은 알림이 있는지 확인하여 뱃지 표시 여부 결정
                    self.hasUnreadData = !items.allSatisfy { $0.isRead }
                }
            }
        })
    }
    
    
    /// 알림 생성하는 함수 : 알림의 Type 과 Content를 인자로 전달 --> 파이어베이스 notifications path에 저장하게 됩니다.
    /// - Parameters:
    ///   - type: 알림의 종류 EX) study 참여,포스팅 좋아요 등
    ///   - content: 알림 메시지 Content , name
    func sendNotification(userId: ID ,type: NotificationType){
        let userId = userId //userViewModel.user?.id else { return }
        let content: String
        
        if let name = self.user?.name{
            content = "@" + name + " 님이" + type.content
        }else{
            content = "@" + "장수지" + " 님이" + type.content
        }
        
        let dto = NotificationDTO(userId: userId, type: type.value, content: content, isRead: false, createdDate: Date())
        
        service.create(send: dto, completion: { result in
            print("저장성공")
        })
    }
    
    
    // 모든 알람을 읽은 상태로 만드는 메서드
    func markAllAsRead() {
        personalNotiItem = markNotificationsAsRead(personalNotiItem)
        publicNotiItem = markNotificationsAsRead(publicNotiItem)
        hasUnreadData = false
        UserDefaults.standard.setValue(hasUnreadData, forKey: "hasUnreadData")
    }
    
    private func markNotificationsAsRead(_ notifications: NotiItem) -> NotiItem {
        var newNotiItem: NotiItem = [:]
        var idsToUpdate: [String] = []
        
        for (key, notificationList) in notifications {
            newNotiItem[key] = notificationList.map { notification in
                var newNotification = notification
                if !newNotification.isRead {
                    idsToUpdate.append(newNotification.id)
                    newNotification.isRead = true
                }
                return newNotification
            }
        }
        // 뱃지 업데이트
        if !idsToUpdate.isEmpty {
            update(isReads: idsToUpdate)
        }
        return newNotiItem
    }
    
    func fetchNotificationItem(limit: Int = 10) {
        
        guard let myID = UserDefaults.standard.string(forKey: Keys.userId.rawValue) else {
            return }
        
        service.fetchUser(userId: myID) { [weak self] user in
            guard let self else { return }
            if let followingsIds = user.following{
                service.read(followingsIDs: followingsIds, completion: { [weak self] result in
                    guard let self else {return }
                    switch result{
                    case .success(let notificationDTO):
                        
                        let items = self.mappingToDTO(dto: notificationDTO)
                        // UserDefaults에 알람 상태를 저장합니다.
                        UserDefaults.standard.setValue(self.hasUnreadData, forKey: "hasUnreadData")
                        
                        // 읽지 않은 알림이 있는지 확인하여 뱃지 표시 여부 결정
                        self.hasUnreadData = !items.allSatisfy { $0.isRead }
                        
                        // 이 부분도 로깅으로 확인
                        print("hasUnreadData updated to: \(self.hasUnreadData)")
                    case .failure(let error):
                        print("error: \(error) -- \(#function)")
                    }
                })
            }
        }
    }
    
    
    
    
    func delete(notification set: IndexSet?, access: NotificationType.Access, key: ASection){
        if let set{
            var willDeleteIds: [ID] = []
            
            switch access {
            case .public:
                for index in set{
                    willDeleteIds.append(self.publicNotiItem[key]![index].id)
                }
            case .personal:
                for index in set{
                    willDeleteIds.append(self.personalNotiItem[key]![index].id)
                }
            case .none:
                return
            }
            
            service.delete(ids: willDeleteIds, completion: { string in
                switch access {
                case .public:
                    // 여기에서 메모리 에 있는 데이터 삭제
                    var values = self.publicNotiItem[key]!
                    values.remove(atOffsets: set)
                    self.publicNotiItem[key] = values
                    
                case .personal:
                    // 여기에서 메모리 에 있는 데이터 삭제
                    var values = self.personalNotiItem[key]!
                    values.remove(atOffsets: set)
                    self.personalNotiItem[key] = values
                case .none:
                    return
                }
            })
        }
    }
    
    func delete(ids: [ID]){
        service.delete(ids: ids, completion: { string in
            print("Delete Success \(string)")
        })
    }
    
    
    // notification의 id로 탐색을 할것인가....
    func update(isRead id: ID){
        service.update(id: id, completion: { err in
            if err != nil{
                print("failed update")
            }else{
                print("success update")
            }
        })
    }
    
    func update(isReads ids: [ID]){
        service.update(ids: ids, completion: { err in
            if err != nil{
                print("failed update")
            }else{
                print("success update")
            }
        })
    }
    
    private var cancelable = Set<AnyCancellable>()
    
    func addNewNotification() {
        // 새로운 알림 데이터를 생성
        let newNotification = NotificationDTO(
            userId: "Y7f1tHkuWcWcEQDd461PAumjobn2",
            type: "follow",
            content: "장수지님이 팔로우 하였습니다.",
            isRead: false,
            createdDate: "2023-08-29 13:50:39".toDate() // 현재 날짜와 시간을 설정
        )
        
        print("newNotification: \(newNotification)")
        
        // Firestore 서비스를 통해 데이터를 추가
        service.create(send: newNotification) { result in
            print("result failed")
            if result == "success" {  // 예시: 성공 시 "success" 문자열 반환
                print("New notification added successfully.")
            } else {
                print("Failed to add new notification.")
            }
        }
    }
    
    
    private func getUser(user id: ID) -> User?{
        
        guard
            let sampleUserName = ["박형환","박찬호","장수지"].randomElement()
        else {return nil}
        
        return User(id: nil, name: sampleUserName, email: "", profileImage: nil, profileMessage: nil, follower: nil, following: nil)
    }
    
    
    private func mappingTOexistList(dto: [NotificationDTO]) -> [NotificationItem] {
        let items = dto.compactMap { $0.toDomain(user: self.getUser(user: $0.userId) ?? User(name: "", email: "", profileImage: "", profileMessage: "")) }
        let models = self.mapToDictionary(items: items)
        
        for (key,item) in models.0{
            if let value = self.personalNotiItem[key]{
                self.personalNotiItem[key]?.append(contentsOf: item)
            }else{
                self.personalNotiItem[key] = item
            }
        }
        for (key,item) in models.1{
            if let value = self.publicNotiItem[key]{
                self.publicNotiItem[key]?.append(contentsOf: item)
            }else{
                self.publicNotiItem[key] = item
            }
        }
        return items
    }
    
    private func mappingToDTO(dto: [NotificationDTO]) -> [NotificationItem] {
        let items = dto.compactMap { $0.toDomain(user: self.getUser(user: $0.userId) ?? User(name: "", email: "", profileImage: "", profileMessage: "")) }
        let models = self.mapToDictionary(items: items)
        self.personalNotiItem = models.0
        self.publicNotiItem = models.1
        return items
    }
    
    
    /// Mapping To View Model
    /// - Parameter items: notification Item
    /// - Returns: public , personal
    private func mapToDictionary(items: [NotificationItem]) -> (NotiItem,NotiItem){
        return items.reduce(into: (NotiItem(),NotiItem()), { original, models in
            let item = models
            if item.type.getAccessLevel() == .personal{
                let dotDate = item.createdDate.dotString()
                if let items = original.0[dotDate]{
                    original.0[dotDate] = items + [item]
                }else{
                    original.0[dotDate] = [item]
                }
            }else {
                let dotDate = item.createdDate.dotString()
                if let items = original.1[dotDate]{
                    original.1[dotDate] = items + [item]
                }else{
                    original.1[dotDate] = [item]
                }
            }
        })
    }
}





struct DummyModel{
    static func getPersonalRandom() -> [NotificationDTO]{
        return [
            NotificationDTO(userId: UUID().uuidString,
                            type: "follow",
                            content: "장수지님이 팔로잉했습니다.",
                            isRead: false,
                            createdDate: "2023-08-21 13:50:39".toDate()),
            
            NotificationDTO(
                userId: UUID().uuidString,
                type: "like",
                content: "박형환님이 게시물을 좋아합니다.",
                isRead: false,
                createdDate: "2022-08-23 13:50:39".toDate()),
            
            NotificationDTO(
                userId: UUID().uuidString,
                type: "comments",
                content: "박찬호님이 댓글을 남겼습니다.",
                isRead: false,
                createdDate: "2023-08-21 13:50:39".toDate())
        ]
    }
    
    
    static func getPersonal() -> [NotificationDTO]{
        return [
            NotificationDTO(
                userId: UUID().uuidString,
                type: "follow",
                content: "박찬호님이 팔로잉했습니다.",
                isRead: false,
                createdDate: "2023-08-21 13:50:39".toDate()),
            
            NotificationDTO(
                userId: UUID().uuidString,
                type: "like",
                content: "장수지님이 게시물을 좋아합니다.",
                isRead: false,
                createdDate: "2022-08-23 13:50:39".toDate()),
            
            NotificationDTO(
                userId: UUID().uuidString,
                type: "comments",
                content: "박형환님이 댓글을 남겼습니다.",
                isRead: false,
                createdDate: "2023-08-21 13:50:39".toDate()),
            
            NotificationDTO(
                userId: UUID().uuidString,
                type: "follow",
                content: "박찬호님이 팔로잉했습니다.",
                isRead: false,
                createdDate: "2023-06-21 13:50:39".toDate())
        ]
    }
    
    static func getPublic() -> [NotificationDTO]{
        return [
            NotificationDTO(
                userId: UUID().uuidString,
                type: "studyGrops",
                content: "박형환님이 @Study_X에 가입했습니다.",
                isRead: false,
                createdDate: "2023-06-21 13:50:39".toDate()),
            NotificationDTO(
                userId: UUID().uuidString,
                type: "studyGroupComments",
                content: "장수지님이 @Study_Y에 댓글을 남겼습니다.",
                isRead: false,
                createdDate: "2023-06-21 13:50:39".toDate()),
            NotificationDTO(
                userId: UUID().uuidString,
                type: "studyGroupComments",
                content: "박찬호님이 @Study_Z에 댓글을 남겼습니다.",
                isRead: false,
                createdDate: "2022-06-21 13:50:39".toDate())
        ]
    }
}
