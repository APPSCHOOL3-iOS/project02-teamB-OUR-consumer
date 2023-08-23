//
//  PostView.swift
//  project02-teamB-OUR-consumer
//
//  Created by 이승준 on 2023/08/22.
//

import SwiftUI

struct PostView: View {
    
    @ObservedObject var post: FeedStore
    
    @State var isSpreadBtn: Bool = false
    @State var lineLimitNumber: Int = 2
    
    var body: some View {
        
        VStack {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom, spacing: 10) {
                    Text("\(post.content)")
                        .lineLimit(lineLimitNumber)
                    Button {
                        isSpreadBtn.toggle()
                        lineLimitNumber = isSpreadBtn ? 10 : 2
                    } label: {
                        Text("\(isSpreadBtn ? "접기" : "더보기")")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                HStack() {
                    Spacer()
                    Button {
                        // 좋아요 카운트
                    } label: {
                        Text("좋아요 \(post.numberOfLike)")
                    }
                    Button {
                        // 댓글 카운트
                    } label: {
                        Text("댓글 \(post.numberOfComments)")
                    }
                    Button {
                        // 퍼감 카운트
                    } label: {
                        Text("퍼감 \(post.numberOfRepost)")
                    }
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()
            }
        }
        
        
    }
}


struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PostView(post: FeedStore(id: UUID(), postId: "leeseungjun", numberOfComments: 3, numberOfLike: 23, numberOfRepost: 4, content: "축구...어렵네..."))
        }
    }
}
