# Member Staff Module - Test Cases

This document contains detailed test cases for the Member Staff module.

## API Test Cases

### Authentication and Authorization

#### TC-AUTH-001: JWT Token Validation

**Description**: Verify that API endpoints require a valid JWT token.

**Steps**:
1. Make an API request without a token
2. Make an API request with an invalid token
3. Make an API request with an expired token
4. Make an API request with a valid token

**Expected Results**:
1. Request without token should be rejected with 401 status code
2. Request with invalid token should be rejected with 401 status code
3. Request with expired token should be rejected with 401 status code
4. Request with valid token should be accepted

#### TC-AUTH-002: Member Context Validation

**Description**: Verify that API enforces member context validation.

**Steps**:
1. Generate a token for member A
2. Try to perform an action for member B using member A's token

**Expected Results**:
1. Action for member B should be rejected with 403 status code

#### TC-AUTH-003: Token Decoding

**Description**: Verify that the Flutter app correctly decodes JWT tokens.

**Steps**:
1. Generate a token with member context
2. Decode the token in the Flutter app
3. Extract member_id, unit_id, and company_id

**Expected Results**:
1. Member context should be correctly extracted from the token

### Staff Verification Flow

#### TC-STAFF-001: Check Unverified Existing Staff

**Description**: Verify that the system correctly identifies unverified existing staff.

**Steps**:
1. Call the staff/check endpoint with mobile number 917411122233

**Expected Results**:
1. Response should indicate that staff exists (exists: true)
2. Response should indicate that staff is not verified (verified: false)

#### TC-STAFF-002: Check Already Verified Staff

**Description**: Verify that the system correctly identifies already verified staff.

**Steps**:
1. Call the staff/check endpoint with mobile number 917422233344

**Expected Results**:
1. Response should indicate that staff exists (exists: true)
2. Response should indicate that staff is verified (verified: true)

#### TC-STAFF-003: Check New Staff

**Description**: Verify that the system correctly identifies new staff.

**Steps**:
1. Call the staff/check endpoint with mobile number 917433344455

**Expected Results**:
1. Response should indicate that staff does not exist (exists: false)

#### TC-STAFF-004: Send OTP

**Description**: Verify that the system can send OTP to a mobile number.

**Steps**:
1. Call the staff/send-otp endpoint with mobile number 917411122233

**Expected Results**:
1. Response should indicate success (success: true)
2. OTP should be created in the database

#### TC-STAFF-005: Verify OTP

**Description**: Verify that the system can verify an OTP.

**Steps**:
1. Call the staff/verify-otp endpoint with mobile number 917411122233 and OTP 123456

**Expected Results**:
1. Response should indicate success (success: true)
2. OTP should be marked as verified in the database

#### TC-STAFF-006: Verify Staff Identity

**Description**: Verify that the system can verify a staff's identity.

**Steps**:
1. Call the staff/{id}/verify endpoint with staff ID and identity information

**Expected Results**:
1. Response should indicate success (success: true)
2. Staff should be marked as verified in the database
3. Staff should be linked to the member

### Schedule Management

#### TC-SCHED-001: Get Staff Schedule

**Description**: Verify that the system can retrieve a staff's schedule.

**Steps**:
1. Call the staff/{staffId}/schedule endpoint with staff ID 917455566677

**Expected Results**:
1. Response should include the staff's schedule with time slots

#### TC-SCHED-002: Add Time Slot

**Description**: Verify that the system can add a time slot to a staff's schedule.

**Steps**:
1. Call the staff/{staffId}/schedule/slots endpoint with staff ID and time slot information

**Expected Results**:
1. Response should indicate success
2. Time slot should be added to the database

#### TC-SCHED-003: Update Time Slot

**Description**: Verify that the system can update a time slot in a staff's schedule.

**Steps**:
1. Call the staff/{staffId}/schedule/slots endpoint with staff ID and updated time slot information

**Expected Results**:
1. Response should indicate success
2. Time slot should be updated in the database

#### TC-SCHED-004: Remove Time Slot

**Description**: Verify that the system can remove a time slot from a staff's schedule.

**Steps**:
1. Call the staff/{staffId}/schedule/slots endpoint with staff ID and time slot information to remove

**Expected Results**:
1. Response should indicate success
2. Time slot should be removed from the database

#### TC-SCHED-005: Detect Schedule Conflicts

**Description**: Verify that the system can detect schedule conflicts.

