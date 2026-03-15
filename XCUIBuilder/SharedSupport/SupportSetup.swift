//
//  SupportSetup.swift
//  XCUIBuilder
//

import Foundation
import XcodeProj
import PathKit

// File content generators
func generateBaseTestContent() -> String {
    return """
    import XCTest

    class BaseTest: XCTestCase {
        let app = XCUIApplication()
        
        override class var runsForEachTargetApplicationUIConfiguration: Bool {
            false
        }
        
        override func setUpWithError() throws {
            continueAfterFailure = false
            app.launch()
        }
        
        override func tearDownWithError() throws {
            // Put teardown code here. This method is called after the invocation of each test method in the class.
        }
        
        func runActivity(named: String, block: () -> Void) {
            return XCTContext.runActivity(named: "\\(Icons.test.rawValue) \\(named)") {_ in
                return block()
            }
        }
    }
    """
}

func generateScreenActivitiesProtocolContent() -> String {
    return """
    import XCTest

    protocol ScreenActivitiesProtocol {
        var screenName: String { get }
        func runActivity<T>(_ icon: Icons, _ named: String, block: () -> T) -> T
        func runActivity<A>(element description: String,
                            state: ElementState,
                            expected result: Bool,
                            block: () -> A) -> A
        func runActivity<A>(element description: String,
                            property: Properties,
                            equalTo: String,
                            expected result: Bool,
                            block: () -> A) -> A
    }

    extension ScreenActivitiesProtocol {
        var screenName: String {
            String(describing: type(of: self))
        }
            
        /// A wrapper for step activities.
        /// This method allows you to perform any actions within an activity, except assertions. It provides an icon and a description for the activity.
        /// - parameter icon: Icons. An enum value representing the icon to use for the activity.
        /// - parameter named: String. A string describing the activity.
        /// - returns: A generic value.
        @discardableResult
        func runActivity<T>(_ icon: Icons, _ named: String, block: () -> T) -> T {
            return XCTContext.runActivity(named: "\\(icon.rawValue) - \\(screenName) - \\(named)") {_ in
                return block()
            }
        }
        
        /// A wrapper for activities for element's state assertions.
        /// - parameter element description: String. A string describing the element.
        /// - parameter state: ElementState.  The state of the element that we are trying to verify, represented by an `ElementState` enum.
        /// - parameter expected result: Bool. A boolean indicating the expected result of the assertion. Pass `true` if you are verifying that the element exists, is selected, is hittable, etc.; pass `false` for the opposite.
        /// - returns: A generic value.
        @discardableResult
        func runActivity<A>(element description: String,
                            state: ElementState,
                            expected result: Bool,
                            block: () -> A) -> A {
            var message = ""
            switch state {
            case .exists:
                message = "\\(result ? "exists" : "doesn't exist")"
            case .hittable:
                message = "is\\(result ? "" : "n't") hittable"
            case .enabled:
                message = "is \\(result ? "enabled" : "disabled")"
            case .selected:
                message = "is\\(result ? "" : "n't") selected"
            case .focused:
                message = "has\\(result ? "" : " no") focus"
            case .visible:
                message = "is\\(result ? "" : "n't") visible"
            }
            let activityName = "\\(Icons.assert.rawValue) - \\(screenName) - Verifying if the \\(description) \\(message)"
            return XCTContext.runActivity(named: activityName) { _ in
                return block()
            }
        }
        
        /// A wrapper for activities for the element's property assertions.
        /// - parameter element description: String. A string describing the element.
        /// - parameter property: Properties.  The property of the element that we are trying to verify, represented by an `Properties` enum.
        /// - parameter equalTo: String. The expected value of the property.
        /// - parameter expected result: Bool. A boolean indicating the expected result of the assertion. Pass `true` if you are verifying that the element exists, is selected, is hittable, etc.; pass `false` for the opposite.
        /// - returns: A generic value.
        @discardableResult
        func runActivity<A>(element description: String,
                            property: Properties,
                            equalTo: String,
                            expected result: Bool,
                            block: () -> A) -> A {
            var message = ""
            switch property {
            case .label:
                message = "label is\\(result ? "" : "n't") equal to \\(equalTo)"
            case .value:
                message = "value is\\(result ? "" : "n't") equal to \\(equalTo)"
            case .placeholderValue:
                message = "placeholderValue is\\(result ? "" : "n't") equal to \\(equalTo)"
            }
            let activityName = "\\(Icons.assert.rawValue) - \\(screenName) - Verifying if the \\(description) \\(message)"
            return XCTContext.runActivity(named: activityName) { _ in
                return block()
            }
        }
    }
    """
}

