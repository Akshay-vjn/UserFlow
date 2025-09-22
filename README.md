# UserFlow

A modern Flutter application with Google Sign-In authentication, user management, and real-time features.

## Features

- 🔐 **Google Sign-In Authentication** - Secure login with Google accounts
- 👥 **User Management** - Create, read, update, and delete user profiles
- 🌐 **API Integration** - RESTful API communication with ReqRes API
- 📱 **Responsive Design** - Works on both Android and iOS
- 🔄 **State Management** - Built with Riverpod for efficient state handling
- 💾 **Local Storage** - SQLite database for offline data persistence
- 🔔 **Push Notifications** - Firebase Cloud Messaging integration
- 🌍 **Internationalization** - Multi-language support (English & Hindi)

## Tech Stack

- **Framework**: Flutter 3.9.0+
- **State Management**: Riverpod
- **Authentication**: Firebase Auth + Google Sign-In
- **Database**: SQLite (sqflite)
- **API**: HTTP client with ReqRes API
- **Notifications**: Firebase Cloud Messaging
- **Routing**: GoRouter

## Prerequisites

- Flutter SDK 3.9.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Firebase project setup
- Google Cloud Console project

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/userflow.git
cd userflow
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication and Google Sign-In
3. Download `google-services.json` for Android
4. Place it in `android/app/` directory

### 4. Environment Variables

1. Copy `.env.example` to `.env`
2. Update the Google Server Client ID:

```env
GOOGLE_SERVER_CLIENT_ID=your_google_server_client_id_here.apps.googleusercontent.com
```

### 5. Run the Application

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Project Structure

```
lib/
├── core/                 # Core utilities and services
│   ├── database/        # Database helper and models
│   ├── network/         # API client and network utilities
│   ├── services/        # Notification and other services
│   └── widgets/         # Reusable widgets
├── features/            # Feature-based modules
│   ├── auth/           # Authentication feature
│   ├── profile/        # User profile feature
│   └── user/           # User management feature
├── l10n/               # Internationalization files
├── app.dart            # Main app configuration
└── main.dart           # Application entry point
```

## API Integration

This app integrates with the [ReqRes API](https://reqres.in/) for user management operations:

- GET `/users` - Fetch users list
- GET `/users/{id}` - Get specific user
- POST `/users` - Create new user
- PUT `/users/{id}` - Update user
- DELETE `/users/{id}` - Delete user

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please:

1. Check the [Issues](https://github.com/yourusername/userflow/issues) page
2. Create a new issue with detailed information
3. Contact the maintainers

## Acknowledgments

- [Flutter](https://flutter.dev/) for the amazing framework
- [Firebase](https://firebase.google.com/) for backend services
- [ReqRes API](https://reqres.in/) for the mock API
