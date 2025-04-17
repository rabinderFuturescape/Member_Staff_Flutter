# Member Staff Module - Integration Guide

This guide provides detailed instructions for integrating the Member Staff module into the parent OneApp application.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Integration Steps](#integration-steps)
5. [Authentication Integration](#authentication-integration)
6. [API Integration](#api-integration)
7. [UI Integration](#ui-integration)
8. [Testing the Integration](#testing-the-integration)
9. [Troubleshooting](#troubleshooting)
10. [Appendix](#appendix)

## Overview

The Member Staff module is designed to be embedded within the OneApp as a micro-app. It provides functionality for:

- Staff verification (mobile verification, OTP, identity capture)
- Staff schedule management
- Member-staff assignments

This module is built with Flutter and connects to a Laravel API backend. It leverages the parent OneApp's authentication system and ensures that all API requests include the necessary member context information.

## Prerequisites

Before integrating the Member Staff module, ensure you have:

1. OneApp version 2.0 or higher
2. Flutter SDK 3.0 or higher
3. Access to the Member Staff module repository
4. Access to the Member Staff API backend
5. Authentication tokens from the parent OneApp

## Architecture

The Member Staff module follows a modular architecture that allows it to be embedded within the parent OneApp:

```
OneApp (Parent Application)
├── Authentication System
├── Navigation System
├── Core Services
└── Modules
    ├── Member Staff Module
    │   ├── API Client
    │   ├── Models
    │   ├── Screens
    │   ├── Widgets
    │   └── Services
    └── Other Modules
```

### Key Components

- **TokenManager**: Handles JWT token management and decoding
- **ApiClient**: Makes API requests with authentication and member context
- **MemberStaffModule**: Main entry point for the module
- **MemberStaffProvider**: Manages state for the module

## Integration Steps

### 1. Add the Module to Your Project

#### Option A: Using Git Submodule

```bash
# Add the Member Staff module as a submodule
git submodule add https://github.com/your-org/member-staff-flutter.git lib/modules/member_staff

# Update the submodule
git submodule update --init --recursive
```

#### Option B: Using Package Dependency

Add the Member Staff module to your `pubspec.yaml`:

```yaml
dependencies:
  member_staff:
    git:
      url: https://github.com/your-org/member-staff-flutter.git
      ref: main  # or specific tag/commit
```

Then run:

```bash
flutter pub get
```

### 2. Update Dependencies

Ensure your app has all the required dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  http: ^0.13.5
  flutter_secure_storage: ^8.0.0
  jwt_decoder: ^2.0.1
  image_picker: ^0.8.7
  intl: ^0.18.0
  # Add other dependencies as needed
```

### 3. Configure API Endpoint

Create a configuration file at `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://api.oneapp.example.com/api';
  static const String memberStaffApiUrl = '$baseUrl/member-staff';
}
```

### 4. Register the Module

In your app's main file, register the Member Staff module:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:member_staff/src/features/member_staff/member_staff_module.dart';
import 'package:member_staff/src/core/network/api_client.dart';
import 'package:member_staff/src/features/member_staff/providers/member_staff_provider.dart';
import 'package:member_staff/src/features/member_staff/api/member_staff_api.dart';
import 'config/api_config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Your existing providers
        
        // Member Staff module providers
        Provider<ApiClient>(
          create: (_) => ApiClient(baseUrl: ApiConfig.memberStaffApiUrl),
        ),
        Provider<MemberStaffApi>(
          create: (context) => MemberStaffApi(
            apiClient: Provider.of<ApiClient>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<MemberStaffProvider>(
          create: (context) => MemberStaffProvider(
            api: Provider.of<MemberStaffApi>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        // Your app configuration
        home: HomeScreen(),
      ),
    );
  }
}
```

## Authentication Integration

The Member Staff module relies on the parent OneApp's authentication system. You need to pass the authentication token to the module.

### 1. Pass Authentication Token

When navigating to the Member Staff module, pass the authentication token:

```dart
import 'package:member_staff/src/core/auth/token_manager.dart';
import 'package:member_staff/src/features/member_staff/member_staff_module.dart';

Future<void> navigateToMemberStaffModule(BuildContext context) async {
  // Get the authentication token from your app
  final String authToken = await yourAuthService.getToken();
  
  // Save the token to the Member Staff module's TokenManager
  await TokenManager.saveAuthToken(authToken);
  
  // Navigate to the Member Staff module
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MemberStaffModule(
        baseUrl: ApiConfig.memberStaffApiUrl,
      ),
    ),
  );
}
```

### 2. Handle Token Refresh

Implement token refresh logic to ensure the Member Staff module always has a valid token:

```dart
// In your app's authentication service
Future<void> refreshToken() async {
  // Your token refresh logic
  final String newToken = await yourAuthService.refreshToken();
  
  // Update the token in the Member Staff module
  await TokenManager.saveAuthToken(newToken);
}
```

## API Integration

The Member Staff module communicates with its own API backend. You need to ensure this API is properly deployed and accessible.

### 1. API Configuration

Configure your API gateway or proxy to route requests to the Member Staff API:

```
/api/member-staff/* -> Member Staff API
```

### 2. API Authentication

Ensure your API gateway forwards authentication headers to the Member Staff API.

### 3. CORS Configuration

Configure CORS on the Member Staff API to allow requests from your OneApp domains:

```php
// In Laravel's cors.php config
return [
    'paths' => ['api/*'],
    'allowed_origins' => ['https://oneapp.example.com'],
    'allowed_methods' => ['*'],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

## UI Integration

### 1. Navigation

Add a navigation item to access the Member Staff module:

```dart
ListTile(
  leading: Icon(Icons.people),
  title: Text('Member Staff'),
  onTap: () => navigateToMemberStaffModule(context),
),
```

### 2. Theme Integration

To ensure the Member Staff module matches your app's theme, provide a theme when navigating:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Theme(
      data: Theme.of(context),
      child: const MemberStaffModule(
        baseUrl: ApiConfig.memberStaffApiUrl,
      ),
    ),
  ),
);
```

### 3. Deep Linking

Set up deep linking to the Member Staff module:

```dart
// In your app's route handling
if (route.startsWith('/member-staff')) {
  // Extract any parameters if needed
  final params = extractParams(route);
  
  // Navigate to the Member Staff module
  navigateToMemberStaffModule(context, params);
  return true;
}
```

## Testing the Integration

### 1. Authentication Testing

Test that authentication tokens are correctly passed to the Member Staff module:

```dart
// Test code
test('Authentication token is passed correctly', () async {
  final authToken = 'test_token';
  await TokenManager.saveAuthToken(authToken);
  final retrievedToken = await TokenManager.getAuthToken();
  expect(retrievedToken, equals(authToken));
});
```

### 2. API Testing

Test that API requests include the correct authentication and member context:

```dart
// Test code
test('API requests include authentication and member context', () async {
  final apiClient = ApiClient(baseUrl: 'https://api.example.com');
  final request = await apiClient.prepareRequest('GET', 'endpoint');
  
  expect(request.headers['Authorization'], startsWith('Bearer '));
  
  final body = jsonDecode(request.body);
  expect(body, contains('member_id'));
  expect(body, contains('unit_id'));
  expect(body, contains('company_id'));
});
```

### 3. UI Testing

Test that the Member Staff module UI is correctly displayed within your app:

```dart
// Test code
testWidgets('Member Staff module UI is displayed', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MemberStaffModule(baseUrl: 'https://api.example.com'),
    ),
  );
  
  expect(find.text('Verify Staff Member'), findsOneWidget);
});
```

## Troubleshooting

### Common Issues

#### 1. Authentication Errors

**Symptom**: API requests return 401 Unauthorized errors.

**Solution**:
- Verify that the authentication token is correctly passed to the Member Staff module
- Check that the token is valid and not expired
- Ensure the token includes the required member context

#### 2. API Connection Issues

**Symptom**: API requests fail with connection errors.

**Solution**:
- Verify that the API endpoint is correctly configured
- Check network connectivity
- Ensure the API server is running and accessible

#### 3. UI Rendering Issues

**Symptom**: UI elements are not displayed correctly or are misaligned.

**Solution**:
- Verify that the theme is correctly passed to the Member Staff module
- Check for any conflicting styles or themes
- Ensure the parent app and the Member Staff module use compatible Flutter versions

### Logging

Enable detailed logging to troubleshoot integration issues:

```dart
// In your app's main.dart
void main() {
  // Enable detailed logging
  Logging.enableDetailedLogs = true;
  
  runApp(MyApp());
}
```

## Appendix

### A. Module Structure

```
lib/
├── src/
│   ├── core/
│   │   ├── auth/
│   │   │   └── token_manager.dart
│   │   ├── network/
│   │   │   └── api_client.dart
│   │   └── exceptions/
│   │       └── api_exception.dart
│   └── features/
│       └── member_staff/
│           ├── api/
│           │   └── member_staff_api.dart
│           ├── models/
│           │   ├── staff.dart
│           │   ├── time_slot.dart
│           │   └── schedule.dart
│           ├── providers/
│           │   └── member_staff_provider.dart
│           ├── screens/
│           │   └── verification_flow/
│           │       ├── mobile_verification_screen.dart
│           │       ├── otp_verification_screen.dart
│           │       ├── identity_form_screen.dart
│           │       └── verification_success_screen.dart
│           ├── widgets/
│           │   └── logged_in_member_info.dart
│           └── member_staff_module.dart
```

### B. API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| /api/staff/check | GET | Check if staff exists |
| /api/staff/send-otp | POST | Send OTP to mobile |
| /api/staff/verify-otp | POST | Verify OTP |
| /api/staff/{id}/verify | PUT | Verify staff identity |
| /api/staff/{staffId}/schedule | GET | Get staff schedule |
| /api/staff/{staffId}/schedule | PUT | Update staff schedule |
| /api/staff/{staffId}/schedule/slots | POST | Add time slot |
| /api/staff/{staffId}/schedule/slots | PUT | Update time slot |
| /api/staff/{staffId}/schedule/slots | DELETE | Remove time slot |
| /api/members/{memberId}/staff | GET | Get member staff |
| /api/member-staff/assign | POST | Assign staff to member |
| /api/member-staff/unassign | POST | Unassign staff from member |

### C. Required Permissions

The Member Staff module requires the following permissions:

- Camera access (for taking staff photos)
- Internet access (for API communication)
- Secure storage access (for token storage)

### D. Version Compatibility

| Component | Minimum Version | Recommended Version |
|-----------|-----------------|---------------------|
| Flutter | 2.10.0 | 3.10.0 or higher |
| Dart | 2.16.0 | 3.0.0 or higher |
| OneApp | 2.0.0 | 2.5.0 or higher |
| Android | API 21 (Android 5.0) | API 33 (Android 13) |
| iOS | iOS 11.0 | iOS 16.0 or higher |
