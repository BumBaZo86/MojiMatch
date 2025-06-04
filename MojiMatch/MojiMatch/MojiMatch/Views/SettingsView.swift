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
    @AppStorage("notificationsOn") private var notificationsOn = false
    
    @State var selectedDate = Date()
    @State var notificationText = ""

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
                    Text("🌗")
                        .font(.title)
                
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
                    Text("🎵")
                        .font(.title)

                    Spacer()

                    Toggle("", isOn: $soundOn)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .black))
                        .onChange(of: soundOn) { oldValue, newValue in
                            if newValue {
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
                
                HStack{
                    Text("🔔")
                        .font(.title)
                    
                    Spacer()
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        .disabled(notificationsOn)
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationsOn)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .black))
                        .onChange(of: notificationsOn) { oldValue, newValue in
                            if newValue {
                                
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                    if success {
                                        
                                        scheduleNotifications(at: selectedDate)
                                        
                                    } else if let error {
                                        print(error.localizedDescription)
                                    }
                                }
                            } else {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                print("Removed notification")
                                notificationText = ""
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

                Text(notificationText)
                
                Spacer()
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        isLoggedIn = false
                    } catch {
                        print("Logout failed: \(error.localizedDescription)")
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Log out")
                            .foregroundColor(.black)
                            .font(.title)
                            .fontDesign(.monospaced)
                        Spacer()
                    }
                    .frame(width: 250, height: 60)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                    )
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)

        
            Button(action: closeAction) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(ThemeColors.text(appSettings.isSettingsMode))
                    .padding()
            }
            .onAppear {
                loadNotification()
            }
        }
        .transition(.move(edge: .trailing))
        .animation(.easeInOut, value: appSettings.isSettingsMode)
    }
    
    func scheduleNotifications(at date : Date) {
        
        let content = UNMutableNotificationContent()
        content.title = "Time to play some MojiMatch!!"
        content.body = "😄🎯⭐🦁💰🔥🎡"
        content.sound = .default // Vill vi ändra till något annat ljud?
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "MojiMatchDailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            
            if let error = error {
                print("Failed to schedule notifications: \(error.localizedDescription)")
            } else {
                print("Success! Notification scheduled at \(components.hour ?? 0):\(components.minute ?? 0)")
            
                notificationText = "Notification scheduled at \(components.hour ?? 0):\(components.minute ?? 0)"
            }
        }
    }
    
    func loadNotification() {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { request in
            
            if let request = request.first(where: { $0.identifier == "MojiMatchDailyReminder" }),
               let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let hour = trigger.dateComponents.hour,
               let minute = trigger.dateComponents.minute {
                
                DispatchQueue.main.async {
                    selectedDate = Calendar.current.date(from: trigger.dateComponents) ?? Date()
                    notificationText = "Notification scheduled at \(hour):\(String(format: "%02d", minute))"
                }
            }
        }
    }
}
