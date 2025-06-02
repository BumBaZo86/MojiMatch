//
//  AppSettings.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-30.
//
import Foundation
import Firebase
import FirebaseFirestore
import Combine
import FirebaseAuth


class AppSettings: ObservableObject {
    @Published var isSettingsMode: Bool = false {
        didSet {
            saveDarkModeSetting()
        }
    }

    private var db = Firestore.firestore()
    private var userEmail: String? {
        Auth.auth().currentUser?.email
    }

    init() {
        loadDarkModeSetting()
    }

    func loadDarkModeSetting() {
        guard let email = userEmail else { return }

        db.collection("users").document(email).getDocument { document, error in
            if let document = document, document.exists {
                if let darkMode = document.data()?["darkMode"] as? Bool {
                    DispatchQueue.main.async {
                        self.isSettingsMode = darkMode
                    }
                }
            }
        }
    }

    func saveDarkModeSetting() {
        guard let email = userEmail else { return }

        db.collection("users").document(email).updateData([
            "darkMode": isSettingsMode
        ]) { error in
            if let error = error {
                print("Failed to save dark mode setting: \(error.localizedDescription)")
            }
        }
    }
}
