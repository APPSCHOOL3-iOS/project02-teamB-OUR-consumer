//
//  FeedStore.swift
//  project02-teamB-OUR-consumer
//
//  Created by Handoo Jeong on 2023/08/22.
//

import Foundation
class FeedStore: ObservableObject {
    var id: UUID = UUID()
    var postId: String
    var numberOfComments: Int
    var numberOfLike: Int
    var numberOfRepost: Int
    var content: String
    
    init(id: UUID, postId: String, numberOfComments: Int, numberOfLike: Int, numberOfRepost: Int, content: String) {
        self.id = id
        self.postId = postId
        self.numberOfComments = numberOfComments
        self.numberOfLike = numberOfLike
        self.numberOfRepost = numberOfRepost
        self.content = content
    }
    
}
