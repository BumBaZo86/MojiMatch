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

            VStack(alignment: .center, spacing: 30) {
                Text("Settings")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .padding()
                    .frame(width: 250, height: 60)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                    )
                    .fontDesign(.monospaced)
                    .frame(maxWidth: .infinity, alignment: .center)

           
                HStack {
                    Image("Darkmode")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.black)

                    Spacer()

                    Toggle("", isOn: $appSettings.isSettingsMode)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .black))
                }
                .padding()
                .frame(width: 250, height: 60)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                )

        
                HStack {
                    Image("Sound")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.black)

                    Spacer()

                    Toggle("", isOn: $soundOn)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .black))
                        .onChange(of: soundOn) { value in
                            if value {
                                AudioManager.shared.playBackgroundMusic()
                            } else {
                                AudioManager.shared.stopBackgroundMusic()
                            }
                        }
                }
                .padding()
                .frame(width: 250, height: 60)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                )

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
            .frame(maxWidth: .infinity, alignment: .center)

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
