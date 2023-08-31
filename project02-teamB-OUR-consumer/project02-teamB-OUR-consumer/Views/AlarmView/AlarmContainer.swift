
//
//  ContentView.swift
//  OURApp
//
//  Created by 박찬호 on 2023/08/22.
//

import SwiftUI



struct AlarmContainer: View {
    
    @EnvironmentObject var alarmViewModel: AlarmViewModel
    
    @State private var selectedTab = 0
    
    // 개인 및 공개 알림 샘플 데이터
    @EnvironmentObject var viewModel: AlarmViewModel
    
    @State private var allClearAlertShowing = false
    let alertTitle: String = "알림 전체 삭제"
    
    // 본문 뷰
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 사용자 지정 탭 뷰
                CustomTabView(selectedTab: $selectedTab)
                
                VStack {
                    Button {
                        UNNotificationService.shared.requestSendNoti(seconds: 0.1)
                    } label: {
                        Text("푸쉬 알림")
                    }
                    Button {
                        UNNotificationService.shared.requestAuthNoti()
                    } label: {
                        Text("권한 설정")
                    }
                }
                // 알림 뷰
                switch selectedTab {
                case 0:
                    NotificationsListView(access: .personal) // 개인 알림
                        .environmentObject(viewModel)
                case 1:
                    NotificationsListView(access: .public) // 공개 알림
                        .environmentObject(viewModel)
                default:
                    Text("알림 뷰")
                }
                Spacer()
            }
        }
        .onAppear{
            viewModel.fetchNotificationItem()
            alarmViewModel.markAllAsRead()
        }
        .navigationTitle("알림")
        .navigationBarTitleDisplayMode(.inline)
        
        // 전체 삭제
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    allClearAlertShowing = true
                } label: {
                    Label("전체 삭제", systemImage: "trash.fill")
                }
                .font(.system(size: 14, weight: .medium))
                .alert(
                    alertTitle,
                    isPresented: $allClearAlertShowing
                ) {
                    Button(role: .destructive) {
                        viewModel.personalNotiItem = [:]
                        viewModel.publicNotiItem = [:]
                    } label: {
                        Text("Delete")
                    }
                }
            }
        }
    }
}



struct AlarmContainer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            AlarmContainer()
                .environmentObject(AlarmViewModel(dependency: .init(alarmFireSerivce: AlarmFireService(), userViewModel: UserViewModel())))
        }
    }
}
