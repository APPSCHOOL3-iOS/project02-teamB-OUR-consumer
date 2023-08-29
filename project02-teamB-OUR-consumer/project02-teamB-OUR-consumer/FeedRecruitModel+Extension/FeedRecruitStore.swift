//
//  FeedRecruitStore.swift
//  project02-teamB-OUR-consumer
//
//  Created by kaikim on 2023/08/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import PhotosUI
import _PhotosUI_SwiftUI

class FeedRecruitStore: ObservableObject {
    let service = RecruitService()
    
    @Published var feedStores: [FeedRecruitModel] = []
    
    let dbRef = Firestore.firestore().collection("posts")
    
    func fetchFeeds() {
        
        service.fetchAll(collection: .posts) { results in
            self.feedStores = results
        }
    }
    
    func addFeed( _ data: FeedRecruitModel ) {
        service.add(collection: .posts, data: data)
    }
    
    
    func updateData( docID: String, _ data: FeedRecruitModel ) {
        service.update(collection: .posts, documentID: docID, data: data)
    }
    
    
    
    
    //    func fetchFeeds() {
    //
    //        dbRef.getDocuments { (snapshot, error) in
    //
    //            self.feedStores.removeAll()
    //
    //            if let snapshot {
    //                var tempFeeds: [FeedRecruitModel] = []
    //
    //                for document in snapshot.documents {
    //                    let id: String = document.documentID
    //                    let docData: [String: Any] = document.data()
    //                    let creator: String = docData["creator"] as? String ?? ""
    //                    let content: String = docData["content"] as? String ?? ""
    //                    let location: String = docData["location"] as? String ?? ""
    //                    let privateSetting: Bool = docData["privateSetting"] as? Bool ?? false
    //                    let createdAt: Double = docData["createdDate"] as? Double ?? 0.0
    //                    let reportCount: Int  = docData["reportCount"] as? Int ?? 0
    //                    let studyImagePath: String = docData["studyImagePath"] as? String ?? ""
    //
    //                    let feeds = FeedRecruitModel(id: id, creator: creator, content: content, location: location, privateSetting: privateSetting, reportCount: reportCount , createdAt: createdAt, feedImagePath: studyImagePath)
    //
    //                    tempFeeds.append(feeds)
    //                }
    //
    //                self.feedStores  = tempFeeds
    //            }
    //        }
    //    }
    //
    //
    //    func addFeed(_ feed: FeedRecruitModel) {
    //
    //        dbRef.document(feed.id)
    //            .setData([
    //                "id": feed.id,
    //                "creator": feed.creator,
    //                "content": feed.content,
    //                "location": feed.location,
    //                "privateSetting": feed.privateSetting,
    //                "createdAt": feed.createdDate,
    //                "reportCount": feed.reportCount,
    //                "studyImagePath": feed.feedImagePath])
    //
    //        fetchFeeds()
    //    }
    //
    //
    //    func removeFeed(_ feed: FeedRecruitModel) {
    //
    //        dbRef.document(feed.id).delete()
    //
    //        fetchFeeds()
    //    }
    
    //이미지 FireBase Storage에 Save.
    
    
    
    func returnImagePath(items: [PhotosPickerItem]) async throws -> [String]{
        
        var urlString:[String] = []
        
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else {return urlString}
            let (_, _, url) = try await FeedStorageManager.shared.saveImage(data: data, id: dbRef.document().documentID)
            urlString.append(url.absoluteString)
        }
    
        return urlString
        
        
        
    }

    func saveStudyImage(item: PhotosPickerItem) {
        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let (path, name, url) = try await FeedStorageManager.shared.saveImage(data: data, id: dbRef.document().documentID)
            print("SUCCESS!!!!")
            print("path : \(path)")
            print("name : \(name)")
            print("url : \(url)")
        }
    }
    
    //
    //    func convertLocationToAddress(location: CLLocation) async throws -> String {
    //
    //        var test:String = ""
    //        let geocoder = CLGeocoder()
    //        let locale = Locale(identifier: "en_US_POSIX")
    //
    //        let data = try await geocoder.reverseGeocodeLocation(location, preferredLocale: locale)
    //
    //        test = "\(data.first?.country ?? ""), \(data.first?.locality ?? ""), \(data.first?.name ?? "")"
    //        print(test)
    //        return test
    //    }
    //
    
    
    
    
    
    
    
    
}
