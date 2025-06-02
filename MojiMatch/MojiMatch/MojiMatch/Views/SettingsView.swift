//
//  SettingsView.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-06-02.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @AppStorage("soundOn") private var soundOn = true
    @AppStorage("isLoggedIn") private var isLoggedIn = true

    var closeAction: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ThemeColors.background(appSettings.isSettingsMode)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 30) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(ThemeColors.text(appSettings.isSettingsMode))
                
                Toggle(isOn: $appSettings.isSettingsMode) {
                    Text("Dark Mode")
                        .foregroundColor(ThemeColors.text(appSettings.isSettingsMode))
                }
                .toggleStyle(SwitchToggleStyle(tint: .black))

                Toggle(isOn: $soundOn) {
                    Text("Sound")
                        .foregroundColor(ThemeColors.text(appSettings.isSettingsMode))
                }
                .toggleStyle(SwitchToggleStyle(tint: .black))

                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        isLoggedIn = false
                    } catch {
                        print("Logout failed: \(error.localizedDescription)")
                    }
                }) {
                    Text("Log Out")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: closeAction) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(ThemeColors.text(appSettings.isSettingsMode))
                    .padding()
            }
        }
        .transition(.move(edge: .trailing))
        .animation(.easeInOut, value: appSettings.isSettingsMode)
    }
}
