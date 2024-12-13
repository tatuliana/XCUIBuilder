//
//  Pattern2Setup.swift
//  XCUIBuilder
//
//  Created by Natalia Popova on 11/21/24.
//

import Foundation
import XcodeProj
import PathKit

func generateSelfChainingTabBarProtocolExampleContent() -> String {
    return """
   import Foundation
   import XCTest

   protocol TabBarProtocolExample: ScreenActivitiesProtocol {
       var screenName: String { get }
       func select(tab: TabsExample) -> Self
       func assertTabIsSelected(_ tab: TabsExample, expected result: Bool) -> Self
   }

   extension TabBarProtocolExample where Self: BaseScreen {
       var screenName: String {
           String(describing: type(of: self))
       }
       
       /// Select the tab on the tab bar
       /// - parameter tab: `TabsExample`. The enum to select the tab from
       /// - returns: Self. Returns self for the chaining purpose
       @discardableResult
       func select(tab: TabsExample) -> Self {
           runActivity(.step, "Tap '\\(tab.rawValue)' tab") {
               BaseScreen.app.tabBars.buttons[tab.rawValue].tap()
               return self
           }
       }
       
       /// Asserts if the specigic tab is selected.
       /// - parameter tab: `TabsExample`. The enum to select the tab from
       /// - parameter expected: `Bool`. The expected result, which is `true` by default.
       /// - returns: Self. Returns self for the chaining purpose
       /// - _Examples:_
       ///   - To verify the element exists:
       ///     ```swift
       ///     sceenName.tabIsSelected(.home)
       ///     ```
       ///   - To verify the element doesn't exist:
       ///     ```swift
       ///     screenName.tabIsSelected(.home, expected: false)
       ///     ```
       @discardableResult
       func assertTabIsSelected(_ tab: TabsExample, expected result: Bool = true) -> Self {
           let myTab = BaseScreen.app.tabBars.buttons[tab.rawValue]
           runActivity(element: myTab.description, state: .selected, expected: result) {
               myTab.assert(state: .selected, expected: result)
           }
           return self
       }
   }
   """
}

func generateSelfChainingLaunchScreenExampleContent() -> String {
    return """
    import XCTest

    final class LaunchScreenExample: BaseScreen {
        // MARK: UI elements declaration
        private lazy var goButton = BaseScreen.app.buttons["Go"].firstMatch
        
        // MARK: Screen Initializer
        required init() {
            super.init()
            visible()
        }
        
        // MARK: Visibility
        /// Verifies the screen state by checking that the element unique to this particular screen exists.
        private func visible() {
            runActivity(.screen, "Verifying if the screen is present") {
                XCTAssertTrue(goButton.wait(for: .loading), "\\(Icons.error.rawValue) \\(screenName) is not present")
            }
        }
        
        // MARK: Actions
        /// Taps the Go button
        /// - returns: Self. Returns self for the chaining purpose
        @discardableResult
        func tapGoButton() -> Self {
            runActivity(.step, "Tap the 'Go' button") {
                goButton.tap()
                return self
            }
        }
    }
    """
}

