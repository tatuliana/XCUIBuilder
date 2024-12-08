
![XCUIBuilder_small_logo](https://github.com/user-attachments/assets/80dac084-e6b1-4d12-975d-50a5b35a3f1d)

# XCUIBuilder 

**XCUIBuilder** is a Swift-based command-line tool designed to deploy a robust and reusable UI testing framework for iOS projects. By automating the creation of a structured folder hierarchy and generating pre-written examples for screens and tests, it enables seamless integration of a scalable and efficient UI testing framework into your project.

The tool deploys a framework that incorporates the functionality of the **XCUIEnhance** library, extended with a modified custom `wait()` function. Unlike the original library, which relied on raw time intervals, the modified version uses a `Timeout` enum to define durations (e.g., 'loading', 'normal', 'short'). While the framework ensures consistent timeouts across all environments, it is designed to allow easy customization if different durations are needed for mock and live environments. Such changes would require no modifications to the deployed framework, as the `wait()` function would seamlessly adapt to any updates in the `Timeout` enum.
## 🚀 Features
### Features of XCUIBuilder:
- Automates the deployment of a reusable and scalable **XCUITest framework**.
- Creates a consistent folder hierarchy, including `Support`, `Screens`, and `Tests` directories.
- Dynamically generates shared files (e.g., protocols, extensions, enums) and pattern-specific implementations tailored to your project needs.
- Guides you through the setup process via an interactive command-line interface.

### Features of the Deployed Framework:
**1. Out-of-the-Box Solution:**
  - Implements the **Page Object Model** combined with a **Builder Pattern**, providing a clean and scalable architecture for UI testing.
  - Features an advanced logging system:
    - Creates well-structured and easy-to-read logs.
    - Automatically generates log messages for assertions via `runActivity` functions.
    - Produces detailed error messages using `assert()` extensions, improving debugging efficiency.
    - Logs accurate screen names for better traceability.

**2. Flexible Chaining Patterns:**

**Screen Transition Chaining**:
  - Every function returns an instance of the screen, which could be:
    - The same screen.
    - The next screen in the flow.
    - A generic screen when the function may navigate to different screens based on the flow (in this case, you must explicitly specify the screen name where the function will land).
  - Verifies the screen state after returning every screen, which helps manage timeouts automatically, reducing the effort required to handle asynchronous calls and complex user interactions.
  - Allows chaining functions seamlessly without needing to repeatedly specify the screen name within the same screen.
  - Offers exceptional **stability** and delivers the **highest performance**, making it the fastest and most efficient approach.
  - Example:
<img width="678" alt="Screenshot 2024-11-30 at 12 34 16 AM" src="https://github.com/user-attachments/assets/fc7f02d5-8974-4216-8c7c-206000981bad">

**Self Chaining**:
  - Always returns `self`, with the screen state verified only during initialization.
  - Produces well-readable and maintainable test code, offering a simpler and more user-friendly approach compared to **Screen Transition Chaining**.
  - Slightly slower than **Screen Transition Chaining** and, in rare cases, may require a more refined approach to handle complex user interactions effectively.
  - Despite these minor drawbacks, it remains a highly stable and reliable solution for UI testing.
  - Example:
<img width="438" alt="Screenshot 2024-11-30 at 12 39 06 AM" src="https://github.com/user-attachments/assets/cc019eed-d77b-4901-8ee0-d6deb368d947">

### 3. Comprehensive Examples:
 - Includes example screens (`LaunchScreen`, `LoginScreen`, `HomeScreen`) and UI tests.
 - Modifiable `TabBarProtocol` with a customizable `Tabs` enum and element locators.

**Pattern-Specific Examples:**

- **Screen Transition Chaining:**
  - Offers two versions of examples for writing assertions:
    1. Using the built-in `XCTAssert` functions directly within the test cases.
    2. Writing `assert` functions in the screen classes, leveraging the `assert` extensions. This approach provides automatic error message generation based on the arguments passed, simplifying debugging and improving readability.
- **Self Chaining:**
Demonstrates the second version only, where `assert` functions are implemented in screen classes using the `assert` extensions. This ensures automatic error message generation and a clean, readable test flow.


## 📂 Folder Structure

After running XCUIBuilder, your project will follow this structure:

<img width="496" alt="Screenshot 2024-11-29 at 9 35 01 PM" src="https://github.com/user-attachments/assets/0a02d6c6-a786-46ea-85bd-9bf33c3582f8">

## 🛠️ Setup

Follow these steps to set up XCUIBuilder and deploy the framework version of your choice:
### 1. Clone the Repository:

Download the XCUIBuilder project to your local machine:
```bash
git clone https://github.com/tatuliana/XCUIBuilder.git
cd XCUIBuilder
```
### 2. Open the Project in Xcode:

Open the project to start using the tool:
```bash
open XCUIBuilder.xcodeproj
```
### 3. Run the Tool:
   Click the `Run` button in Xcode to start the tool. Follow the instructions in the console:
  - **Step 1:** Enter the path to your Xcode project (e.g., `path/to/MyApp.xcodeproj` or project folder). Alternatively, you can drag your project file or folder directly into the Xcode console to automatically generate the correct path.
  - **Step 2:** Enter the name of the existing UI Testing target (e.g., `MyAppUITests`). Note: **XCUIBuilder** does not create a new UI Testing target automatically. If you don't already have a UI Testing target, you will need to create one manually in Xcode before running the tool. To do this:
    - Go to Xcode.
    - Click on your **project name** (the top line in your file navigator).
    - Click the `+` button at the bottom of the target list.
    - Select **UI Testing Bundle** and follow the prompts.
  - **Step 3:** Choose the framework version to deploy:

    **1: Screen Transition Chaining**
    
    **2: Self Chaining**
### 4. Verify Setup:

After the deployment, verify that the newly created framework folders are added to your target. If the folders do not appear in Xcode, close the Xcode app and reopen your project to refresh the file structure.

## 📱Demo App

To help you explore **XCUIBuilder** and its capabilities, I’ve created a sample iOS app that:

- **Serves as a testing ground** for the deployed framework.
- Allows you to deploy one pattern at a time (**Screen Transition Chaining** or **Self Chaining**) and run the pre-written test examples included in the deployed framework.
- Since these tests were written specifically for this app, you can build and run them to see real examples of logs generated by the framework.

### Important Note
The app does not have a backend. However, it provides a clear picture of the framework’s features and the deployment process, allowing you to evaluate its functionality.

### Clone the Demo App

You can find the demo app repository here: [TestApp](https://github.com/tatuliana/TestApp.git)

To try it out:

1. Clone the demo app repository:
```bash
git clone https://github.com/tatuliana/TestApp.git
cd TestApp
```
2. Open the app in Xcode.
3. Use **XCUIBuilder** to deploy the framework with your chosen pattern, then build and run the pre-written test examples in the deployed framework to experience its functionality in action.


## 🔧 Post-Deployment Customization and Next Steps

Once the framework has been successfully deployed, here’s what you can do next:

### 1. Remove the Deployment Tool
The tool used for deployment is no longer required after setup and can be safely removed from your project.

### 2. Create New Screens and Tests
Adapt the deployed framework to your specific app by:

Creating new screen classes with real UI element locators.
Writing functions for these screens following the provided examples.
Adding test cases tailored to your workflows using the deployed framework.

### 3. Modify the Framework
The deployed framework is fully customizable, enabling you to:

- Add new features or utilities to enhance your testing capabilities.
- Adjust the directory structure to better suit your project’s needs.
- Customize the configuration, such as enums or protocols, to align with your app's architecture.
> **Note**: Ensure that modifications are thoroughly tested to maintain the integrity and functionality of the framework.

## 🧩 Extending Framework Development with [XCUISnippetDeployer](https://github.com/tatuliana/XCUISnippet_Deployer/tree/main)
Once the foundational framework has been deployed with **XCUIBuilder**, you can enhance your workflow by leveraging **XCUISnippetDeployer**. This complementary tool simplifies and accelerates the development of additional tests by providing ready-to-use, well-structured code snippets that align with the architecture deployed by **XCUIBuilder**.

### What is XCUISnippetDeployer?
**XCUISnippetDeployer** is a CLI tool that:
- Automates the deployment of Xcode code snippets for common XCUITest patterns.
- Supports 2 design patterns, **Screen Transition Chaining** and **Self-Chaining**, ensuring consistency with the chosen framework architecture.
- Helps developers streamline test writing, improving both productivity and code quality.

### How Does It Work?
1. Select a pattern in **XCUISnippetDeployer** that matches your framework architecture.
2. Deploy snippets into Xcode's environment with a single command.
3. Access the deployed snippets in Xcode's snippet manager (`Command + Shift + L`) to efficiently create new screens in your Page Object Model (POM) and add test cases with consistent patterns and best practices.

### When to Use XCUISnippetDeployer?
- **After Initial Framework Deployment**: Use XCUISnippetDeployer to add code snippets for screens, protocols, assertions, and reusable test components.
- **To Maintain Consistency**: Snippets align perfectly with the XCUIBuilder-generated architecture, ensuring uniformity across your test codebase.

### Integration with XCUIBuilder
- **XCUIBuilder** lays the foundation of the XCUITest framework with a robust directory structure, base classes, extensions and protocols.
- **XCUISnippetDeployer** builds upon this foundation, offering pre-defined templates and reusable patterns to speed up test development.

### Getting Started
Refer to the [XCUISnippetDeployer documentation](https://github.com/tatuliana/XCUISnippet_Deployer/tree/main) for installation and usage instructions.

## 🤝 Contributing

1. Fork the repository and create your feature branch.
2. Add your changes (e.g., new builder patterns, protocols, or utilities).
3. Commit your changes with a descriptive message.
4. Push your branch and create a pull request.

## 📜 License

This project is licensed under the [Apache License 2.0](https://github.com/tatuliana/XCUIEnhance/blob/main/LICENSE).

You may use, distribute, and modify this code under the terms of the license. A copy of the license is included in this repository.

