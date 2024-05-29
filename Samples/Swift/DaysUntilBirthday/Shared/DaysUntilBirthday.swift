/*
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import SwiftUI
import GoogleSignIn


@main
struct DaysUntilBirthday: App {
  @StateObject var authViewModel = AuthenticationViewModel()

  // Simple counter used to match up completion invocations.
  struct Counter {
    private var count : Int = 0
    mutating func claim() -> Int {
      let current = count
      count += 1
      return current
    }
  }
  static var counter = Counter()
  func restore() {
    let count = DaysUntilBirthday.counter.claim()
    print("\(count): Restoring")
    GIDSignIn.sharedInstance.restorePreviousSignIn() { user, error in
      print("\(count): Done: \(user), \(error)")
      if let user = user {
        self.authViewModel.state = .signedIn(user)
      } else if let error = error {
        self.authViewModel.state = .signedOut
        print("There was an error restoring the previous sign-in: \(error)")
      } else {
        self.authViewModel.state = .signedOut
      }
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authViewModel)
        .onAppear {
          restore()
          restore()
        }
        .onOpenURL { url in
          GIDSignIn.sharedInstance.handle(url)
        }
    }
  }
}
