# Member Staff Module - Compliance Verification

This document outlines the implementation of compliance verification for the Member Staff module within the OneApp Auth Framework.

## Overview

The Member Staff module functions as an embedded micro-app within OneApp and leverages OneSSO auth tokens to:

1. Identify the current logged-in member
2. Link any added/verified member staff to that member's unit
3. Maintain data consistency across shared onesociety and onegatekeeper databases

## Implementation Details

### 1. Auth Token Injection from OneApp

The Flutter module correctly receives and decodes the auth token (JWT) from OneApp:

- The token is stored securely using `flutter_secure_storage`
- The `AuthService` class handles token management and decoding
- The `jwt_decoder` library is used to extract member information:

```dart
// From lib/src/services/auth_service.dart
final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
final user = AuthUser(
  id: decodedToken['sub'] ?? '',
  name: decodedToken['name'] ?? '',
  email: decodedToken['email'] ?? '',
  role: decodedToken['role'] ?? 'user',
  token: token,
  memberId: decodedToken['member_id']?.toString(),
  unitId: decodedToken['unit_id']?.toString(),
  companyId: decodedToken['company_id']?.toString(),
  unitNumber: decodedToken['unit_number']?.toString(),
);
```

### 2. Member Identification in API Requests

All API requests related to staff creation, verification, and scheduling include member context:

- The `HttpHelper` class automatically adds auth headers and member context to all requests
- The `_enrichRequestBody` method ensures member_id, unit_id, and company_id are included in all requests:

```dart
// From lib/src/utils/http_helper.dart
Future<dynamic> _enrichRequestBody(dynamic body) async {
  // ...
  // Add member context if not already present
  if (!enrichedBody.containsKey('member_id')) {
    final memberId = await _authService.getMemberId();
    if (memberId != null) {
      enrichedBody['member_id'] = memberId;
    }
  }
  
  if (!enrichedBody.containsKey('unit_id')) {
    final unitId = await _authService.getUnitId();
    if (unitId != null) {
      enrichedBody['unit_id'] = unitId;
    }
  }
  
  if (!enrichedBody.containsKey('company_id')) {
    final companyId = await _authService.getCompanyId();
    if (companyId != null) {
      enrichedBody['company_id'] = companyId;
    }
  }
  // ...
}
```

### 3. Data Persistence with Auth Context

The backend (Laravel) saves the correct member ownership of the created/linked staff:

- The `Staff` model includes fields for member_id, unit_id, company_id, created_by, and updated_by
- The `StaffController::verifyIdentity` method ensures these fields are properly set:

```php
// From api/app/Http/Controllers/StaffController.php
$staff->update([
  'aadhaar_number' => $request->aadhaar_number,
  'residential_address' => $request->residential_address,
  'next_of_kin_name' => $request->next_of_kin_name,
  'next_of_kin_mobile' => $request->next_of_kin_mobile,
  'photo_url' => Storage::url($photoPath),
  'is_verified' => true,
  'verified_at' => now(),
  'verified_by_member_id' => $request->member_id,
  'unit_id' => $request->unit_id,
  'company_id' => $request->company_id,
]);
```

### 4. Server-Side Authorization

APIs reject unauthorized token holders trying to create/verify staff for other members:

- The `VerifyMemberContext` middleware validates that the authenticated user can only perform actions for their own member_id:

```php
// From api/app/Http/Middleware/VerifyMemberContext.php
// If the member_id in the request doesn't match the user's member_id, return forbidden
if ($requestMemberId !== $userMemberId) {
  return response()->json([
    'code' => 403,
    'message' => 'Forbidden: Cannot perform actions for other members',
  ], 403);
}
```

- This middleware is applied to all sensitive routes in `api/routes/api.php`

### 5. UI Verification Screen

The UI displays logged-in member info for clarity and debugging:

- The `LoggedInMemberInfo` widget shows the member name and unit number:

```dart
// From lib/src/widgets/logged_in_member_info.dart
Text(
  'Logged in as: ${user.name}',
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
  ),
),
if (user.unitNumber != null)
  Text(
    'Flat-${user.unitNumber}',
    style: TextStyle(
      fontSize: 11,
      color: Colors.grey[600],
    ),
  ),
```

- This widget is included in all verification flow screens

## Test Checklist

| Test Case | Expected | Status |
|-----------|----------|--------|
| Member staff added from OneApp → Staff record links to correct member_id and unit_id | ✅ | Implemented |
| Auth token auto-injected on app startup | ✅ | Implemented |
| Token used for send-otp, verify-otp, create staff, update schedule | ✅ | Implemented |
| Backend logs created_by and verified_by_member_id correctly | ✅ | Implemented |
| Attempt to spoof other member_id is rejected | ✅ | Implemented |
| Schedule created for authenticated member's staff only | ✅ | Implemented |

## Security Considerations

1. **Token Validation**: The system validates JWT tokens on both client and server sides
2. **Authorization Checks**: Middleware ensures users can only access their own data
3. **Secure Storage**: Auth tokens are stored using secure storage on the device
4. **Audit Logging**: All verification actions are logged with member context for audit purposes
5. **Input Validation**: All inputs are validated on both client and server sides

## Conclusion

The Member Staff module has been properly integrated with the OneApp Auth Framework, ensuring that all actions are performed in the context of the authenticated member and maintaining data consistency across the system.