func generateSelfChainingLoginScreenExampleContent() -> String {
    return """
    import XCTest

    final class LoginScreenExample: BaseScreen {
        // MARK: UI elements declaration
        private lazy var usernameTextField = BaseScreen.app.textFields["Username"].firstMatch
        private lazy var passwordTextField = BaseScreen.app.secureTextFields["Password"].firstMatch
        private lazy var loginButton = BaseScreen.app.buttons["Login"].firstMatch
        private lazy var errorAlert = BaseScreen.app.alerts["Error"].firstMatch
        
        // MARK: Screen Initializer
        required init() {
            super.init()
            visible()
        }
        
        // MARK: Visibility
        /// Verifies the screen state by checking that the element unique to this particular screen exists.
        private func visible() {
            runActivity(.screen, "Verifying if the screen is present") {
                XCTAssertTrue(loginButton.wait(for: .loading), "\\(Icons.error.rawValue) \\(screenName) is not present")
            }
        }
        
        // MARK: Actions
        /// Enter the `username` into the `usernameTextField`.
        /// - parameter username: The `username` to enter into the `usernameTextField`.
        /// - returns: Self. Returns self for the chaining purpose
        @discardableResult
        func enter(username: String) -> Self {
            runActivity(.step, "Enter username into the usernameTextField") {
                usernameTextField.tap()
                usernameTextField.typeText(username)
                return self
            }
        }
        
        /// Enter the `username` into the `usernameTextField`.
        /// - parameter password: The `password` to enter into the `passwordTextField`.
        /// - returns: Self. Returns self for the chaining purpose
        @discardableResult
        func enter(password: String) -> Self {
            runActivity(.step, "Enter password into the passwordTextField") {
                passwordTextField.tap()
                passwordTextField.typeText(password)
                return self
            }
        }
        
        /// Taps the `Login` button
        /// - parameter screen: The screen to navigate to after tapping the button.
        /// - returns: Self. Returns self for the chaining purpose
        @discardableResult
        func tapLoginButton() -> Self {
            runActivity(.step, "Tap the Login button") {
                loginButton.tap()
                return self
            }
        }
        
        // MARK: Assertions
        /// Asserts if the Login button is enabled.
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: Self. Returns self for the chaining purpose
        /// - warning: If you want to assert that the element doesn't exist, set the expected result to `false`.
        /// - _Examples:_
        ///   - To verify the element is enabled:
        ///     ```swift
        ///        .assertLoginButtonIsEnabled()
        ///     ```
        ///   - To verify the element isn't enabled:
        ///     ```swift
        ///        .assertLoginButtonIsEnabled(expected: false)
        ///     ```
        @discardableResult
        func assertLoginButtonIsEnabled(expected result: Bool = true) -> Self {
            return runActivity(element: "Login button", state: .enabled, expected: result) {
                loginButton.assert(state: .enabled, expected: result)
                return self
            }
        }
        
        /// Asserts if the login `Error` alert exists.
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: Self. Returns self for the chaining purpose
        /// - warning: If you want to assert that the element doesn't exist, set the expected result to `false`.
        /// - _Examples:_
        ///   - To verify the element exists:
        ///     ```swift
        ///        .assertErrorAlertExists()
        ///     ```
        ///   - To verify the element doesn't exist:
        ///     ```swift
        ///        .assertErrorAlertExists(result: false)
        ///     ```
        @discardableResult
        func assertErrorAlertExists(expected result: Bool = true) -> Self {
            runActivity(element: "Login Error alert", state: .exists, expected: result) {
                errorAlert.assert(expected: result)
                return self
            }
        }
    }
    """
}

func generateSelfChainingHomeScreenExampleContent() -> String {
    return """
    import XCTest

    final class HomeScreenExample: BaseScreen, TabBarProtocolExample {
        // MARK: UI elements declaration
        private lazy var welcomeLabel = BaseScreen.app.staticTexts.label(containing: "Welcome").firstMatch
        
        // MARK: Screen Initializer
        required init() {
            super.init()
            visible()
        }
        
        // MARK: Visibility
        /// Verifies the screen state by checking that the element unique to this particular screen exists.
        private func visible() {
            runActivity(.screen, "Verifying if the screen is present") {
                XCTAssertTrue(welcomeLabel.wait(for: .normal), "\\(Icons.error.rawValue) \\(screenName) is not present")
            }
        }
    }
    """
}

func generateSelfChainingUITestsExampleContent() -> String {
    return """
    import XCTest

    // Screen Transition Chaining UI Test Examples
    final class SelfChainingUITestsExampleExample: BaseTest {
        func testLoginButtonIsDisabled() {
            runActivity(named: "Test Login Button is disabled") {
                LaunchScreenExample()
                    .tapGoButton()
                LoginScreenExample()
                    .assertLoginButtonIsEnabled(expected: false)
            }
        }
        
        func testLoginButtonIsEnabled() {
            runActivity(named: "Test Login Button is enabled") {
                LaunchScreenExample()
                    .tapGoButton()
                LoginScreenExample()
                    .enter(username: "Santa")
                    .enter(password: "12345")
                    .assertLoginButtonIsEnabled()
            }
        }
        
        func testLoginErrorAlertIsDisplayed() {
            runActivity(named: "Test Login Error Alert is Displayed") {
                LaunchScreenExample()
                    .tapGoButton()
                LoginScreenExample()
                    .enter(username: "Santa")
                    .enter(password: "1234567")
                    .tapLoginButton()
                    .assertErrorAlertExists()
            }
        }
        
        func testHappyPathLogin() {
            runActivity(named: "Test Happy Path Login") {
                LaunchScreenExample()
                    .tapGoButton()
                LoginScreenExample()
                    .enter(username: "Santa")
                    .enter(password: "12345")
                    .tapLoginButton()
                HomeScreenExample()
                    .assertTabIsSelected(.home)
            }
        }
    }
    """
}
