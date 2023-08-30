//
//  viewModel.studyDetailView.swift
//  project02-teamB-OUR-consumer
//
//  Created by yuri rho on 2023/08/22.
//

import SwiftUI
import CoreLocation

struct StudyDetailView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @StateObject var viewModel: StudyViewModel
    var study: StudyDTO
    
    @State private var isShowingStudyMemberSheet: Bool = false
    @State var isShowingLocationSheet: Bool = false
    @State var isShowingReportSheet: Bool = false
    @Binding var isSavedBookmark: Bool
    @State var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack {
                    if viewModel.studyDetail.imageString != nil {
                        AsyncImage(url: URL(string: viewModel.studyDetail.imageString!)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity)
                        .overlay(alignment:.bottom) {
                            VStack(alignment: .center, spacing: 10) {
                                Text(viewModel.studyDetail.creator.name)
                                    .font(.system(size: 14, weight: .semibold))
                                Text(viewModel.studyDetail.title)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .padding(15)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color(red: 215 / 255, green: 215 / 255, blue: 215 / 255), radius: 5)
                            .padding(.horizontal, 20)
                            .offset(y:30)
                        }
                    } else {
                        Image("OUR_Logo")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .overlay(alignment:.bottom) {
                                VStack(alignment: .center, spacing: 10) {
                                    Text(viewModel.studyDetail.creator.name)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(viewModel.studyDetail.title)
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .padding(15)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: Color(red: 215 / 255, green: 215 / 255, blue: 215 / 255), radius: 5)
                                .padding(.horizontal, 20)
                                .offset(y:30)
                            }
                    }
                    
                    VStack {
                        VStack {
                            Spacer(minLength: 20)
                            Text(viewModel.studyDetail.description)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(3)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: viewModel.studyDetail.isOnline ? "macbook.and.iphone" : "mappin.and.ellipse" )
                                    .frame(width: 20)
                                Text(viewModel.studyDetail.isOnline ? "\(viewModel.studyDetail.linkString ?? "")" : "\(viewModel.studyDetail.locationName ?? "")")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
//                            MARK: 위치시트 보기 위함 테스트 후에 변경해야함
//                                if !viewModel.studyDetail.isOnline {
                                if viewModel.studyDetail.isOnline {
                                    Button {
                                        isShowingLocationSheet = true
                                    } label: {
                                        Text("위치보기")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(.black)
                                            .padding(3)
                                            .border(Color(red: 215 / 255, green: 215 / 255, blue: 215 / 255))
                                            .background(Color(red: 215 / 255, green: 215 / 255, blue: 215 / 255))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                            
                            HStack {
                                Image(systemName: "person.3.fill" )
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20)
                                Text("최대 \(viewModel.studyDetail.totalMemberCount)명 (\(viewModel.studyDetail.currentMembers.count)/\(viewModel.studyDetail.totalMemberCount))")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                Button {
                                    isShowingStudyMemberSheet.toggle()
                                } label: {
                                    Text("멤버보기")
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundColor(.black)
                                        .padding(3)
                                        .border(Color(red: 215 / 255, green: 215 / 255, blue: 215 / 255))
                                        .background(Color(red: 215 / 255, green: 215 / 255, blue: 215 / 255))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.bottom, 5)
                            
                            HStack{
                                Image(systemName: "calendar" )
                                    .frame(width: 20)
                                Text(viewModel.studyDetail.studyDate)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            .padding(.bottom, 10)
                            
                            HStack {
                                if isMyStudy() {
                                    Button {
                                        //MARK: 스터디 게시글 수정
                                    } label: {
                                        Text("수정")
                                            .bold()
                                            .frame(width: 180, height: 40)
                                            .foregroundColor(.white)
                                            .background(Color(red: 9 / 255, green: 5 / 255, blue: 128 / 255))
                                            .cornerRadius(5)
                                    }
                                    Button {
                                        //MARK: 스터디 게시글 삭제
                                    } label: {
                                        Text("삭제")
                                            .bold()
                                            .frame(width: 180, height: 40)
                                            .foregroundColor(.black)
                                            .background(Color(red: 215 / 255, green: 215 / 255, blue: 215 / 255))
                                            .cornerRadius(5)
                                    }
                                    
                                }
//                                MARK: 로그인한 유저가 이 스터디를 이미 신청했다면 참석취소 버튼 보여주기
//                                else if studyDetail.currentMembers. {
//                                    Button {
//                                        //MARK: 참석 취소 프로세스-디비저장-알럿
//                                    } label: {
//                                        Text("참석취소")
//                                            .bold()
//                                            .frame(width: 290, height: 40)
//                                            .foregroundColor(.white)
//                                            .background(Color(red: 9 / 255, green: 5 / 255, blue: 128 / 255))
//                                            .cornerRadius(5)
//                                    }
//                                    Button {
//                                        isSavedBookmark.toggle()
//                                    } label: {
//                                        Image(systemName: isSavedBookmark ? "bookmark.fill" : "bookmark")
//                                            .font(.system(size: 30))
//                                            .frame(width: 60, height: 40)
//                                            .foregroundColor(Color(red: 251 / 255, green: 55 / 255, blue: 65 / 255))
//                                    }
//
//                                }
                                else {
                                    Button {
                                        //MARK: 참석 프로세스-디비저장-알럿
                                    } label: {
                                        Text("참석")
                                            .bold()
                                            .frame(width: 290, height: 40)
                                            .foregroundColor(.white)
                                            .background(Color(red: 9 / 255, green: 5 / 255, blue: 128 / 255))
                                            .cornerRadius(5)
                                    }
                                    Button {
                                        //MARK: isSaved 변수 업데이트
                                        isSavedBookmark.toggle()
                                        if isSavedBookmark {
                                            viewModel.updateBookmark(studyID: study.id ?? "")
                                        } else {
                                            viewModel.removeBookmark(studyID: study.id ?? "")
                                        }
                                    } label: {
                                        Image(systemName: isSavedBookmark ? "bookmark.fill" : "bookmark")
                                            .font(.system(size: 30))
                                            .frame(width: 60, height: 40)
                                            .foregroundColor(Color(red: 251 / 255, green: 55 / 255, blue: 65 / 255))
                                    }
                                }
                            }
                        }
                    }
                    .padding(15)
                    
                    StudyReplyView(viewModel: viewModel)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
        }){
            Image(systemName: "chevron.backward")
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: viewModel.studyDetail.title) {
                    Label("공유하기", systemImage: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        if isAlreadyReported() {
                            showAlert = true
                        } else {
                            isShowingReportSheet = true
                        }
                    }, label: {
                        Label("신고하기", systemImage: "exclamationmark.shield")
                    })
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $isShowingStudyMemberSheet) {
            StudyMemberSheetView(isShowingStudyMemberSheet: $isShowingStudyMemberSheet, viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isShowingLocationSheet) {
            LocationSheetView(viewModel: viewModel, locationCoordinate: CLLocationCoordinate2D(latitude: study.locationCoordinate?[0] ?? 0.0, longitude: study.locationCoordinate?[1] ?? 0.0), isShowingLocationSheet: $isShowingLocationSheet)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $isShowingReportSheet) {
            StudyCommentReportView(viewModel: viewModel, isStudy: true)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("신고"),
                  message: Text("이미 신고한 스터디입니다."),
                  dismissButton: .destructive(Text("확인")) {
            })
        }
        .onAppear(){
            viewModel.makeStudyDetail(study: study) {
                
            }
        }
    }
    
    func isMyStudy() -> Bool {
        guard let userId: String = UserDefaults.standard.string(forKey: Keys.userId.rawValue) else {
            return false
        }
        // 작성자 id와 내 id가 같다면
        if viewModel.studyDetail.creator.id == userId {
            return true
        } else {
            return false
        }
    }
    
    
    func isAlreadyReported() -> Bool {
        guard let userId = UserDefaults.standard.string(forKey: Keys.userId.rawValue) else {
            return false
        }
        if viewModel.studyDetail.reportUserIds.contains(userId) {
            return true
        }
        return false
    }
}

struct StudyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            StudyDetailView(viewModel: StudyViewModel(), study: StudyDTO.defaultStudy, isSavedBookmark: .constant(false))
        }
    }
    
}
