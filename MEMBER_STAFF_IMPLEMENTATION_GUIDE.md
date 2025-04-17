# Member Staff Module Implementation Guide

This guide provides an overview of the Member Staff module implementation, focusing on authentication, context injection, and API integration.

## Overview

The Member Staff module is designed to be embedded within the OneApp as a micro-app. It leverages the parent app's authentication system and ensures that all API requests include the necessary member context information.

## Key Components

### 1. Authentication & Token Management

The `TokenManager` class (`lib/src/core/auth/token_manager.dart`) handles all authentication-related functionality:

- Securely stores and retrieves the JWT token from the parent app
- Decodes the token to extract member information (member_id, unit_id, company_id)
- Provides methods to check token validity and get auth headers

```dart
// Example usage
final token = await TokenManager.getAuthToken();
final memberId = await TokenManager.getMemberId();
final headers = await TokenManager.getAuthHeader();
```

### 2. API Client with Context Injection

The `ApiClient` class (`lib/src/core/network/api_client.dart`) handles all HTTP requests with automatic context injection:

- Adds authentication headers to all requests
- Automatically injects member context (member_id, unit_id, company_id) into request bodies
- Handles API responses and error parsing

```dart
// Example usage
final apiClient = ApiClient(baseUrl: 'https://api.example.com');
final response = await apiClient.post(
  'staff/verify',
  body: {'name': 'John Doe'},  // member_id, unit_id, company_id are auto-injected
);
```

### 3. Member Staff API

The `MemberStaffApi` class (`lib/src/features/member_staff/api/member_staff_api.dart`) provides specific methods for the Member Staff module:

- Uses the ApiClient for all requests, ensuring auth and context injection
- Implements all required endpoints (verification, scheduling, etc.)
- Handles data conversion between API and model objects

```dart
// Example usage
final memberStaffApi = MemberStaffApi(apiClient: apiClient);
final success = await memberStaffApi.verifyOtp('9123456789', '123456');
```

## Implementation Details

### Authentication Flow

1. The parent OneApp injects the JWT token into the Member Staff module
2. The `AuthWrapper` in `main.dart` checks if the token is valid
3. If valid, the Member Staff module is initialized
4. All API requests automatically include the token and member context

### Member Context Injection

The `_enrichRequestBody` method in `ApiClient` automatically adds member context to all requests:

```dart
Future<Map<String, dynamic>> _enrichRequestBody(Map<String, dynamic> body) async {
  final memberContext = await TokenManager.getMemberContext();
  
  // Only add context fields that aren't already in the body
  memberContext.forEach((key, value) {
    if (!body.containsKey(key)) {
      body[key] = value;
    }
  });
  
  return body;
}
```

### Verification Flow

The verification flow consists of three main screens:

1. `MobileVerificationScreen`: Collects the staff's mobile number and sends OTP
2. `OtpVerificationScreen`: Verifies the OTP
3. `IdentityFormScreen`: Collects identity information (Aadhaar, address, etc.)

Each screen displays the logged-in member's information using the `LoggedInMemberInfo` widget.

## Integration Checklist

- [x] Token is retrieved from secure storage
- [x] Token is decoded client-side to extract member context
- [x] API calls include member_id, unit_id, company_id
- [x] All requests carry bearer token
- [x] Server can trust context from OneSSO

## Usage Example

To use the Member Staff module in your OneApp:

```dart
import 'package:member_staff/src/features/member_staff/member_staff_module.dart';

// In your OneApp code
void navigateToMemberStaffModule() {
  // First, ensure the token is saved
  final token = getTokenFromOneApp();
  await TokenManager.saveAuthToken(token);
  
  // Then navigate to the Member Staff module
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MemberStaffModule(
        baseUrl: 'https://api.oneapp.example.com/api',
      ),
    ),
  );
}
```

## Server-Side Requirements

The server must:

1. Validate the JWT token from the Authorization header
2. Verify that the member_id in the request matches the one in the token
3. Use the verified member context for all operations
4. Implement the middleware for authorization checks

## Conclusion

This implementation ensures that:

- 🔐 Auth token is properly decoded
- 🧾 Member context is injected into all API requests
- 🔄 Context is auto-injected into staff registration, OTP, and schedule APIs
- 🛡️ Server-side authorization is properly enforced
