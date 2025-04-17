# Test Scenarios for Member Staff Module

This document outlines the test scenarios available in the mock environment for the Member Staff Flutter module.

## Available Test Scenarios

| Test Case | Mobile | Verified | Expected UI | Description |
|-----------|--------|----------|-------------|-------------|
| Unverified Existing Staff | 917411122233 | false | Send OTP + Verify | Staff exists in the system but has not completed verification |
| Already Verified Staff | 917422233344 | true | Block duplicate | Staff is already verified and linked to a member |
| New Staff | 917433344455 | — | Create new record | Mobile number not in the system, should create a new staff record |
| Staff with Pending OTP | 917444455566 | false | Resend OTP | Staff has a pending OTP that hasn't expired yet |
| Staff with Schedule Conflicts | 917455566677 | true | Show conflicts | Staff has existing time slots that may conflict with new bookings |
| Society Staff | 917466677788 | true | N/A | Staff with society scope instead of member scope |

## How to Test Each Scenario

### 1. Unverified Existing Staff (917411122233)

**Steps:**
1. Enter mobile number 917411122233
2. System should recognize the staff exists but is not verified
3. Send OTP
4. Verify OTP (use 123456 for all OTPs in the mock environment)
5. Complete identity verification form

**Expected Result:**
- Staff should be marked as verified
- Staff should be linked to the member

### 2. Already Verified Staff (917422233344)

**Steps:**
1. Enter mobile number 917422233344
2. System should recognize the staff is already verified

**Expected Result:**
- UI should show a message that the staff is already verified
- Should not allow proceeding with verification

### 3. New Staff (917433344455)

**Steps:**
1. Enter mobile number 917433344455
2. System should not find an existing staff
3. Create a new staff record
4. Send OTP
5. Verify OTP
6. Complete identity verification form

**Expected Result:**
- New staff record should be created
- Staff should be marked as verified
- Staff should be linked to the member

### 4. Staff with Pending OTP (917444455566)

**Steps:**
1. Enter mobile number 917444455566
2. System should recognize the staff has a pending OTP
3. UI should show option to resend OTP or enter the existing one
4. Enter OTP 123456

**Expected Result:**
- OTP should be verified
- Should proceed to identity verification form

### 5. Staff with Schedule Conflicts (917455566677)

**Steps:**
1. Enter mobile number 917455566677 (or access an already verified staff)
2. Navigate to schedule management
3. Try to add a time slot that conflicts with existing slots

**Expected Result:**
- System should detect the conflict
- UI should show a warning about the conflict
- Should not allow creating conflicting time slots

### 6. Society Staff (917466677788)

**Steps:**
1. Enter mobile number 917466677788
2. System should recognize this is a society staff, not a member staff

**Expected Result:**
- UI should show appropriate message
- Should handle society staff differently from member staff

## Testing Authentication and Context

### Test JWT Token with Member Context

**Steps:**
1. Generate a test token with specific member context:
   ```bash
   php artisan generate:test-token --member-id=<member_id> --unit-id=<unit_id> --company-id=<company_id>
   ```
2. Use this token in your Flutter app
3. Make API requests that require member context

**Expected Result:**
- API should accept the token
- API should use the member context from the token
- API should enforce member context validation

### Test Invalid Member Context

**Steps:**
1. Generate a test token with one member ID
2. Try to perform actions for a different member ID

**Expected Result:**
- API should reject the request with a 403 Forbidden error
- Error message should indicate that you cannot perform actions for other members

## Testing Error Scenarios

### Test Invalid OTP

**Steps:**
1. Enter a valid mobile number
2. Request OTP
3. Enter an incorrect OTP

**Expected Result:**
- System should reject the invalid OTP
- UI should show an error message
- Should allow retrying

### Test Expired OTP

**Steps:**
1. Enter a valid mobile number
2. Request OTP
3. Wait for the OTP to expire (in the mock environment, you can manually update the expires_at field in the database)
4. Try to verify the expired OTP

**Expected Result:**
- System should reject the expired OTP
- UI should show an error message
- Should offer to resend a new OTP

### Test Invalid Mobile Number

**Steps:**
1. Enter an invalid mobile number format
2. Try to proceed

**Expected Result:**
- UI should validate the mobile number format
- Should show an error message
- Should not allow proceeding with an invalid format

## Testing Schedule Management

### Test Adding Time Slots

**Steps:**
1. Access a verified staff's schedule
2. Add a new time slot
3. Save the changes

**Expected Result:**
- New time slot should be added to the schedule
- UI should update to show the new slot

### Test Updating Time Slots

**Steps:**
1. Access a verified staff's schedule
2. Select an existing time slot
3. Update the time slot
4. Save the changes

**Expected Result:**
- Time slot should be updated
- UI should reflect the changes

### Test Removing Time Slots

**Steps:**
1. Access a verified staff's schedule
2. Select an existing time slot
3. Remove the time slot
4. Save the changes

**Expected Result:**
- Time slot should be removed from the schedule
- UI should update to remove the slot

## Testing Member-Staff Assignment

### Test Assigning Staff to Member

**Steps:**
1. Verify a new staff
2. Assign the staff to the current member

**Expected Result:**
- Staff should be assigned to the member
- UI should show the staff in the member's staff list

### Test Unassigning Staff from Member

**Steps:**
1. Access a member's staff list
2. Select an assigned staff
3. Unassign the staff

**Expected Result:**
- Staff should be unassigned from the member
- UI should update to remove the staff from the list