**Steps**:
1. Call the staff/{staffId}/schedule/slots endpoint with staff ID and a conflicting time slot

**Expected Results**:
1. Response should indicate a conflict
2. Time slot should not be added to the database

### Member-Staff Assignment

#### TC-ASSIGN-001: Get Member Staff

**Description**: Verify that the system can retrieve staff assigned to a member.

**Steps**:
1. Call the members/{memberId}/staff endpoint with member ID

**Expected Results**:
1. Response should include the list of staff assigned to the member

#### TC-ASSIGN-002: Assign Staff to Member

**Description**: Verify that the system can assign a staff to a member.

**Steps**:
1. Call the member-staff/assign endpoint with member ID and staff ID

**Expected Results**:
1. Response should indicate success
2. Assignment should be created in the database

#### TC-ASSIGN-003: Unassign Staff from Member

**Description**: Verify that the system can unassign a staff from a member.

**Steps**:
1. Call the member-staff/unassign endpoint with member ID and staff ID

**Expected Results**:
1. Response should indicate success
2. Assignment should be removed from the database

## Flutter Integration Test Cases

### Token Management

#### TC-TOKEN-001: Store and Retrieve Token

**Description**: Verify that the app can securely store and retrieve JWT tokens.

**Steps**:
1. Store a token using TokenManager.saveAuthToken()
2. Retrieve the token using TokenManager.getAuthToken()

**Expected Results**:
1. Token should be stored securely
2. Retrieved token should match the stored token

#### TC-TOKEN-002: Decode Token

**Description**: Verify that the app can decode JWT tokens.

**Steps**:
1. Store a token using TokenManager.saveAuthToken()
2. Decode the token using TokenManager.getDecodedToken()

**Expected Results**:
1. Decoded token should contain the expected claims

### API Client

#### TC-API-001: Make GET Request

**Description**: Verify that the API client can make GET requests with auth headers.

**Steps**:
1. Make a GET request using the API client

**Expected Results**:
1. Request should include Authorization header with Bearer token
2. Request should be successful

#### TC-API-002: Make POST Request with Member Context

**Description**: Verify that the API client can make POST requests with member context.

**Steps**:
1. Make a POST request using the API client

**Expected Results**:
1. Request should include Authorization header with Bearer token
2. Request body should include member_id, unit_id, and company_id
3. Request should be successful

### UI Components

#### TC-UI-001: Mobile Verification Screen

**Description**: Verify that the mobile verification screen works correctly.

**Steps**:
1. Navigate to the mobile verification screen
2. Enter a mobile number
3. Tap the Continue button

**Expected Results**:
1. Screen should display correctly
2. Mobile number should be validated
3. OTP should be sent
4. Navigation to OTP verification screen should occur

#### TC-UI-002: OTP Verification Screen

**Description**: Verify that the OTP verification screen works correctly.

**Steps**:
1. Navigate to the OTP verification screen
2. Enter an OTP
3. Tap the Verify OTP button

**Expected Results**:
1. Screen should display correctly
2. OTP should be validated
3. Navigation to identity form screen should occur

#### TC-UI-003: Identity Form Screen

**Description**: Verify that the identity form screen works correctly.

**Steps**:
1. Navigate to the identity form screen
2. Fill in the identity form
3. Take a photo
4. Tap the Verify Identity button

**Expected Results**:
1. Screen should display correctly
2. Form should be validated
3. Photo should be captured
4. Identity should be verified
5. Navigation to verification success screen should occur

#### TC-UI-004: Verification Success Screen

**Description**: Verify that the verification success screen works correctly.

**Steps**:
1. Navigate to the verification success screen
2. Tap the Go to Dashboard button

**Expected Results**:
1. Screen should display correctly
2. Navigation to dashboard should occur

## User Flow Test Cases

### Staff Verification Flow

#### TC-FLOW-001: Unverified Existing Staff Flow

**Description**: Verify the complete flow for an unverified existing staff.

**Steps**:
1. Enter mobile number 917411122233
2. Send OTP
3. Verify OTP
4. Complete identity form
5. Submit verification

**Expected Results**:
1. Staff should be marked as verified
2. Staff should be linked to the member
3. Success screen should be displayed

#### TC-FLOW-002: Already Verified Staff Flow

**Description**: Verify the flow for an already verified staff.

**Steps**:
1. Enter mobile number 917422233344