func generateBaseScreenContent() -> String {
    return """
    import Foundation
    import XCTest

    class BaseScreen: ScreenActivitiesProtocol {
        static let app = XCUIApplication()
        static let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        
        var screenName: String {
            String(describing: type(of: self))
        }
        
        required init() { }
    }
    """
}

func generateXCUIElementQueryExtensionContent() -> String {
    return """
    import XCTest

    extension XCUIElementQuery {    
        /// Extension to get an XCUIElementQuery from XCUIElementQuery where the label contains the text passed as an argument
        /// - parameter texts: String. The text that the label contains
        /// - parameter type: NSCompoundPredicate. LogicalType. An enum to choose the logical type out of AND, OR, NOT. Set to *AND* by default
        /// - parameter caseSensitive: Bool. Set to *true* by default
        /// - returns: XCUIElementQuery
        /// - _Examples:_
        /// ````
        /// BaseScreen.app.staticTexts.label(containing: "1")
        /// BaseScreen.app.staticTexts.label(containing: "1", "2")
        /// BaseScreen.app.staticTexts.label(containing: "1", "2", "3", caseSensitive: false)
        ///  ````
        func label(containing texts: String..., type: NSCompoundPredicate.LogicalType = .and, caseSensitive: Bool = true) -> XCUIElementQuery {
            let caseMode = caseSensitive ? "" : "[c]"
            let subPredicates = texts.map { NSPredicate(format: "label CONTAINS\\(caseMode)%@", $0) }
            let predicate = NSCompoundPredicate(type: type, subpredicates: subPredicates)
            return matching(predicate)
        }
        
        /// Extension to get an XCUIElementQuery from XCUIElementQuery where the label matches the text passed as an argument
        /// - parameter texts: String. The text that the label matches
        /// - parameter type: NSCompoundPredicate. LogicalType. An enum to choose the logical type out of AND, OR, NOT. Set to *AND* by default
        /// - parameter caseSensitive: Bool. Set to *true* by default
        /// - returns: XCUIElementQuery
        /// - _Examples:_
        /// ````
        /// BaseScreen.app.staticTexts.label(matching: "1")
        /// BaseScreen.app.staticTexts.label(matching: "1", "2")
        /// BaseScreen.app.staticTexts.label(matching: "1", "2", "3", caseSensitive: false)
        ///  ````
        func label(matching texts: String..., type: NSCompoundPredicate.LogicalType = .and, caseSensitive: Bool = true) -> XCUIElementQuery {
            let caseMode = caseSensitive ? "" : "[c]"
            let subPredicates = texts.map { NSPredicate(format: "label MATCHES\\(caseMode)%@", $0) }
            let predicate = NSCompoundPredicate(type: type, subpredicates: subPredicates)
            return matching(predicate)
        }
        
        /// Extension to get an XCUIElementQuery from XCUIElementQuery where the value contains the text passed as an argument
        /// - parameter texts: String. The text that the value contains
        /// - parameter type: NSCompoundPredicate. LogicalType. An enum to choose the logical type out of AND, OR, NOT. Set to *AND* by default
        /// - parameter caseSensitive: Bool. Set to *true* by default
        /// - returns: XCUIElementQuery
        /// - _Examples:_
        /// ````
        /// BaseScreen.app.staticTexts.value(containing: "1")
        /// BaseScreen.app.staticTexts.value(containing: "1", "2")
        /// BaseScreen.app.staticTexts.value(containing: "1", "2", "3", caseSensitive: false)
        ///  ````
        func value(containing texts: String..., type: NSCompoundPredicate.LogicalType = .and, caseSensitive: Bool = true) -> XCUIElementQuery {
            let caseMode = caseSensitive ? "" : "[c]"
            let subPredicates = texts.map { NSPredicate(format: "value CONTAINS\\(caseMode)%@", $0) }
            let predicate = NSCompoundPredicate(type: type, subpredicates: subPredicates)
            return matching(predicate)
        }
        
        /// Extension to get an XCUIElementQuery from XCUIElementQuery where the value matches the text passed as an argument
        /// - parameter texts: String. The text that the value matches
        /// - parameter type: NSCompoundPredicate. LogicalType. An enum to choose the logical type out of AND, OR, NOT. Set to *AND* by default
        /// - parameter caseSensitive: Bool. Set to *true* by default
        /// - returns: XCUIElementQuery
        /// - _Examples:_
        /// ````
        /// BaseScreen.app.staticTexts.value(matching: "1")
        /// BaseScreen.app.staticTexts.value(matching: "1", "2")
        /// BaseScreen.app.staticTexts.value(matching: "1", "2", "3", caseSensitive: false)
        ///  ````
        func value(matching texts: String..., type: NSCompoundPredicate.LogicalType = .and, caseSensitive: Bool = true) -> XCUIElementQuery {
            let caseMode = caseSensitive ? "" : "[c]"
            let subPredicates = texts.map { NSPredicate(format: "value MATCHES\\(caseMode)%@", $0) }
            let predicate = NSCompoundPredicate(type: type, subpredicates: subPredicates)
            return matching(predicate)
        }
            
        /// Extension to get an XCUIElementQuery from XCUIElementQuery where the value contains the text passed as an argument
        /// - parameter texts: String. The text that the value contains
        /// - parameter type: NSCompoundPredicate. LogicalType. An enum to choose the logical type out of AND, OR, NOT. Set to *AND* by default
        /// - parameter caseSensitive: Bool. Set to *true* by default
        /// - returns: XCUIElementQuery
        /// - _Examples:_
        /// ````
        /// BaseScreen.app.staticTexts.placeholderValue(containing: "1")
        /// BaseScreen.app.staticTexts.placeholderValue(containing: "1", "2")
        /// BaseScreen.app.staticTexts.placeholderValue(containing: "1", "2", "3", caseSensitive: false)
        ///  ````
        func placeholderValue(containing texts: String..., type: NSCompoundPredicate.LogicalType = .and, caseSensitive: Bool = true) -> XCUIElementQuery {
            let caseMode = caseSensitive ? "" : "[c]"
            let subPredicates = texts.map { NSPredicate(format: "placeholderValue CONTAINS\\(caseMode)%@", $0) }
            let predicate = NSCompoundPredicate(type: type, subpredicates: subPredicates)
            return matching(predicate)
        }
        
        /// Extension to get an XCUIElementQuery from XCUIElementQuery where the value matches the text passed as an argument
        /// - parameter texts: String. The text that the value matches
        /// - parameter type: NSCompoundPredicate. LogicalType. An enum to choose the logical type out of AND, OR, NOT. Set to *AND* by default
        /// - parameter caseSensitive: Bool. Set to *true* by default
        /// - returns: XCUIElementQuery
        /// - _Examples:_
        /// ````
        /// BaseScreen.app.staticTexts.placeholderValue(matching: "1")
        /// BaseScreen.app.staticTexts.placeholderValue(matching: "1", "2")
        /// BaseScreen.app.staticTexts.placeholderValue(matching: "1", "2", "3", caseSensitive: false)
        ///  ````
        func placeholderValue(matching texts: String..., type: NSCompoundPredicate.LogicalType = .and, caseSensitive: Bool = true) -> XCUIElementQuery {
            let caseMode = caseSensitive ? "" : "[c]"
            let subPredicates = texts.map { NSPredicate(format: "placeholderValue MATCHES\\(caseMode)%@", $0) }
            let predicate = NSCompoundPredicate(type: type, subpredicates: subPredicates)
            return matching(predicate)
        }
        
        /// Extension to get an XCUIElementQuery from XCUIElementQuery where the identifier contains the text passed as an argument
        /// - parameter texts: String. The text that the identifier contains
        /// - parameter type: NSCompoundPredicate. LogicalType. An enum to choose the logical type out of AND, OR, NOT. Set to *AND* by default
        /// - parameter caseSensitive: Bool. Set to *true* by default
        /// - returns: XCUIElementQuery
        /// - _Examples:_
        /// ````
        /// BaseScreen.app.staticTexts.identifier(containing: "1")
        /// BaseScreen.app.staticTexts.identifier(containing: "1", "2")
        /// BaseScreen.app.staticTexts.identifier(containing: "1", "2", "3", caseSensitive: false)
        ///  ````
        func identifier(containing texts: String...,
            type: NSCompoundPredicate.LogicalType = .and,
            caseSensitive: Bool = true
        ) -> XCUIElementQuery {
            let caseMode = caseSensitive ? "" : "[c]"
            let subPredicates = texts.map { NSPredicate(format: "identifier CONTAINS\\(caseMode)%@", $0) }
            let predicate = NSCompoundPredicate(type: type, subpredicates: subPredicates)
            return matching(predicate)
        }
    }
    """
}

