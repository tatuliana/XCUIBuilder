//
//  Pattern1Setup.swift
//  XCUIBuilder
//
//  Created by Natalia Popova on 11/21/24.
//

import Foundation
import XcodeProj
import PathKit

func generateScreenTransitionChainingTabBarProtocolContent() -> String {
    return """
    import Foundation
    import XCTest

    protocol TabBarProtocol: ScreenActivitiesProtocol {
        var screenName: String { get }
        func select<T>(tab: Tabs, goTo screen: T.Type) -> T where T: BaseScreen
        func tabIsSelected(_ tab: Tabs, expected result: Bool) -> Bool
        func assertTabIsSelected(_ tab: Tabs, expected result: Bool) -> Self
    }

    extension TabBarProtocol {
        var screenName: String {
            String(describing: type(of: self))
        }
        
        /// Select the tab on the tab bar
        /// - parameter tab: `Tabs`. The enum to select the tab from
        /// - parameter goTo: The name of the screen that is expected after tapping the element.
        /// - returns: An instance of the screen indicated by the `goTo` parameter, representing either the next screen or the current screen depending on the flow.
        @discardableResult
        func select<T>(tab: Tabs, goTo screen: T.Type) -> T where T: BaseScreen {
            runActivity(.step, "Tap '\\(tab.rawValue)' tab") {
                BaseScreen.app.tabBars.buttons[tab.rawValue].tap()
                return T()
            }
        }
        
        /// Verifies if the specific tab is selected.
        /// - parameter tab: `Tabs`. The enum to select the tab from
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: `Bool`. Returns `true` if the button's state matches the expected result, otherwise `false`.
        /// - warning: Use with `XCTAssertTrue`. If you want to assert that the element doesn't exist, set the expected result to `false`. It helps the test to run faster.
        /// - _Examples:_
        ///   - To verify the element exists:
        ///     ```swift
        ///     XCTAssertTrue(sceenName.tabIsSelected(.home)
        ///     ```
        ///   - To verify the element doesn't exist:
        ///     ```swift
        ///     XCTAssertTrue(screenName.tabIsSelected(.home, expected: false))
        ///     ```
        @discardableResult
        func tabIsSelected(_ tab: Tabs, expected result: Bool = true) -> Bool {
            let myTab = BaseScreen.app.tabBars.buttons[tab.rawValue]
            return runActivity(element: myTab.description, state: .selected, expected: result) {
                myTab.wait(state: .selected, result: result)
            }
        }
        
        /// Verifies if the specigic tab is selected.
        /// - parameter tab: `Tabs`. The enum to select the tab from
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: `Bool`. Returns `true` if the button's state matches the expected result, otherwise `false`.
        /// - warning: Use with `XCTAssertTrue`. If you want to assert that the element doesn't exist, set the expected result to `false`. It helps the test to run faster.
        /// - _Examples:_
        ///   - To verify the element exists:
        ///     ```swift
        ///     XCTAssertTrue(sceenName.tabIsSelected(.home)
        ///     ```
        ///   - To verify the element doesn't exist:
        ///     ```swift
        ///     XCTAssertTrue(screenName.tabIsSelected(.home, expected: false))
        ///     ```
        @discardableResult
        func assertTabIsSelected(_ tab: Tabs, expected result: Bool = true) -> Self {
            let myTab = BaseScreen.app.tabBars.buttons[tab.rawValue]
            runActivity(element: myTab.description, state: .selected, expected: result) {
                myTab.assert(state: .selected, expected: result)
            }
            return self
        }
    }
    """
}

func generateTransitionChainingLaunchScreenContent() -> String {
    return """
    import XCTest

    final class LaunchScreen: BaseScreen {
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
        /// - returns: An instance of `LoginScreen` representing the next screen after tapping the button.
        @discardableResult
        func tapGoButton() -> LoginScreen {
            runActivity(.step, "Tap the 'Go' button") {
                goButton.tap()
                return LoginScreen()
            }
        }
    }
    """
}

