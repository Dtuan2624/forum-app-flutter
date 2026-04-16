# Flutter Forum App

A fully functional cross-platform forum application built with Flutter. This app supports Web, Mobile (Android/iOS), and Desktop platforms, using **Hive** for persistent local storage.

## 🚀 Features

### User Authentication
- **Register**: Create a new account with email and password.
- **Login**: Secure access to the forum.
- **Logout**: Session management.
- **Profile Management**: View and edit user profile (name and avatar).

### Forum Functionality
- **Home Screen**: 
    - Left panel showing a list of categories.
    - Right panel showing the 4 latest posts across all categories.
- **Categories**: 
    - Full CRUD for categories (via `CategoryService`).
    - Navigate to specific category pages to see related posts.
- **Posts**: 
    - Full CRUD for posts.
    - Image upload support (persistent across sessions).
    - Post detail view with full-size image support and interactive zoom.
- **Comments**:
    - Add and delete comments on individual posts.
    - Owner-based deletion logic.

## 🛠️ Technologies Used
- **Flutter**: Cross-platform framework.
- **Provider**: State management.
- **Hive**: Lightweight and blazing fast key-value database for local persistence (Web compatible).
- **Image Picker**: For picking user avatars and post images.
- **Path Provider**: For permanent local file storage on mobile.

## 📦 Getting Started

### Prerequisites
- Flutter SDK installed.
- A code editor (VS Code or Android Studio).

### Installation
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Launch the app:
   - **Web**: `flutter run -d chrome`
   - **Mobile**: `flutter run`

## 📂 Project Structure
- `lib/models`: Data models for User, Post, Category, and Comment.
- `lib/services`: Logic for API/Database interactions (Auth, Post, Category, Comment, Upload).
- `lib/providers`: State management using Provider.
- `lib/views`: UI screens organized by feature (Auth, Home, Profile).
- `lib/widgets`: Reusable UI components like `AppImage`.

## 📝 License
This project is open-source and available under the MIT License.