func generateXCUIElementExtensionContent() -> String {
    return """
    import XCTest

    extension XCUIElement {
        /// Function to handle wait for different element's states
        /// - parameter state: ElementState.
        /// The enum to choose the element state out of exist, hittable, enabled, selected. The default value is set
        /// to *exist*.
        /// - parameter result: Bool. The expected result for the element state. The default value is set to *true*
        /// - parameter for timeout: Timeout. The enum to choose the timeout duration out of navigation and defaultTimeout.
        /// The default value is set to *normal*.
        /// - parameter isSlowed: Bool. The default value is set to *false*. If set to *true*, the function will wait for the
        /// full timeout before making an assertion
        /// - returns: Bool. A boolean, true or false.
        /// - warning: There are two ways to use this function for the negative assertions.
        /// If used with *XCTAssertFalse* it will wait for the full timeout before making an assertion.
        /// If used with *XCTAssertTrue* and the *result* is set to *false*, it will make an assertion at the moment when the
        /// condition is met.
        /// If the condition is met at the time when the function is called, it won't wait at all.
        /// It will work the same way as exists, isHittable, isEnabled or isSelected.
        func wait(
            state: ElementState = .exists,
            result: Bool = true,
            for timeout: Timeout = .normal,
            isSlowed: Bool = false
        ) -> Bool {
            if !isSlowed {
                switch state {
                case .exists:
                    if (result && exists) || (!result && !exists) {
                        return true
                    }
                case .hittable:
                    if (result && isHittable) || (!result && !isHittable) {
                        return true
                    }
                case .enabled:
                    if (result && isEnabled) || (!result && !isEnabled) {
                        return true
                    }
                case .selected:
                    let isSelectedState = checkSelectedState()
                    if (result && isSelectedState) || (!result && !isSelectedState) {
                        return true
                    }
                case .focused:
                    if (result && hasKeyboardFocus) || (!result && !hasKeyboardFocus) {
                        return true
                    }
                case .visible:
                    if (result && isVisible) || (!result && !isVisible) {
                        return true
                    }
                }
            }

            // For .selected state, use custom predicate that checks both isSelected and value
            if state == .selected {
                let predicate = NSPredicate { _, _ in
                    self.checkSelectedState() == result
                }
                let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
                return XCTWaiter().wait(for: [expectation], timeout: timeout.rawValue) == .completed
            }

            let predicate = NSPredicate(format: "\\(state.rawValue) == \\(result ? "true" : "false")")
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
            return XCTWaiter().wait(for: [expectation], timeout: timeout.rawValue) == .completed
        }

        /// Checks if element is in selected state by verifying either:
        /// - Standard iOS isSelected trait (for native TabView/UITabBar)
        /// - accessibilityValue contains "selected" case-insensitively (for PDS components like PDSTabs)
        /// - Returns: Bool indicating if element is selected
        private func checkSelectedState() -> Bool {
            // Check standard iOS selected trait
            if isSelected {
                return true
            }
            // Check PDS components that use accessibilityValue with "selected" text
            if let value = value as? String {
                return value.lowercased().contains("selected")
            }
            return false
        }

        /// Taps on the element at a specific offset relative to its bounds, regardless of its state.
        /// - Parameters:
        ///   - dx: A horizontal offset, specified as a normalized value between 0.0 and 1.0,
        ///         where 0.0 represents the left edge of the element and 1.0 represents the right edge.
        ///         The default value is 0.5, which corresponds to the horizontal center of the element.
        ///   - dy: A vertical offset, specified as a normalized value between 0.0 and 1.0,
        ///         where 0.0 represents the top edge of the element and 1.0 represents the bottom edge.
        ///         The default value is 0.5, which corresponds to the vertical center of the element.
        ///
        /// - Note: Values outside the 0.0...1.0 range are valid and tap a point beyond the element's bounds.
        ///         For example, dx: 1.5 taps 50% of the element's width to the right of its right edge.
        ///         This is useful for tapping elements that are partially off-screen or obscured by overlapping views.
        ///
        /// - Usage:
        /// ```swift
        /// element.forceTapWithOffset() // Taps the center of the element
        /// element.forceTapWithOffset(dx: 0.2, dy: 0.8) // Taps near the bottom-left corner of the element
        /// element.forceTapWithOffset(dx: 1.5, dy: 0.5) // Taps outside the right edge of the element
        /// ```
        func forceTapWithOffset(dx: Double = 0.5, dy: Double = 0.5) {
            coordinate(withNormalizedOffset: CGVector(dx: dx, dy: dy)).tap()
        }

        /// Asserts the state of a UI element based on the expected condition.
        /// - parameter state: `ElementState`. The state of the element to check. Possible values are `.exists`, `.hittable`,
        /// `.enabled`, `.selected`, and `.focused`. Default is `.exists`.
        /// - parameter result: `Bool`. The expected result of the state assertion. Default is `true`.
        /// - parameter timeout: `TestTimeout`. The time within which the element state must meet the expected result. Default
        /// is `.defaultTimeout`.
        /// - parameter file: `StaticString`. The file where the assertion is performed. Used for logging purposes when the
        /// test fails. Default is the current file.
        /// - parameter line: `UInt`. The line number where the assertion is performed. Used for logging purposes when the
        /// test fails. Default is the current line.
        /// - warning: Use `XCTAssertTrue` to verify if the condition is satisfied. If you want to assert that the element
        /// doesn't match the state, set the `result` parameter to `false`.
        /// - returns: `Void`. Asserts the condition and logs error if it fails.
        ///
        /// - _Examples:_
        ///   - To verify the element exists:
        ///     ```swift
        ///     assert(state: .exists)
        ///     ```
        ///     or
        ///     ```swift
        ///     assert()
        ///     ```
        ///   - To verify the element is not selected:
        ///     ```swift
        ///     assert(state: .selected, result: false)
        ///     ```
        func assert(
            state: ElementState = .exists,
            expected result: Bool = true,
            timeout: Timeout = .normal,
            file: StaticString = #filePath,
            line: UInt = #line
        ) {
            var message = ""
            switch state {
            case .exists:
                message = "\\(result ? "doesn't exist" : "exists")"
            case .hittable:
                message = "is\\(result ? "n't" : "") hittable"
            case .enabled:
                message = "is \\(result ? "disabled" : "enabled")"
            case .selected:
                message = "is\\(result ? "n't" : "") selected"
            case .focused:
                message = "has\\(result ? " no" : "") focus"
            case .visible:
                message = "is\\(result ? " not" : "") visible"
            }
            let error = "\\(Icons.error.rawValue) — The \\(description) \\(message)"
            XCTAssertTrue(wait(state: state, result: result, for: timeout), "\\(error)", file: file, line: line)
        }

        /// Asserts that a specific property of a UI element matches an expected value.
        /// - parameter property: `Properties`. The property of the element to check. Possible values are `.label`, `.value`,
        /// and `.placeholderValue`.
        /// - parameter equalTo: `String`. The expected value of the property.
        /// - parameter expected: `Bool`. The expected result of the comparison. Default is `true`.
        /// - parameter timeout: `TestTimeout`. The time within which the property value must match the expected result.
        /// Default is `.defaultTimeout`.
        /// - parameter file: `StaticString`. The file where the assertion is performed. Used for logging purposes when the
        /// test fails. Default is the current file.
        /// - parameter line: `UInt`. The line number where the assertion is performed. Used for logging purposes when the
        /// test fails. Default is the current line.
        /// - warning: Use `XCTAssertEqual` or `XCTAssertNotEqual` based on the `expected` parameter to validate the
        /// condition.
        /// - returns: `Void`. Asserts the condition and logs error if it fails.
        ///
        /// - _Examples:_
        ///   - To verify the label of an element equals "Submit":
        ///     ```swift
        ///     assert(for: .label, equalTo: "Submit")
        ///     ```
        ///   - To verify the value of an element is not equal to "Jane Doe":
        ///     ```swift
        ///     assert(for: .value, equalTo: "Jane Doe", expected: false)
        ///     ```
        func assert(
            for property: Properties,
            equalTo: String,
            expected result: Bool = true,
            timeout: Timeout = .normal,
            file: StaticString = #file,
            line: UInt = #line
        ) {
            // Build the predicate that re-reads the property value on each evaluation
            let predicate = NSPredicate { _, _ in
                let actualValue: String? = {
                    switch property {
                    case .label:
                        return self.label
                    case .value:
                        return self.value as? String
                    case .placeholderValue:
                        return self.placeholderValue
                    }
                }()
                guard let actual = actualValue else {
                    return false
                }
                return result ? (actual == equalTo) : (actual != equalTo)
            }
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
            let waiterResult = XCTWaiter().wait(for: [expectation], timeout: timeout.rawValue)

            // Re-read the current value for accurate error message
            let currentValue: String? = {
                switch property {
                case .label:
                    return label
                case .value:
                    return value as? String
                case .placeholderValue:
                    return placeholderValue
                }
            }()
            if result {
                XCTAssertEqual(
                    waiterResult,
                    .completed,
                    "\\(Icons.error.rawValue) Expected \\(property.rawValue) to be equal '\\(equalTo)', but found '\\(currentValue ?? "nil")'.",
                    file: file,
                    line: line
                )
            } else {
                XCTAssertEqual(
                    waiterResult,
                    .completed,
                    "\\(Icons.error.rawValue) Expected \\(property.rawValue) not to be equal '\\(equalTo)', but found '\\(currentValue ?? "nil")'.",
                    file: file,
                    line: line
                )
            }
        }

        var hasKeyboardFocus: Bool {
            guard let hasFocus = value(forKey: "hasKeyboardFocus") as? Bool else {
                return false
            }
            return hasFocus
        }

        func focusAndEnter(text: String) {
            for _ in 0 ..< 5 {
                if hasKeyboardFocus { break }
                tap()
            }
            typeText(text)
        }

        func enter(text: String) {
            tap()
            typeText(text)
        }

        /// The bounds to check element visibility against.
        /// On iPad, the app window may be smaller than the screen (split view, slide over, multitasking),
        /// so we use the window frame to get the actual visible area of the app.
        /// On iPhone, the app always occupies the full screen, so we use screen bounds directly
        /// to avoid creating an unnecessary XCUIApplication instance.
        private var visibilityBounds: CGRect {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let window = XCUIApplication().windows.element(boundBy: 0)
                if window.exists, !window.frame.isEmpty {
                    return window.frame
                }
            }
            // iPhone or fallback: app always occupies the full screen
            let screenSize = XCUIScreen.main.screenshot().image.size
            return CGRect(origin: .zero, size: screenSize)
        }

        /// Returns true if the element exists and is at least partially visible on screen
        var isVisible: Bool {
            guard exists else { return false }
            return visibilityBounds.intersects(frame)
        }

        /// Returns true if the element exists and is completely visible within the screen bounds
        var isFullyVisible: Bool {
            guard exists, !frame.isEmpty else { return false }
            return visibilityBounds.contains(frame)
        }

        /// Returns true if the element's point at the given normalized offset is visible on screen.
        /// - Parameters:
        ///   - dx: Normalized X offset within the element's frame (0...1). Default: 0.5 (center).
        ///   - dy: Normalized Y offset within the element's frame (0...1). Default: 0.5 (center).
        ///   - tabBarPresent: Pass true when a UITabBar is present; the point must not be covered by it.
        func isVisibleAtOffset(
            dx: CGFloat = 0.5,
            dy: CGFloat = 0.5,
            tabBarPresent: Bool = false
        ) -> Bool {
            guard exists else { return false }
            let vector = CGVector(dx: dx, dy: dy)
            let coordinate = coordinate(withNormalizedOffset: vector)
            let screenPoint = coordinate.screenPoint
            let screenSize = XCUIScreen.main.screenshot().image.size
            let screenBounds = CGRect(origin: .zero, size: screenSize)
            if tabBarPresent {
                let tabBar = XCUIApplication().tabBars.firstMatch
                if tabBar.exists, tabBar.frame.contains(screenPoint) {
                    return false
                }
            }
            return screenBounds.contains(screenPoint) && frame.contains(screenPoint)
        }

        func turnSwitch(_ state: SwitchState) {
            if let stateValue = value as? String, stateValue != state.rawValue {
                tap()
            }
        }

        /// Checks if element is fully contained within the content area between island and tab bar
        /// - Returns: True if element is completely within the usable content area
        func isFullyInContentArea() -> Bool {
            let app = XCUIApplication()
            let topBoundary: CGFloat
            let navBar = app.navigationBars.firstMatch
            if navBar.exists {
                topBoundary = navBar.frame.maxY
            } else {
                let screenHeight = app.frame.height
                topBoundary = screenHeight >= 800 ? 59 : 20
            }
            let bottomBoundary: CGFloat
            let tabBar = app.tabBars.element(boundBy: 0)
            if tabBar.exists {
                bottomBoundary = tabBar.frame.minY
            } else {
                let allTabBars = app.descendants(matching: .tabBar)
                if allTabBars.allElementsBoundByIndex.isEmpty == false,
                   let firstTabBar = allTabBars.allElementsBoundByIndex.first {
                    bottomBoundary = firstTabBar.frame.minY
                } else {
                    bottomBoundary = app.frame.height
                }
            }
            let elementTop = frame.minY
            let elementBottom = frame.maxY
            let isFullyVisible = elementTop > topBoundary && elementBottom < bottomBoundary
            return isFullyVisible
        }

        func safeTap(timeout: Timeout = .short) {
            guard wait(state: .hittable, for: timeout) else {
                XCTFail("Element is not hittable: \\(self)")
                return
            }
            tap()
        }

        func swipeUntil(
            in direction: SwipeDirection = .up,
            maxAttempts: Int = 5
        ) {
            for _ in 0 ..< maxAttempts {
                if wait(state: .hittable, for: .short) { return }
                switch direction {
                case .up: swipeUp()
                case .down: swipeDown()
                case .left: swipeLeft()
                case .right: swipeRight()
                }
            }
        }

        func swipeToAndTapElement(
            withText text: String,
            direction: SwipeDirection = .left,
            maxAttempts: Int = 5
        ) {
            let element = descendants(matching: .staticText)[text].firstMatch
            for _ in 0 ..< maxAttempts {
                if element.wait(state: .hittable, for: .short) { break }
                switch direction {
                case .up: swipeUp()
                case .down: swipeDown()
                case .left: swipeLeft()
                case .right: swipeRight()
                }
            }
            element.tap()
        }

        func swipeUntilVisible(
            withText text: String,
            direction: SwipeDirection = .left,
            maxAttempts: Int = 5
        ) {
            let element = descendants(matching: .staticText)[text].firstMatch
            for _ in 0 ..< maxAttempts {
                if element.wait(state: .visible, for: .short) { break }
                switch direction {
                case .up: swipeUp()
                case .down: swipeDown()
                case .left: swipeLeft()
                case .right: swipeRight()
                }
            }
        }

        /// Asserts that a dynamically computed value matches an expected value with wait support.
        /// - parameter actualValue: `@escaping () -> T`. A closure that returns the actual value to compare. The closure is
        /// called repeatedly during the wait period to check if the value matches the expected value.
        /// - parameter equalTo: `T`. The expected value for comparison. Must be of the same type as the value returned by the
        /// `actualValue` closure.
        /// - parameter expected: `Bool`. The expected result of the comparison. If `true`, asserts that values are equal.
        /// If `false`, asserts that values are not equal. Default is `true`.
        /// - parameter timeout: `Timeouts`. The time within which the value must match the expected result. Default is `.normal`.
        /// - parameter file: `StaticString`. The file where the assertion is performed. Default: current file.
        /// - parameter line: `UInt`. The line number where the assertion is performed. Default: current line.
        /// - warning: The `actualValue` closure is called multiple times during the wait period. Use this assertion when
        /// validating dynamic values that may change over time (e.g., text being typed, asynchronous updates).
        /// - returns: `Void`. Asserts the condition and logs error if it fails.
        ///
        /// - _Examples:_
        ///   - To verify that a password field contains the expected number of characters:
        ///     ```swift
        ///     passwordField.assertValue(
        ///         actualValue: { (passwordField.value as? String ?? "").count },
        ///         equalTo: password.password.count
        ///     )
        ///     ```
        ///   - To verify that an email field contains the expected value:
        ///     ```swift
        ///     emailField.assertValue(
        ///         actualValue: { emailField.value as? String ?? "" },
        ///         equalTo: "user@example.com"
        ///     )
        ///     ```
        ///   - To verify that a label text equals the expected value with short timeout:
        ///     ```swift
        ///     statusLabel.assertValue(
        ///         actualValue: { statusLabel.label },
        ///         equalTo: "Success",
        ///         timeout: .short
        ///     )
        ///     ```
        ///   - To verify that an error label is not empty (inequality check):
        ///     ```swift
        ///     errorLabel.assertValue(
        ///         actualValue: { errorLabel.label },
        ///         equalTo: "",
        ///         expected: false
        ///     )
        ///     ```
        ///   - To verify that a toggle switch is enabled:
        ///     ```swift
        ///     toggleSwitch.assertValue(
        ///         actualValue: { toggleSwitch.isEnabled },
        ///         equalTo: true
        ///     )
        ///     ```
        ///   - To verify that a status value is not "Error":
        ///     ```swift
        ///     statusLabel.assertValue(
        ///         actualValue: { statusLabel.label },
        ///         equalTo: "Error",
        ///         expected: false
        ///     )
        ///     ```
        func assertValue<T: Equatable>(
            actualValue: @escaping () -> T,
            equalTo expectedValue: T,
            expected result: Bool = true,
            timeout: Timeout = .normal,
            file: StaticString = #file,
            line: UInt = #line
        ) {
            let predicate = NSPredicate { _, _ in
                let actual = actualValue()
                return result ? (actual == expectedValue) : (actual != expectedValue)
            }
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
            let waiterResult = XCTWaiter().wait(for: [expectation], timeout: timeout.rawValue)
            let actual = actualValue()
            if result {
                XCTAssertEqual(
                    waiterResult,
                    .completed,
                    "\\(Icons.error.rawValue) Expected value to be equal '\\(expectedValue)', but found '\\(actual)'.",
                    file: file,
                    line: line
                )
            } else {
                XCTAssertEqual(
                    waiterResult,
                    .completed,
                    "\\(Icons.error.rawValue) Expected value not to be equal '\\(expectedValue)', but found '\\(actual)'.",
                    file: file,
                    line: line
                )
            }
        }
    }
    """
}

