# Flutter Integration Guide for Mock Environment

This guide explains how to integrate your Flutter app with the mock environment for the Member Staff module.

## Prerequisites

- Flutter SDK installed
- Mock environment set up and running
- JWT token generated from the mock environment

## Configuration

### 1. Update API Base URL

In your Flutter app, update the API base URL to point to the mock environment:

```dart
// lib/src/core/network/api_client.dart
class ApiClient {
  // For local development
  static const String baseUrl = 'http://localhost:8000/api';

  // For Docker setup
  // static const String baseUrl = 'http://192.168.1.X:8000/api';

  // For production (when ready)
  // static const String baseUrl = 'https://api.oneapp.example.com/api';

  // Rest of the class...
}
```

### 2. Set Up JWT Token

You need to set the JWT token in your app. You can do this in several ways:

#### Option 1: Hardcode for Development

For quick development, you can temporarily hardcode the token:

```dart
// lib/src/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For development only - remove before production
  const devToken = 'your_jwt_token_here';
  await TokenManager.saveAuthToken(devToken);

  runApp(const MyApp());
}
```

#### Option 2: Login Screen

Create a simple login screen that calls the test token API:

```dart
Future<void> _login() async {
  final response = await http.post(
    Uri.parse('http://localhost:8000/api/auth/generate-test-token'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'member_id': 'member_id_here',
      'unit_id': 'unit_id_here',
      'company_id': 'company_id_here',
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final token = data['access_token'];
    await TokenManager.saveAuthToken(token);

    // Navigate to the main app
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else {
    // Handle error
  }
}
```

#### Option 3: Deep Link from Parent App

Simulate the parent app passing the token via deep link:

```dart
// In your main.dart
void main() {
  // Initialize deep link handling
  initUniLinks();
  runApp(const MyApp());
}

Future<void> initUniLinks() async {
  // Handle deep link when app is already running
  getLinksStream().listen((String? link) {
    if (link != null) {
      handleDeepLink(link);
    }
  }, onError: (err) {
    // Handle error
  });

  // Handle deep link when app is started from deep link
  try {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      handleDeepLink(initialLink);
    }
  } catch (e) {
    // Handle error
  }
}

void handleDeepLink(String link) {
  // Parse the link to extract the token
  final uri = Uri.parse(link);
  final token = uri.queryParameters['token'];

  if (token != null) {
    TokenManager.saveAuthToken(token);
  }
}
```

## Making API Requests

### Using the ApiClient

The `ApiClient` class should handle adding the JWT token to all requests:

```dart
Future<Map<String, String>> _getHeaders() async {
  final authHeaders = await TokenManager.getAuthHeader();

  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...authHeaders,
  };
}
```

### Example API Calls

#### Check if Staff Exists

```dart
Future<Map<String, dynamic>> checkStaffMobile(String mobile) async {
  try {
    return await _apiClient.get('staff/check', queryParams: {'mobile': mobile});
  } catch (e) {
    throw ApiException(message: 'Failed to check staff mobile: $e');
  }
}
```

#### Send OTP

```dart
Future<bool> sendOtp(String mobile) async {
  try {
    final response = await _apiClient.post(
      'staff/send-otp',
      body: {'mobile': mobile},
    );

    return response['success'] ?? false;
  } catch (e) {
    throw ApiException(message: 'Failed to send OTP: $e');
  }
}
```

#### Verify OTP

```dart
Future<bool> verifyOtp(String mobile, String otp) async {
  try {
    final response = await _apiClient.post(
      'staff/verify-otp',
      body: {
        'mobile': mobile,
        'otp': otp,
      },
    );

    return response['success'] ?? false;
  } catch (e) {
    throw ApiException(message: 'Failed to verify OTP: $e');
  }
}
```

#### Verify Staff Identity

```dart
Future<bool> verifyStaffIdentity(String staffId, Map<String, dynamic> identityData, File photoFile) async {
  try {
    // Convert image to base64
    final bytes = await photoFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final data = {
      ...identityData,
      'photo_base64': base64Image,
    };

    final response = await _apiClient.put(
      'staff/$staffId/verify',
      body: data,
    );

    return response['success'] ?? false;
  } catch (e) {
    throw ApiException(message: 'Failed to verify staff identity: $e');
  }
}
```

## Testing with Mock Data

### Test Scenarios

The mock environment includes several test scenarios based on the imported SQL data. Here's how to test them in your Flutter app:

#### Unverified Existing Staff

```dart
final mobile = '917411122233';
final result = await staffApi.checkStaffMobile(mobile);
// result['exists'] should be true
// result['verified'] should be false
```

#### Already Verified Staff

```dart
final mobile = '917422233344';
final result = await staffApi.checkStaffMobile(mobile);
// result['exists'] should be true
// result['verified'] should be true
```

#### New Staff

```dart
final mobile = '917433344455';
final result = await staffApi.checkStaffMobile(mobile);
// result['exists'] should be false
```

#### Staff with Pending OTP

```dart
final mobile = '917444455566';
final result = await staffApi.checkStaffMobile(mobile);
// result['exists'] should be true
// result['verified'] should be false

// Test resending OTP
final success = await staffApi.sendOtp(mobile);
// success should be true
```

#### Staff with Schedule Conflicts

```dart
final mobile = '917455566677';
final result = await staffApi.checkStaffMobile(mobile);
// result['exists'] should be true
// result['verified'] should be true

// Get staff ID from the result
final staffId = result['staff_id'];

// Get the staff schedule
final schedule = await staffApi.getStaffSchedule(staffId);
// schedule should contain time slots

// Try to add a conflicting time slot
final today = DateTime.now();
final conflictingSlot = TimeSlot(
  date: today,
  startTime: '09:30',
  endTime: '10:30',
  isBooked: true,
);

try {
  await staffApi.addTimeSlot(staffId, conflictingSlot);
  // Should throw an exception due to conflict
} catch (e) {
  print('Expected error: $e');
}
```

### OTP Verification

In the mock environment, all OTPs are set to `123456` for testing purposes:

```dart
final success = await staffApi.verifyOtp(mobile, '123456');
// success should be true
```

## Debugging Tips

### Inspecting JWT Token

To inspect the JWT token in your Flutter app:

```dart
final token = await TokenManager.getAuthToken();
final decodedToken = await TokenManager.getDecodedToken();
print('Token: $token');
print('Decoded Token: $decodedToken');
```

### Checking API Responses

To debug API responses:

```dart
try {
  final response = await _apiClient.get('staff/check', queryParams: {'mobile': mobile});
  print('API Response: $response');
  return response;
} catch (e) {
  print('API Error: $e');
  rethrow;
}
```

### Testing Member Context Validation

To test that the API correctly enforces member context validation:

1. Generate a token for one member
2. Try to perform an action for a different member
3. The API should return a 403 Forbidden error

```dart
// This should fail with a 403 error
try {
  await _apiClient.post(
    'member-staff/assign',
    body: {
      'member_id': 'different_member_id', // Different from the token
      'staff_id': 'staff_id_here',
    },
  );
} catch (e) {
  print('Expected error: $e');
}
```

## Conclusion

By following this guide, you should be able to integrate your Flutter app with the mock environment and test all the functionality of the Member Staff module before connecting to the production API.

Remember to remove any development-specific code (like hardcoded tokens) before deploying to production.
