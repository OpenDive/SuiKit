//
//  ContentView.swift
//  visionOS_Example
//
//  Created by Marcus Arnett on 1/24/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AuthenticationServices
import Firebase
import FirebaseAuth
import AppAuthCore
import SuiKit

struct ContentView: View {
    @State private var zkAddress: String? = nil

    var body: some View {
        VStack {
            if let zkAddress {
                Text("ZK Address: \(zkAddress)")
                    .bold()
            } else {
                Button("Sign in with Google") {
                    startGoogleSignIn()
                }
            }
            
            Text("Hello, world!")
        }
        .padding()
    }

    private func startGoogleSignIn() {
        let clientId = "INSERT-CLIENT-ID-HERE"
        let redirectUri = "io.opendive.TestOIDXROS:/oauth2redirect"
        let authUrl = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?client_id=\(clientId)&redirect_uri=\(redirectUri)&response_type=code&scope=email")!
        let callbackUrlScheme = "io.opendive.TestOIDXROS"
        
        let authenticationSession = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: callbackUrlScheme) { callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else { return }
            
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            if let code = queryItems?.first(where: { $0.name == "code" })?.value {
                // Ensure the configuration is discovered before attempting to exchange the code
                let googleAuthorizationEndpoint = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
                let googleTokenEndpoint = URL(string: "https://oauth2.googleapis.com/token")!
                let googleConfiguration = OIDServiceConfiguration(authorizationEndpoint: googleAuthorizationEndpoint,
                                                                   tokenEndpoint: googleTokenEndpoint)
                
                let codeExchangeRequest = OIDTokenRequest(
                    configuration: googleConfiguration,
                    grantType: OIDGrantTypeAuthorizationCode,
                    authorizationCode: code,
                    redirectURL: URL(string: redirectUri)!,
                    clientID: clientId,
                    clientSecret: nil, // Client secret is not used in public clients
                    scope: nil,
                    refreshToken: nil,
                    codeVerifier: nil,
                    additionalParameters: nil
                )
                
                // Perform the token request
                OIDAuthorizationService.perform(codeExchangeRequest) { response, error in
                    DispatchQueue.main.async {
                        if let tokenResponse = response {
                            let credentials = GoogleAuthProvider.credential(withIDToken: tokenResponse.idToken!, accessToken: tokenResponse.accessToken!)
                            
                            Auth.auth().signIn(with: credentials) { authResult, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }
                                authResult!.user.getIDTokenForcingRefresh(true) { idToken, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                        return
                                    }
                                    self.zkAddress = try! zkLoginUtilities.jwtToAddress(jwt: idToken!, userSalt: "0")
                                }
                            }
                        } else {
                            print("Error exchanging code for tokens: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            }
        }

        authenticationSession.presentationContextProvider = UIApplication.shared.windows.first?.rootViewController
        authenticationSession.start()
    }
}

extension UIViewController: @retroactive ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