func generateElementStateEnumContent() -> String {
    return """
    import Foundation

    enum ElementState: String {
        case exists = "exists"
        case hittable = "isHittable"
        case enabled = "isEnabled"
        case selected = "isSelected"
        case focused = "hasKeyboardFocus"
        case visible = "isVisible"
    }
    """
}

func generateTimeoutEnumContent() -> String {
    return """
    import Foundation

    enum Timeout: TimeInterval {
        case loading = 20.0
        case normal = 3.0
        case short = 1.0
    }
    """
}

func generateIconsEnumContent() -> String {
    return """
    import Foundation

    enum Icons: String {
        case screen = "⏹️"
        case step = "🔹"
        case assert = "☑️"
        case error = "❌"
        case test = "🔵"
    }
    """
}

func generateTabsExampleEnumContent() -> String {
    return """
    import Foundation

    enum TabsExample: String {
        case home = "Home"
        case profile = "Profile"
        case settings = "Settings"
    }
    """
}

func generatePropertiesEnumContent() -> String {
    return """
    import Foundation

    enum Properties: String {
        case label
        case value
        case placeholderValue
    }
    """
}

func generateSwipeDirectionEnumContent() -> String {
    return """
    import Foundation

    enum SwipeDirection {
        case up
        case down
        case left
        case right
    }
    """
}

func generateSwitchStateEnumContent() -> String {
    return """
    import Foundation

    enum SwitchState: String {
        case on = "1"
        case off = "0"
        
        var description: String {
            switch self {
            case .on:
                return "On"
            case .off:
                return "Off"
            }
        }
    }
    """
}
