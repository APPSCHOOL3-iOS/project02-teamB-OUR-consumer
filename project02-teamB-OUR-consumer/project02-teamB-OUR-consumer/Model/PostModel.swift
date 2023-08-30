//
//  PostModel.swift
//  project02-teamB-OUR-consumer
//
//  Created by SONYOONHO on 2023/08/29.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

// 데이터베이스에서 가져오는 모델
struct Post: Codable, Identifiable {
    @DocumentID var id: String?
    var creator: String
    var privateSetting: Bool
    var content: String
    var createdAt: String
    var location: String
    var postImagePath: [String]
    var reportCount: Int
    var like: [String]
    var isRepost: Bool?
}


struct PostModel: Identifiable {
    var id: String?
    var creator: User
    var privateSetting: Bool
    var content: String
    var createdAt: String
    var location: String
    var postImagePath: [String]
    var reportCount: Int
    var isRepost: Bool?
    var numberOfComments: Int?
    var numberOfLike: Int
    var numberOfRepost: Int?
    var isLiked: Bool
    var comment: [PostComment]?
}

struct PostComment {
    @DocumentID var id: String?
    var userId: String
    var content: String
    var createdAt: String
    
    init(userId: String, content: String) {
        self.userId = userId
        let timestamp = Timestamp(date: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년MM월dd일 HH:mm"
        self.createdAt = formatter.string(from: timestamp.dateValue())
        self.content = content
    }
}

extension Post {
    static var samplePost = Post(id: "1m0tjsoBQ1mnn2Ag7WYz", creator: "leeseungjun", privateSetting: false, content: "fdsfsdfd", createdAt: "2023-08-30 11:22:49", location: "ddd", postImagePath: ["https://firebasestorage.googleapis.com:443/v0/b/our-app-server.appspot.com/o/FeedPosts%2FfKRz5KdcxnLpKhIBGb24%2F999BD351-5075-4E30-AFFC-0F4086FE6973.jpeg?alt=media&token=11a75b01-842a-499a-a070-adedc8c7da2c"], reportCount: 0, like: ["eYebZXFIGGQFqYt1fI4v4M3efSv2"])
}

extension PostModel {
    static var samplePostModel = PostModel(creator: User.defaultUser, privateSetting: false, content: "", createdAt: "", location: "", postImagePath: [""], reportCount: 0, numberOfLike: 0, isLiked: false)
}

extension User {
    static var defaultUser: User {
        return User(name: "test", email: "test@gamil.com")
    }
}

struct FollowerData: Codable {
    let follower: [String]
}

struct LikedUsers: Codable {
    let userID: String
    var createdAt: String
    
    init(userID: String) {
        self.userID = userID
        let timestamp = Timestamp(date: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        self.createdAt = formatter.string(from: timestamp.dateValue())
    }
}
