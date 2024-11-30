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
        /// The enum to choose the element state out of exist, hittable, enabled, selected. The default value is set to*exist*.
        /// - parameter result: Bool. The expected result for the element state. The default value is set to *true*
        /// - parameter for timeout: Timeout. The enum to choose the timeout duration out of navigation and defaultTimeout. The default value is set to *normal*.
        /// - parameter isSlowed: Bool. The default value is set to *false*. If set to *true*, the function will wait for the full timeout before making an assertion
        /// - returns: Bool. A boolean, true or false.
        /// - warning: There are two ways to use this function for the negative assertions.
        /// If used with *XCTAssertFalse* it will wait for the full timeout before making an assertion.
        /// If used with *XCTAssert True* and the *result* is set to *false*, it will make an assertion at the moment when the condition is met.
        /// If the condition is met at the time when the function is called, it won't wait at all.
        /// It will work the same way as exists, isHittable, isEnabled or isSelected.
        func wait(state: ElementState = .exists, result: Bool = true, for timeout: Timeout = .normal, isSlowed: Bool = false) -> Bool {
            if !isSlowed{
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
                    if (result && isSelected) || (!result && !isSelected) {
                        return true
                    }
                case .focused:
                    if (result && hasFocus) || (!result && !hasFocus) {
                        return true
                    }
                }
            }
            let predicate = NSPredicate(format: "\\(state.rawValue) == \\(result ? "true" : "false")")
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
            return XCTWaiter.wait(for: [expectation], timeout: timeout.rawValue) == .completed
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
        /// - Usage:
        /// ```swift
        /// element.forceTapWithOffset() // Taps the center of the element
        /// element.forceTapWithOffset(dx: 0.2, dy: 0.8) // Taps near the bottom-left corner of the element
        /// ```
        func forceTapWithOffset(dx: Double = 0.5, dy: Double = 0.5) {
            coordinate(withNormalizedOffset: CGVector(dx: dx, dy: dy)).tap()
        }
        
        
        /// Returns sibling elements of the given type, if the current element can be identified by an `identifier` or a `label`.
        /// - Parameters:
        ///   - siblingType: The type of sibling elements you want to find.
        ///   - parentType: The type of the parent element containing both the current element and its siblings.
        /// - Returns: A query for sibling elements of the given type, or nil if the parent is not found.
        func siblings(ofType siblingType: XCUIElement.ElementType, inParentOfType parentType: XCUIElement.ElementType) -> XCUIElementQuery? {
            // Search the entire hierarchy for an ancestor of the specified type
            let ancestorQuery = BaseScreen.app.descendants(matching: parentType)
            
            // Look for the parent that contains both the current element (self) and its siblings
            for index in 0..<ancestorQuery.count {
                let potentialParent = ancestorQuery.element(boundBy: index)
                
                // Check if the current element (`self`) is a child of this parent
                let parentChildren = potentialParent.children(matching: .any)
                let siblings = potentialParent.children(matching: siblingType)
                for i in 0..<parentChildren.count {
                    let child = parentChildren.element(boundBy: i)
                    if child.identifier == self.identifier && self.identifier != "" {
                        // Found the parent, return the siblings of the specified type
                        return siblings.matching(NSPredicate(format: "self.identifier != %@.identifier", self))
                    } else if child.label == self.label && self.label != "" {
                        return siblings.matching(NSPredicate(format: "self.label != %@.label", self))
                    } else {
                        continue
                    }
                }
            }
            return nil
        }
        
        /// Asserts the state of a UI element based on the expected condition.
        /// - parameter state: `ElementState`. The state of the element to check. Possible values are `.exists`, `.hittable`, `.enabled`, `.selected`, and `.focused`. Default is `.exists`.
        /// - parameter result: `Bool`. The expected result of the state assertion. Default is `true`.
        /// - parameter timeout: `TestTimeout`. The time within which the element state must meet the expected result. Default is `.defaultTimeout`.
        /// - parameter file: `StaticString`. The file where the assertion is performed. Used for logging purposes when the test fails. Default is the current file.
        /// - parameter line: `UInt`. The line number where the assertion is performed. Used for logging purposes when the test fails. Default is the current line.
        /// - warning: Use `XCTAssertTrue` to verify if the condition is satisfied. If you want to assert that the element doesn't match the state, set the `result` parameter to `false`.
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
        func assert(state: ElementState = .exists,
                    expected result: Bool = true,
                    timeout: Timeout = .normal,
                    file: StaticString = #filePath,
                    line: UInt = #line) {
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
            }
            let error = "\\(Icons.error.rawValue) - The \\(description) \\(message)"
            XCTAssertTrue(wait(state: state, result: result, for: timeout), "\\(error)", file: file, line: line)
        }
        
        /// Asserts that a specific property of a UI element matches an expected value.
        /// - parameter property: `Properties`. The property of the element to check. Possible values are `.label`, `.value`, and `.placeholderValue`.
        /// - parameter equalTo: `String`. The expected value of the property.
        /// - parameter expected: `Bool`. The expected result of the comparison. Default is `true`.
        /// - parameter timeout: `TestTimeout`. The time within which the property value must match the expected result. Default is `.defaultTimeout`.
        /// - parameter file: `StaticString`. The file where the assertion is performed. Used for logging purposes when the test fails. Default is the current file.
        /// - parameter line: `UInt`. The line number where the assertion is performed. Used for logging purposes when the test fails. Default is the current line.
        /// - warning: Use `XCTAssertEqual` or `XCTAssertNotEqual` based on the `expected` parameter to validate the condition.
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
            let actualValue: String? = {
                switch property {
                case .label:
                    return label
                case .value:
                    return value as? String
                case .placeholderValue:
                    return placeholderValue
                }
            }()
            
            // Ensure we have an actual value to compare
            guard let actual = actualValue else {
                XCTFail("\\(Icons.error.rawValue) Property '\\(property.rawValue)' is nil or not of type String.", file: file, line: line)
                return
            }
            
            // Build the predicate for comparison
            let comparison = result ? "==" : "!="
            let predicate = NSPredicate(format: "SELF \\(comparison) %@", equalTo)
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: actual)
            
            // Wait for the predicate to succeed
            let waiterResult = XCTWaiter().wait(for: [expectation], timeout: timeout.rawValue)
            
            // Assert based on the result
            if result {
                XCTAssertEqual(waiterResult, .completed, "\\(Icons.error.rawValue) Expected \\(property.rawValue) to be equal '\\(equalTo)', but found '\\(actual)'.", file: file, line: line)
            } else {
                XCTAssertEqual(waiterResult, .completed, "\\(Icons.error.rawValue) Expected \\(property.rawValue) not to be equal '\\(equalTo)', but found '\\(actual)'.", file: file, line: line)
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
        case focused = "hasFocus"
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

func generateTabsEnumContent() -> String {
    return """
    import Foundation

    enum Tabs: String {
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
