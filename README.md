# Flutter Forum App

A fully functional cross-platform forum application built with Flutter, powered by **Firebase** and enhanced with **VelocityX**. This app supports Web, Mobile (Android/iOS), and Desktop platforms.

## 📋 Requirements

Before setting up the project, ensure you have the following installed:

- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install) (Stable channel recommended)
- **Dart SDK**: Included with Flutter
- **Firebase Project**: A project created in the [Firebase Console](https://console.firebase.google.com/)
- **Node.js** (Optional): For using Firebase CLI/FlutterFire CLI
- **Operating System Specifics**:
    - **Windows**: Enable "Developer Mode" in system settings to support symlinks for plugins.
    - **Web**: Chrome or Edge browser.
    - **Android**: Android Studio and an emulator or physical device.

## 🚀 Features

### User Authentication (Firebase Auth)
- **Register**: Create an account using Email and Password.
- **Login**: Secure access to the forum.
- **Logout**: Persistent session management.
- **Profile**: View and edit your name and avatar.

### Forum Functionality (Cloud Firestore)
- **Home Screen**: 
    - Sidebar showing a real-time list of **Topics**.
    - Main feed showing the **Latest Posts**.
    - Search bar to filter articles.
- **Category CRUD**: 
    - Create new topics/categories directly from the home screen.
- **Post CRUD**: 
    - Create, Edit, and Delete posts.
    - Support for image attachments.
- **Comments**:
    - Real-time commenting system on post details.

### Multimedia (Firebase Storage)
- Persistent image storage for post attachments and user avatars.

## ⚙️ Project Setup

### 1. Firebase Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project named `hz-forum-flutter`.
2. **Enable Authentication**: In the "Authentication" section, enable the **Email/Password** provider.
3. **Enable Firestore**: Create a database named **`hz-flutter-forum`** (not the default name). 
   - *Note: If you use the default name, you may need to update the `databaseId` in the service files.*
4. **Enable Storage**: Initialize Firebase Storage to store images.
5. **Rules**: Set Firestore and Storage rules to allow read/write access for authenticated users.

### 2. Configure Platform Files
You need to add the Firebase configuration files:
- **Android**: Place `google-services.json` in `android/app/`.
- **iOS**: Place `GoogleService-Info.plist` in `ios/Runner/`.
- **Web/Windows**: The project is pre-configured with `lib/core/firebase_options.dart`.

### 3. Installation
1. Clone the repository.
2. Navigate to the project directory:
   ```bash
   cd untitled2
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```

## 🏃 How to Run

### Web (Recommended for this setup)
```bash
flutter run -d chrome
```

### Android
```bash
flutter run -d <your_device_id>
```

### Windows
1. Ensure "Developer Mode" is **ON**.
2. Run:
   ```bash
   flutter run -d windows
   ```

## 🛠️ Technologies Used
- **Flutter**: UI Framework.
- **Firebase**: Backend (Auth, Firestore, Storage).
- **Provider**: State management.
- **VelocityX**: Rapid UI development and enhancement.
- **Image Picker**: Handle gallery images.

## 📂 Project Structure
- `lib/core`: Firebase initialization and options.
- `lib/models`: Data models (User, Post, Category, Comment).
- `lib/services`: Firebase interaction logic.
- `lib/providers`: State management for UI updates.
- `lib/views`: Organize screens (Auth, Home, Profile).
- `lib/widgets`: Shared components like `AppImage`.

## 📝 License
MIT License.
