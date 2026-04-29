//
//  MainTabView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 18/03/2026.
//


import SwiftUI

struct MainTabView: View{
    var body: some View {
        TabView {
            PatientDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
//            ProgressViewScreen()
//                .tabItem {
//                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
//                }
            
            AddGaitRecordView()
                            .tabItem {
                                Label("Record", systemImage: "plus.circle.fill")
                            }
            
            RecoveryCheckInView()
                .tabItem {
                    Label("Check-In", systemImage: "heart.text.square")
                }

            RecoveryHistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.line.uptrend.xyaxis")
                }

            
            MyAccountView()
                            .tabItem {
                                Label("Account", systemImage: "person.circle")
                            }
            
            HealthSyncView()
                            .tabItem {
                                Label("Sync", systemImage: "heart.text.square.fill")
                            }
            
            

            
            SettingsViewScreen()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
}
