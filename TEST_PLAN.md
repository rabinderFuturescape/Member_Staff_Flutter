# Member Staff Module - Test Plan

## Overview

This test plan outlines the approach for testing the Member Staff module, which includes the Laravel API, Flutter integration, and mock data environment. The plan covers all aspects of the module, from API endpoints to user flows and edge cases.

## Test Environment Setup

### Backend Setup

1. **Database Setup**
   - Create a test database
   - Import the mock data from `mock_member_staff_seed.sql`
   - Verify tables are created correctly

2. **API Setup**
   - Configure Laravel environment for testing
   - Generate JWT secret key
   - Start the development server

3. **Test User Setup**
   - Generate test tokens with different member contexts
   - Prepare test data for various scenarios

### Frontend Setup

1. **Flutter Environment**
   - Set up Flutter development environment
   - Configure API client to use test API URL
   - Set up test JWT tokens

2. **Emulator/Simulator Setup**
   - Prepare Android emulator and iOS simulator
   - Install the app on test devices

## Test Categories

### 1. API Testing

#### Authentication and Authorization

- Test JWT token validation
- Test member context validation
- Test token expiration handling

#### Staff Endpoints

- Test staff lookup by mobile number
- Test staff creation
- Test staff update
- Test staff deletion

#### Verification Endpoints

- Test OTP sending
- Test OTP verification
- Test identity verification

#### Schedule Endpoints

- Test getting staff schedule
- Test updating staff schedule
- Test adding time slots
- Test updating time slots
- Test removing time slots
- Test conflict detection

#### Member-Staff Endpoints

- Test getting member staff
- Test assigning staff to member
- Test unassigning staff from member

### 2. Flutter Integration Testing

#### Token Management

- Test token storage and retrieval
- Test token decoding
- Test token expiration handling

#### API Client

- Test API request formatting
- Test auth header injection
- Test member context injection
- Test error handling

#### UI Components

- Test mobile verification screen
- Test OTP verification screen
- Test identity form screen
- Test verification success screen
- Test schedule management screen

#### State Management

- Test provider state updates
- Test UI reactivity to state changes
- Test error state handling

### 3. User Flow Testing

#### Staff Verification Flow

- Test unverified existing staff flow
- Test already verified staff flow
- Test new staff flow
- Test staff with pending OTP flow

#### Schedule Management Flow

- Test viewing staff schedule
- Test adding time slots
- Test updating time slots
- Test removing time slots
- Test handling schedule conflicts

#### Member-Staff Assignment Flow

- Test viewing member staff
- Test assigning staff to member
- Test unassigning staff from member

### 4. Edge Case Testing

- Test invalid mobile number formats
- Test expired OTPs
- Test network errors
- Test invalid tokens
- Test concurrent requests

### 5. Performance Testing

- Test API response times
- Test UI rendering performance
- Test memory usage

### 6. Security Testing

- Test JWT implementation security
- Test data encryption
- Test authorization checks
- Test for SQL injection vulnerabilities

### 7. Compatibility Testing

- Test on different browsers
- Test on different mobile devices
- Test on different screen sizes

## Test Scenarios

### Scenario 1: Unverified Existing Staff

1. Enter mobile number 917411122233
2. System should recognize the staff exists but is not verified
3. Send OTP
4. Verify OTP (use 123456 for testing)
5. Complete identity verification form
6. Staff should be marked as verified and linked to the member

### Scenario 2: Already Verified Staff

1. Enter mobile number 917422233344
2. System should recognize the staff is already verified
3. UI should show a message that the staff is already verified
4. Should not allow proceeding with verification

### Scenario 3: New Staff

1. Enter mobile number 917433344455
2. System should not find an existing staff
3. Create a new staff record
4. Send OTP
5. Verify OTP
6. Complete identity verification form
7. New staff record should be created, verified, and linked to the member

### Scenario 4: Staff with Pending OTP

1. Enter mobile number 917444455566
2. System should recognize the staff has a pending OTP
3. UI should show option to resend OTP or enter the existing one
4. Enter OTP 123456
5. OTP should be verified
6. Should proceed to identity verification form

### Scenario 5: Staff with Schedule Conflicts

1. Enter mobile number 917455566677 (or access an already verified staff)
2. Navigate to schedule management
3. Try to add a time slot that conflicts with existing slots
4. System should detect the conflict
5. UI should show a warning about the conflict
6. Should not allow creating conflicting time slots

## Test Data

The test data is provided in the `mock_member_staff_seed.sql` file, which includes:

- Members with their associated units
- Staff members with various verification statuses
- Staff schedules with time slots
- OTP records for testing verification flow

## Test Execution

### Manual Testing

1. Execute each test scenario manually
2. Record the results
3. Document any issues found

### Automated Testing

1. Write unit tests for API endpoints
2. Write widget tests for Flutter UI components
3. Write integration tests for user flows
4. Run automated tests and record results

## Test Reporting

The test report will include:

1. Executive summary
2. Test environment details
3. Test scenarios and results
4. Issues found and recommendations
5. Conclusion and next steps

## Test Schedule

1. **Day 1**: Environment setup and API testing
2. **Day 2**: Flutter integration testing
3. **Day 3**: User flow testing
4. **Day 4**: Edge case, performance, and security testing
5. **Day 5**: Compatibility testing and test reporting

## Roles and Responsibilities

- **Test Lead**: Oversee the testing process and coordinate team efforts
- **API Tester**: Test the Laravel API endpoints
- **Flutter Tester**: Test the Flutter integration
- **QA Engineer**: Test user flows and edge cases
- **Security Specialist**: Conduct security testing

## Exit Criteria

Testing will be considered complete when:

1. All test scenarios have been executed
2. All critical and high-priority issues have been resolved
3. Test coverage is at least 90%
4. All acceptance criteria have been met

## Approvals

- **Project Manager**: [Name]
- **Development Lead**: [Name]
- **QA Lead**: [Name]
- **Client Representative**: [Name]
