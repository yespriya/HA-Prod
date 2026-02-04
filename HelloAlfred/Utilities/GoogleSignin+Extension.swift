
import Foundation
import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

extension AppDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let handled = GIDSignIn.sharedInstance.handle(url)
        
      return handled
    }
    
}

extension SignInViewController {
    func googleSignInAction() {
        // Get Firebase client ID
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("🔴 Firebase client ID not found")
            return
        }
        
        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start sign-in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            
            // Handle errors
            if let error = error {
                print("🔴 Google Sign-In error: \(error.localizedDescription)")
                return
            }
            
            // Validate user data
            guard let user = result?.user,
                  let email = user.profile?.email else {
                print("🔴 Failed to retrieve user profile or token")
                return
            }
            
            // Get user info
            let name = user.profile?.name ?? ""
            print("✅ Signed in user: \(email)")
            
            // Call your API
            self.socialSignIn(name: name, email: email, onboard: .google)
        }
    }
}
