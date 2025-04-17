# Member Staff Flutter Application

A Flutter application for managing members and staff information efficiently.

## Overview
This application provides functionality to manage members and staff information, including:
- Member registration and management
- Staff registration and management
- User authentication and authorization
- Reporting and analytics

## Project Structure

```
member_staff_app/
├── lib/
│   ├── main.dart                 # Entry point of the application
│   └── src/
│       ├── app.dart              # Main application widget
│       ├── models/               # Data models
│       │   ├── member.dart
│       │   └── staff.dart
│       ├── screens/              # UI screens
│       │   └── home_screen.dart
│       ├── services/             # API and other services
│       │   └── api_service.dart
│       ├── utils/                # Utility functions and constants
│       └── widgets/              # Reusable widgets
├── test/                         # Unit and widget tests
├── pubspec.yaml                  # Dependencies and app metadata
└── analysis_options.yaml         # Linting rules
```

## Features

- **Member Management**: Add, edit, view, and delete member information
- **Staff Management**: Add, edit, view, and delete staff information
- **Authentication**: Secure login and role-based access control
- **Reporting**: Generate reports on member and staff data

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- An IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository
   ```
   git clone https://github.com/rabinderFuturescape/Member_Staff_Flutter.git
   ```

2. Navigate to the project directory
   ```
   cd Member_Staff_Flutter
   ```

3. Install dependencies
   ```
   flutter pub get
   ```

4. Run the app
   ```
   flutter run
   ```

## Development

This project follows clean architecture principles and is organized into layers:

- **Presentation Layer**: UI components (screens, widgets)
- **Domain Layer**: Business logic and models
- **Data Layer**: API services and repositories

## Testing

Run tests with:
```
flutter test
```
