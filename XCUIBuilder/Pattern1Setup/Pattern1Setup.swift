//
//  Pattern1Setup.swift
//  XCUIBuilder
//
//  Created by Natalia Popova on 11/21/24.
//

import Foundation
import XcodeProj
import PathKit

func generateScreenTransitionChainingTabBarProtocolExampleContent() -> String {
    return """
    import Foundation
    import XCTest

    protocol TabBarProtocolExample: ScreenActivitiesProtocol {
        var screenName: String { get }
        func select<T>(tab: TabsExample, goTo screen: T.Type) -> T where T: BaseScreen
        func tabIsSelected(_ tab: TabsExample, expected result: Bool) -> Bool
        func assertTabIsSelected(_ tab: TabsExample, expected result: Bool) -> Self
    }

    extension TabBarProtocolExample {
        var screenName: String {
            String(describing: type(of: self))
        }
        
        /// Select the tab on the tab bar
        /// - parameter tab: `TabsExample`. The enum to select the tab from
        /// - parameter goTo: The name of the screen that is expected after tapping the element.
        /// - returns: An instance of the screen indicated by the `goTo` parameter, representing either the next screen or the current screen depending on the flow.
        @discardableResult
        func select<T>(tab: TabsExample, goTo screen: T.Type) -> T where T: BaseScreen {
            runActivity(.step, "Tap '\\(tab.rawValue)' tab") {
                BaseScreen.app.tabBars.buttons[tab.rawValue].tap()
                return T()
            }
        }
        
        /// Asserts if the specific tab is selected.
        /// - parameter tab: `TabsExample`. The enum to select the tab from
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
        func tabIsSelected(_ tab: TabsExample, expected result: Bool = true) -> Bool {
            let myTab = BaseScreen.app.tabBars.buttons[tab.rawValue]
            return runActivity(element: myTab.description, state: .selected, expected: result) {
                myTab.wait(state: .selected, result: result)
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

func generateTransitionChainingLaunchScreenExampleContent() -> String {
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
        /// - returns: An instance of `LoginScreenExample` representing the next screen after tapping the button.
        @discardableResult
        func tapGoButton() -> LoginScreenExample {
            runActivity(.step, "Tap the 'Go' button") {
                goButton.tap()
                return LoginScreenExample()
            }
        }
    }
    """
}

func generateTransitionChainingLoginScreenExampleContent() -> String {
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
        /// - returns: An instance of `LoginScreenExample`.
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
        /// - returns: An instance of `LoginScreenExample`.
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
        /// - returns: An instance of `LoginScreenExample` in case of the error message or an instance `HomeScreenExample` after tapping the button.
        @discardableResult
        func tapLoginButton<T>(screen: T.Type) -> T where T: BaseScreen {
            runActivity(.step, "Tap the Login button") {
                loginButton.tap()
                return T()
            }
        }
        
        // MARK: Assertions
        /// Asserts if the Login button is enabled.
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: `Bool`. Returns `true` if the button's state matches the expected result, otherwise `false`.
        /// - warning: Use with `XCTAssertTrue`. If you want to assert that the element doesn't exist, set the expected result to `false`. This helps the test to run faster.
        /// - _Examples:_
        ///   - To verify the element exists:
        ///     ```swift
        ///     XCTAssertTrue(loginScreenExample.loginButtonIsEnabled()
        ///     ```
        ///   - To verify the element doesn't exist:
        ///     ```swift
        ///     XCTAssertTrue(loginScreenExample.loginButtonIsEnabled(expected: false))
        ///     ```
        @discardableResult
        func loginButtonIsEnabled(expected result: Bool = true) -> Bool {
            return runActivity(element: "Login button", state: .enabled, expected: result) {
                loginButton.wait(state: .enabled, result: result)
            }
        }
        
        /// Asserts if the Login button is enabled.
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: Self. Returns self for the chaining purpose
        /// - _Examples:_
        ///   - To verify the element is enabled:
        ///     ```swift
        ///     loginScreenExample.assertLoginButtonIsEnabled()
        ///     ```
        ///   - To verify the element isn't enabled:
        ///     ```swift
        ///    loginScreenExample.assertLoginButtonIsEnabled(expected: false)
        ///     ```
        @discardableResult
        func assertLoginButtonIsEnabled(expected result: Bool = true) -> Self {
            runActivity(element: "Login button", state: .enabled, expected: result) {
                loginButton.assert(state: .enabled, expected: result)
                return self
            }
        }
        
        /// Asserts if the login `Error` alert exists.
        /// - parameter expected: `Bool`. The expected result, which is `true` by default.
        /// - returns: Self. Returns self for the chaining purpose
        /// - _Examples:_
        ///   - To verify the element exists:
        ///     ```swift
        ///     loginScreenExample.assertErrorAlertExists()
        ///     ```
        ///   - To verify the element doesn't exist:
        ///     ```swift
        ///     loginScreenExample.assertErrorAlertExists(result: false)
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

func generateTransitionChainingHomeScreenExampleContent() -> String {
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

func generateTransitionChainingUITestsExample() -> String {
    return """
    import XCTest

    // Screen Transition Chaining UI Test Examples
    class TransitionChainingUITestsExample: BaseTest {
        // This function uses XCTAssertTrue to verify the Bool value that is returned from the function loginButtonIsEnabled
        func testLoginButtonIsDisabled() {
            runActivity(named: "Test Login Button is disabled") {
                let launchScreenExample = LaunchScreenExample()
                let loginScreenExample = launchScreenExample.tapGoButton()
                XCTAssertTrue(loginScreenExample.loginButtonIsEnabled(expected: false))
            }
        }
        
        // This function uses the assert function directly in the test
        func testLoginButtonIsEnabled() {
            runActivity(named: "Test Login Button is enabled") {
                let launchScreenExample = LaunchScreenExample()
                launchScreenExample.tapGoButton()
                    .enter(username: "Santa")
                    .enter(password: "12345")
                    .assertLoginButtonIsEnabled()
            }
        }
        
        func testLoginErrorAlertIsDisplayed() {
            runActivity(named: "Test Login Error Alert is Displayed") {
                let launchScreenExample = LaunchScreenExample()
                launchScreenExample.tapGoButton()
                    .enter(username: "Santa")
                    .enter(password: "1234567")
                    .tapLoginButton(screen: LoginScreenExample.self)
                    .assertErrorAlertExists()
            }
        }
        
        func testHappyPathLogin() {
            runActivity(named: "Test Happy Path Login") {
                let launchScreenExample = LaunchScreenExample()
                launchScreenExample.tapGoButton()
                    .enter(username: "Santa")
                    .enter(password: "12345")
                    .tapLoginButton(screen: HomeScreenExample.self)
            }
        }
    }
    """
}