**Expected Results**:
1. System should indicate that staff is already verified
2. Should not proceed with verification

#### TC-FLOW-003: New Staff Flow

**Description**: Verify the complete flow for a new staff.

**Steps**:
1. Enter mobile number 917433344455
2. Send OTP
3. Verify OTP
4. Complete identity form
5. Submit verification

**Expected Results**:
1. New staff record should be created
2. Staff should be marked as verified
3. Staff should be linked to the member
4. Success screen should be displayed

#### TC-FLOW-004: Staff with Pending OTP Flow

**Description**: Verify the flow for a staff with a pending OTP.

**Steps**:
1. Enter mobile number 917444455566
2. System should indicate that an OTP is pending
3. Enter the OTP or request a new one
4. Complete identity form
5. Submit verification

**Expected Results**:
1. OTP should be verified
2. Staff should be marked as verified
3. Staff should be linked to the member
4. Success screen should be displayed

### Schedule Management Flow

#### TC-FLOW-005: Schedule Management Flow

**Description**: Verify the complete flow for managing a staff's schedule.

**Steps**:
1. Access a verified staff's schedule
2. Add a new time slot
3. Update an existing time slot
4. Remove a time slot
5. Try to add a conflicting time slot

**Expected Results**:
1. New time slot should be added
2. Existing time slot should be updated
3. Time slot should be removed
4. Conflict should be detected and prevented

## Edge Case Test Cases

#### TC-EDGE-001: Invalid Mobile Format

**Description**: Verify that the system handles invalid mobile number formats.

**Steps**:
1. Enter an invalid mobile number format

**Expected Results**:
1. System should validate the mobile number
2. Error message should be displayed

#### TC-EDGE-002: Expired OTP

**Description**: Verify that the system handles expired OTPs.

**Steps**:
1. Send an OTP
2. Wait for the OTP to expire
3. Try to verify the expired OTP

**Expected Results**:
1. System should reject the expired OTP
2. Error message should be displayed
3. Option to resend OTP should be provided

#### TC-EDGE-003: Network Error

**Description**: Verify that the system handles network errors.

**Steps**:
1. Simulate a network error during an API call

**Expected Results**:
1. System should handle the error gracefully
2. Error message should be displayed
3. Option to retry should be provided

#### TC-EDGE-004: Invalid Token

**Description**: Verify that the system handles invalid tokens.

**Steps**:
1. Use an invalid or expired JWT token

**Expected Results**:
1. System should reject the token
2. User should be prompted to log in again

## Performance Test Cases

#### TC-PERF-001: API Response Time

**Description**: Verify that API response times are acceptable.

**Steps**:
1. Measure response times for various API endpoints

**Expected Results**:
1. Response times should be under 500ms

#### TC-PERF-002: UI Rendering Performance

**Description**: Verify that UI rendering performance is acceptable.

**Steps**:
1. Measure UI rendering performance for various screens

**Expected Results**:
1. UI should render at 60fps
2. No jank or stuttering should be observed

#### TC-PERF-003: Memory Usage

**Description**: Verify that memory usage is acceptable.

**Steps**:
1. Monitor memory usage during app usage

**Expected Results**:
1. Memory usage should be stable
2. No memory leaks should be observed

## Security Test Cases

#### TC-SEC-001: JWT Security

**Description**: Verify that JWT implementation is secure.

**Steps**:
1. Analyze JWT implementation
2. Check token signing algorithm
3. Check token expiration
4. Check token validation

**Expected Results**:
1. JWT implementation should be secure
2. Tokens should be properly signed
3. Tokens should have appropriate expiration
4. Tokens should be properly validated

#### TC-SEC-002: Data Encryption

**Description**: Verify that sensitive data is encrypted.

**Steps**:
1. Analyze data storage
2. Check encryption of sensitive data

**Expected Results**:
1. Sensitive data should be encrypted
2. Encryption should be implemented correctly

#### TC-SEC-003: Authorization Checks

**Description**: Verify that all endpoints have proper authorization checks.

**Steps**:
1. Analyze API endpoints
2. Check authorization middleware

**Expected Results**:
1. All endpoints should have appropriate authorization checks
2. Unauthorized access should be prevented

#### TC-SEC-004: SQL Injection

**Description**: Verify that the system is protected against SQL injection.

**Steps**:
1. Attempt SQL injection attacks on API endpoints

**Expected Results**:
1. System should be protected against SQL injection
2. Attacks should be prevented