func generateTransitionChainingLoginScreenContent() -> String {
    return """
    import XCTest

    final class LoginScreen: BaseScreen {
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
        /// - returns: An instance of `LoginScreen`.
        @discardableResult
        func enter(username: String) -> Self {
            runActivity(.step, "Enter username into the usernameTextField") {
                usernameTextField.tap()
                usernameTextField.typeText(username)
                return Self()
            }
        }
        
        /// Enter the `username` into the `usernameTextField`.
        /// - parameter password: The `password` to enter into the `passwordTextField`.
        /// - returns: An instance of `LoginScreen`.
        @discardableResult
        func enter(password: String) -> Self {
            runActivity(.step, "Enter password into the passwordTextField") {
                passwordTextField.tap()
                passwordTextField.typeText(password)
                return Self()
            }
        }
        
        /// Taps the `Login` button
        /// - parameter screen: The screen to navigate to after tapping the button.
        /// - returns: An instance of `LoginScreen` in case of the error message or an instance `HomeScreen` after tapping the button.
        @discardableResult
        func tapLoginButton<T>(screen: T.Type) -> T where T: BaseScreen {
            runActivity(.step, "Tap the Login button") {
                loginButton.tap()
                return T()
            }
        }
        
        // MARK: Assertions
        /// Verifies if the Login button is enabled.
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: `Bool`. Returns `true` if the button's state matches the expected result, otherwise `false`.
        /// - warning: Use with `XCTAssertTrue`. If you want to assert that the element doesn't exist, set the expected result to `false`. This helps the test to run faster.
        /// - _Examples:_
        ///   - To verify the element exists:
        ///     ```swift
        ///     XCTAssertTrue(loginScreen.loginButtonIsEnabled()
        ///     ```
        ///   - To verify the element doesn't exist:
        ///     ```swift
        ///     XCTAssertTrue(loginScreen.loginButtonIsEnabled(expected: false))
        ///     ```
        @discardableResult
        func loginButtonIsEnabled(expected result: Bool = true) -> Bool {
            return runActivity(element: "Login button", state: .enabled, expected: result) {
                loginButton.wait(state: .enabled, result: result)
            }
        }
        
        /// Verifies if the Login button is enabled.
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: `Bool`. Returns `true` if the button's state matches the expected result, otherwise `false`.
        /// - warning: Use with `XCTAssertTrue`. If you want to assert that the element doesn't exist, set the expected result to `false`. This helps the test to run faster.
        /// - _Examples:_
        ///   - To verify the element is enabled:
        ///     ```swift
        ///     loginScreen.assertLoginButtonIsEnabled()
        ///     ```
        ///   - To verify the element isn't enabled:
        ///     ```swift
        ///    loginScreen.assertLoginButtonIsEnabled(expected: false)
        ///     ```
        func assertLoginButtonIsEnabled(expected result: Bool = true) {
            return runActivity(element: "Login button", state: .enabled, expected: result) {
                loginButton.assert(state: .enabled, expected: result)
            }
        }
        
        /// Verifies if the login `Error` alert exists.
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: `Bool`. Returns `true` if the button's state matches the expected result, otherwise `false`.
        /// - warning: Use with `XCTAssertTrue`. If you want to assert that the element doesn't exist, set the expected result to `false`. It helps the test to run faster.
        /// - _Examples:_
        ///   - To verify the element exists:
        ///     ```swift
        ///     loginScreen.assertErrorAlertExists()
        ///     ```
        ///   - To verify the element doesn't exist:
        ///     ```swift
        ///     loginScreen.assertErrorAlertExists(result: false)
        ///     ```
        func assertErrorAlertExists(expected result: Bool = true) {
            runActivity(element: "Login Error alert", state: .exists, expected: result) {
                return errorAlert.assert(expected: result)
            }
        }
    }
    """
}

func generateTransitionChainingHomeScreenContent() -> String {
    return """
    import XCTest

    final class HomeScreen: BaseScreen, TabBarProtocol {
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

func generateTransitionChainingUITests() -> String {
    return """
    import XCTest

    // Screen Transition Chaining UI Test Examples
    class TransitionChainingUITests: BaseTest {
        // This function uses XCTAssertTrue to verify the Bool value that is returned from the function loginButtonIsEnabled
        func testLoginButtonIsDisabled() {
            runActivity(named: "Test Login Button is disabled") {
                let launchScreen = LaunchScreen()
                let loginScreen = launchScreen.tapGoButton()
                XCTAssertTrue(loginScreen.loginButtonIsEnabled(expected: false))
            }
        }
        
        // This function uses the assert function directly in the test
        func testLoginButtonIsEnabled() {
            runActivity(named: "Test Login Button is enabled") {
                let launchScreen = LaunchScreen()
                launchScreen.tapGoButton()
                    .enter(username: "Santa")
                    .enter(password: "12345")
                    .assertLoginButtonIsEnabled()
            }
        }
        
        func testLoginErrorAlertIsDisplayed() {
            runActivity(named: "Test Login Error Alert is Displayed") {
                let launchScreen = LaunchScreen()
                launchScreen.tapGoButton()
                    .enter(username: "Santa")
                    .enter(password: "1234567")
                    .tapLoginButton(screen: LoginScreen.self)
                    .assertErrorAlertExists()
            }
        }
        
        func testHappyPathLogin() {
            runActivity(named: "Test Happy Path Login") {
                let launchScreen = LaunchScreen()
                launchScreen.tapGoButton()
                    .enter(username: "Santa")
                    .enter(password: "12345")
                    .tapLoginButton(screen: HomeScreen.self)
            }
        }
    }
    """
}
