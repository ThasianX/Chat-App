# Chat App

### How to set up
1. Navigate to the directory in which you have the project downloaded.
2. Run 'pod install'
3. Open the newly created workspace file in the project directory
4. Create a Firebase account and register a new app, following Firebase's instructions
5. Once you get the GoogleService-Info.plist file, add it into the Supporting Files folder of the project with yours
6. The app is ready to run

### Planning

#### List of Features

- Core feature:  The user should be able to chat with an AI chat bot and the chat bot will initiate a conversation.
- Cool: Having the bot being able to detect if the user is happy or sad
- Chat logs should be persisted
- No image support
- Flow: User enters a message. Message is processed and given to the chat bot as input. Chat bot outputs a message which will then be displayed as a message in the UI.

#### UI Screens, tools, development concepts, and Swift classes

- Use Raywenderlich's chat project as a template to start
- MessageKit will design the chat UI for me
- Got to find some AI library online. Not sure if CoreML will support my needs
- Concepts: MVVM, Factories, Object oriented programming
- Classes: Setup, ChatView, SettingsView

#### Data Structure

- Firestone database for cloud and offline database
- UserDefaults for preferences
- Messages will be stored in a message struct provided by MessageKit

#### Frameworks, Tools, and Libraries

- Cocoapods
- Firebase
- MessageKit
- CoreML?
