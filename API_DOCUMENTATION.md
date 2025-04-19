# Member Staff Module - API Documentation

This document provides a comprehensive overview of all API endpoints used in the Member Staff module. It serves as a reference for developers to understand the API structure and usage.

## Table of Contents

1. [Base URL](#base-url)
2. [Authentication](#authentication)
3. [Staff Management](#staff-management)
4. [Schedule Management](#schedule-management)
5. [Member-Staff Assignment](#member-staff-assignment)
6. [Admin Dashboard](#admin-dashboard)
7. [Staff Rating](#staff-rating)
8. [Error Handling](#error-handling)
9. [API Client](#api-client)
10. [API Models](#api-models)

## Base URL

The base URL for the Member Staff API is:

```
https://api.example.com/api
```

For development environments, the base URL is:

```
http://localhost:8000/api
```

## Authentication

All API requests (except for the authentication endpoints) require a valid JWT token issued by OneSSO (Keycloak) in the Authorization header:

```
Authorization: Bearer your_jwt_token
```

The JWT token should include the following standard claims:

- `sub`: The subject identifier (user ID)
- `iss`: The issuer of the token (Keycloak realm URL)
- `aud`: The audience of the token (client ID)
- `exp`: The expiration timestamp of the token
- `iat`: The issued-at timestamp of the token

And the following custom claims:

- `member_id`: The ID of the authenticated member
- `unit_id`: The ID of the member's unit
- `company_id`: The ID of the member's company
- `name`: The name of the authenticated member
- `email`: The email of the authenticated member
- `realm_access.roles`: Array of realm roles assigned to the user

### Generate Test Token

**Endpoint**: `POST /auth/generate-test-token`

Generates a test JWT token for development purposes.

**Request Body**:
```json
{
  "member_id": "00000000-0000-0000-0000-000000000001",
  "unit_id": "00000000-0000-0000-0000-000000000002",
  "company_id": "8454",
  "name": "Test Member",
  "email": "test@example.com"
}
```

**Response**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2023-07-27T12:00:00.000Z"
}
```

### Verify Token

**Endpoint**: `POST /auth/verify-token`

Verifies a JWT token.

**Request Body**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "sub": "00000000-0000-0000-0000-000000000000",
    "iss": "https://sso.oneapp.in/auth/realms/oneapp",
    "aud": "member-staff-api",
    "exp": 1690464000,
    "iat": 1690460400,
    "member_id": "00000000-0000-0000-0000-000000000001",
    "unit_id": "00000000-0000-0000-0000-000000000002",
    "company_id": "8454",
    "name": "Test Member",
    "email": "test@example.com",
    "realm_access": {
      "roles": ["member", "committee"]
    }
  }
}
```

### OneSSO Integration

The Member Staff module integrates with OneSSO (Keycloak) for authentication and authorization. This section describes the integration details.

#### Keycloak Configuration

The following environment variables are used to configure the Keycloak integration:

```
KEYCLOAK_BASE_URL=https://sso.oneapp.in
KEYCLOAK_REALM=oneapp
KEYCLOAK_REALM_URL=https://sso.oneapp.in/auth/realms/oneapp
KEYCLOAK_CLIENT_ID=member-staff-api
KEYCLOAK_PUBLIC_KEY=your_public_key_here
```

#### Token Validation

The `VerifyKeycloakToken` middleware validates the JWT token by:

1. Checking the token signature using the Keycloak public key
2. Verifying the token issuer matches the configured realm URL
3. Verifying the token audience includes the configured client ID
4. Checking the token expiration time

#### Role-Based Access Control

The `CommitteeRoleMiddleware` middleware checks if the user has the required role:

1. Extracts the `realm_access.roles` array from the token
2. Checks if the array contains the 'committee' role
3. Returns a 403 Forbidden response if the role is not present

## Staff Management

### Check Staff Mobile

**Endpoint**: `GET /staff/check`

Checks if a staff exists by mobile number.

**Query Parameters**:
- `mobile`: The mobile number to check (required)

**Response**:
```json
{
  "success": true,
  "exists": true,
  "verified": false,
  "staff_id": "00000000-0000-0000-0000-000000000003"
}
```

### Send OTP

**Endpoint**: `POST /staff/send-otp`

Sends an OTP to a mobile number.

**Request Body**:
```json
{
  "mobile": "917411122233"
}
```

**Response**:
```json
{
  "success": true,
  "message": "OTP sent successfully"
}
```

### Verify OTP

**Endpoint**: `POST /staff/verify-otp`

Verifies an OTP.

**Request Body**:
```json
{
  "mobile": "917411122233",
  "otp": "123456"
}
```

**Response**:
```json
{
  "success": true,
  "message": "OTP verified successfully"
}
```

### Create Staff

**Endpoint**: `POST /staff`

Creates a new staff.

**Request Body**:
```json
{
  "name": "John Doe",
  "mobile": "917433344455",
  "email": "john.doe@example.com",
  "staff_scope": "member",
  "unit_id": "00000000-0000-0000-0000-000000000002",
  "company_id": "8454",
  "member_id": "00000000-0000-0000-0000-000000000001"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Staff created successfully",
  "data": {
    "id": "00000000-0000-0000-0000-000000000003",
    "name": "John Doe",
    "mobile": "917433344455",
    "email": "john.doe@example.com",
    "staff_scope": "member",
    "unit_id": "00000000-0000-0000-0000-000000000002",
    "company_id": "8454",
    "is_verified": false,
    "created_by": "00000000-0000-0000-0000-000000000001",
    "updated_by": "00000000-0000-0000-0000-000000000001",
    "created_at": "2023-07-20T12:00:00.000Z",
    "updated_at": "2023-07-20T12:00:00.000Z"
  }
}
```

### Get Staff

**Endpoint**: `GET /staff/{id}`

Gets a staff's details.

**Path Parameters**:
- `id`: The ID of the staff (required)

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "00000000-0000-0000-0000-000000000003",
    "name": "John Doe",
    "mobile": "917433344455",
    "email": "john.doe@example.com",
    "staff_scope": "member",
    "unit_id": "00000000-0000-0000-0000-000000000002",
    "company_id": "8454",
    "is_verified": false,
    "created_by": "00000000-0000-0000-0000-000000000001",
    "updated_by": "00000000-0000-0000-0000-000000000001",
    "created_at": "2023-07-20T12:00:00.000Z",
    "updated_at": "2023-07-20T12:00:00.000Z"
  }
}
```

### Update Staff

**Endpoint**: `PUT /staff/{id}`

Updates a staff's details.

**Path Parameters**:
- `id`: The ID of the staff (required)

**Request Body**:
```json
{
  "name": "John Doe Updated",
  "email": "john.updated@example.com",
  "member_id": "00000000-0000-0000-0000-000000000001"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Staff updated successfully",
  "data": {
    "id": "00000000-0000-0000-0000-000000000003",
    "name": "John Doe Updated",
    "mobile": "917433344455",
    "email": "john.updated@example.com",
    "staff_scope": "member",
    "unit_id": "00000000-0000-0000-0000-000000000002",
    "company_id": "8454",
    "is_verified": false,
    "created_by": "00000000-0000-0000-0000-000000000001",
    "updated_by": "00000000-0000-0000-0000-000000000001",
    "created_at": "2023-07-20T12:00:00.000Z",
    "updated_at": "2023-07-20T12:01:00.000Z"
  }
}
```

### Verify Staff Identity

**Endpoint**: `PUT /staff/{id}/verify`

Verifies a staff's identity.

**Path Parameters**:
- `id`: The ID of the staff (required)

**Request Body (multipart/form-data)**:
```
aadhaar_number: 123456789012
residential_address: 123 Main St, City, State, Country
next_of_kin_name: Jane Doe
next_of_kin_mobile: 917411122234
photo: [file]
member_id: 00000000-0000-0000-0000-000000000001
```

**Response**:
```json
{
  "success": true,
  "message": "Staff verified successfully",
  "data": {
    "id": "00000000-0000-0000-0000-000000000003",
    "name": "John Doe Updated",
    "mobile": "917433344455",
    "email": "john.updated@example.com",
    "staff_scope": "member",
    "unit_id": "00000000-0000-0000-0000-000000000002",
    "company_id": "8454",
    "aadhaar_number": "123456789012",
    "residential_address": "123 Main St, City, State, Country",
    "next_of_kin_name": "Jane Doe",
    "next_of_kin_mobile": "917411122234",
    "photo_url": "storage/staff_photos/1689854400_photo.jpg",
    "is_verified": true,
    "verified_at": "2023-07-20T12:02:00.000Z",
    "verified_by_member_id": "00000000-0000-0000-0000-000000000001",
    "created_by": "00000000-0000-0000-0000-000000000001",
    "updated_by": "00000000-0000-0000-0000-000000000001",
    "created_at": "2023-07-20T12:00:00.000Z",
    "updated_at": "2023-07-20T12:02:00.000Z"
  }
}
```

### Delete Staff

**Endpoint**: `DELETE /staff/{id}`

Deletes a staff.

**Path Parameters**:
- `id`: The ID of the staff (required)

**Response**:
```json
{
  "success": true,
  "message": "Staff deleted successfully"
}
```

## Schedule Management

### Get Staff Schedule

**Endpoint**: `GET /staff/{staffId}/schedule`

Gets a staff's schedule.

**Path Parameters**:
- `staffId`: The ID of the staff (required)

**Query Parameters**:
- `start_date`: The start date of the schedule (optional, default: today)
- `end_date`: The end date of the schedule (optional, default: start_date + 6 days)

**Response**:
```json
{
  "success": true,
  "data": {
    "staff": {
      "id": "00000000-0000-0000-0000-000000000003",
      "name": "John Doe",
      "mobile": "917433344455",
      "email": "john.doe@example.com",
      "staff_scope": "member",
      "unit_id": "00000000-0000-0000-0000-000000000002",
      "company_id": "8454",
      "is_verified": true,
      "created_at": "2023-07-20T12:00:00.000Z",
      "updated_at": "2023-07-20T12:02:00.000Z"
    },
    "time_slots": [
      {
        "id": "00000000-0000-0000-0000-000000000004",
        "staff_id": "00000000-0000-0000-0000-000000000003",
        "date": "2023-07-20",
        "start_time": "09:00",
        "end_time": "10:00",
        "is_booked": false,
        "created_at": "2023-07-20T12:05:00.000Z",
        "updated_at": "2023-07-20T12:05:00.000Z"
      }
    ],
    "start_date": "2023-07-20",
    "end_date": "2023-07-26"
  }
}
```

### Add Time Slot

**Endpoint**: `POST /staff/{staffId}/schedule/slots`

Adds a time slot to a staff's schedule.

**Path Parameters**:
- `staffId`: The ID of the staff (required)

**Request Body**:
```json
{
  "date": "2023-07-21",
  "start_time": "09:00",
  "end_time": "10:00",
  "is_booked": false,
  "member_id": "00000000-0000-0000-0000-000000000001"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Time slot added successfully",
  "data": {
    "id": "00000000-0000-0000-0000-000000000005",
    "staff_id": "00000000-0000-0000-0000-000000000003",
    "date": "2023-07-21",
    "start_time": "09:00",
    "end_time": "10:00",
    "is_booked": false,
    "created_at": "2023-07-20T12:10:00.000Z",
    "updated_at": "2023-07-20T12:10:00.000Z"
  }
}
```

### Update Time Slot

**Endpoint**: `PUT /staff/{staffId}/schedule/slots/{timeSlotId}`

Updates a time slot.

**Path Parameters**:
- `staffId`: The ID of the staff (required)
- `timeSlotId`: The ID of the time slot (required)

**Request Body**:
```json
{
  "date": "2023-07-21",
  "start_time": "10:00",
  "end_time": "11:00",
  "is_booked": true,
  "member_id": "00000000-0000-0000-0000-000000000001"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Time slot updated successfully",
  "data": {
    "id": "00000000-0000-0000-0000-000000000005",
    "staff_id": "00000000-0000-0000-0000-000000000003",
    "date": "2023-07-21",
    "start_time": "10:00",
    "end_time": "11:00",
    "is_booked": true,
    "created_at": "2023-07-20T12:10:00.000Z",
    "updated_at": "2023-07-20T12:15:00.000Z"
  }
}
```

### Remove Time Slot

**Endpoint**: `DELETE /staff/{staffId}/schedule/slots/{timeSlotId}`

Removes a time slot.

**Path Parameters**:
- `staffId`: The ID of the staff (required)
- `timeSlotId`: The ID of the time slot (required)

**Response**:
```json
{
  "success": true,
  "message": "Time slot removed successfully"
}
```

### Get Time Slots for Date

**Endpoint**: `GET /staff/{staffId}/schedule/date/{date}`

Gets time slots for a specific date.

**Path Parameters**:
- `staffId`: The ID of the staff (required)
- `date`: The date in YYYY-MM-DD format (required)

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "00000000-0000-0000-0000-000000000004",
      "staff_id": "00000000-0000-0000-0000-000000000003",
      "date": "2023-07-20",
      "start_time": "09:00",
      "end_time": "10:00",
      "is_booked": false,
      "created_at": "2023-07-20T12:05:00.000Z",
      "updated_at": "2023-07-20T12:05:00.000Z"
    }
  ]
}
```

### Bulk Add Time Slots

**Endpoint**: `POST /staff/{staffId}/schedule/slots/bulk`

Bulk adds time slots.

**Path Parameters**:
- `staffId`: The ID of the staff (required)

**Request Body**:
```json
{
  "time_slots": [
    {
      "date": "2023-07-22",
      "start_time": "09:00",
      "end_time": "10:00",
      "is_booked": false
    },
    {
      "date": "2023-07-22",
      "start_time": "10:00",
      "end_time": "11:00",
      "is_booked": false
    },
    {
      "date": "2023-07-22",
      "start_time": "11:00",
      "end_time": "12:00",
      "is_booked": false
    }
  ],
  "member_id": "00000000-0000-0000-0000-000000000001"
}
```

**Response**:
```json
{
  "success": true,
  "message": "3 time slots added successfully",
  "data": {
    "added_time_slots": [
      {
        "id": "00000000-0000-0000-0000-000000000006",
        "staff_id": "00000000-0000-0000-0000-000000000003",
        "date": "2023-07-22",
        "start_time": "09:00",
        "end_time": "10:00",
        "is_booked": false,
        "created_at": "2023-07-20T12:20:00.000Z",
        "updated_at": "2023-07-20T12:20:00.000Z"
      },
      {
        "id": "00000000-0000-0000-0000-000000000007",
        "staff_id": "00000000-0000-0000-0000-000000000003",
        "date": "2023-07-22",
        "start_time": "10:00",
        "end_time": "11:00",
        "is_booked": false,
        "created_at": "2023-07-20T12:20:00.000Z",
        "updated_at": "2023-07-20T12:20:00.000Z"
      },
      {
        "id": "00000000-0000-0000-0000-000000000008",
        "staff_id": "00000000-0000-0000-0000-000000000003",
        "date": "2023-07-22",
        "start_time": "11:00",
        "end_time": "12:00",
        "is_booked": false,
        "created_at": "2023-07-20T12:20:00.000Z",
        "updated_at": "2023-07-20T12:20:00.000Z"
      }
    ],
    "conflicting_time_slots": []
  }
}
```

## Member-Staff Assignment

### Get Member Staff

**Endpoint**: `GET /members/{memberId}/staff`

Gets staff assigned to a member.

**Path Parameters**:
- `memberId`: The ID of the member (required)

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "00000000-0000-0000-0000-000000000003",
      "name": "John Doe",
      "mobile": "917433344455",
      "email": "john.doe@example.com",
      "staff_scope": "member",
      "unit_id": "00000000-0000-0000-0000-000000000002",
      "company_id": "8454",
      "is_verified": true,
      "created_at": "2023-07-20T12:00:00.000Z",
      "updated_at": "2023-07-20T12:02:00.000Z",
      "time_slots": [
        {
          "id": "00000000-0000-0000-0000-000000000004",
          "staff_id": "00000000-0000-0000-0000-000000000003",
          "date": "2023-07-20",
          "start_time": "09:00",
          "end_time": "10:00",
          "is_booked": false,
          "created_at": "2023-07-20T12:05:00.000Z",
          "updated_at": "2023-07-20T12:05:00.000Z"
        }
      ]
    }
  ]
}
```

### Assign Staff to Member

**Endpoint**: `POST /member-staff/assign`

Assigns a staff to a member.

**Request Body**:
```json
{
  "member_id": "00000000-0000-0000-0000-000000000001",
  "staff_id": "00000000-0000-0000-0000-000000000003",
  "assigned_by": "00000000-0000-0000-0000-000000000001"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Staff assigned successfully",
  "data": {
    "id": "00000000-0000-0000-0000-000000000009",
    "member_id": "00000000-0000-0000-0000-000000000001",
    "staff_id": "00000000-0000-0000-0000-000000000003",
    "assigned_by": "00000000-0000-0000-0000-000000000001",
    "is_active": true,
    "created_at": "2023-07-20T12:25:00.000Z",
    "updated_at": "2023-07-20T12:25:00.000Z"
  }
}
```

### Unassign Staff from Member

**Endpoint**: `POST /member-staff/unassign`

Unassigns a staff from a member.

**Request Body**:
```json
{
  "member_id": "00000000-0000-0000-0000-000000000001",
  "staff_id": "00000000-0000-0000-0000-000000000003"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Staff unassigned successfully"
}
```

### Get Company Staff

**Endpoint**: `GET /company/{companyId}/staff`

Gets all staff for a company.

**Path Parameters**:
- `companyId`: The ID of the company (required)

**Query Parameters**:
- `staff_scope`: Filter by staff scope (optional, values: society, member)
- `is_verified`: Filter by verification status (optional, values: true, false)

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "00000000-0000-0000-0000-000000000003",
      "name": "John Doe",
      "mobile": "917433344455",
      "email": "john.doe@example.com",
      "staff_scope": "member",
      "unit_id": "00000000-0000-0000-0000-000000000002",
      "company_id": "8454",
      "is_verified": true,
      "created_at": "2023-07-20T12:00:00.000Z",
      "updated_at": "2023-07-20T12:02:00.000Z"
    }
  ]
}
```

### Search Staff

**Endpoint**: `GET /staff/search`

Searches for staff.

**Query Parameters**:
- `company_id`: The ID of the company (required)
- `query`: The search query (required, minimum 3 characters)
- `staff_scope`: Filter by staff scope (optional, values: society, member)
- `is_verified`: Filter by verification status (optional, values: true, false)

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "00000000-0000-0000-0000-000000000003",
      "name": "John Doe",
      "mobile": "917433344455",
      "email": "john.doe@example.com",
      "staff_scope": "member",
      "unit_id": "00000000-0000-0000-0000-000000000002",
      "company_id": "8454",
      "is_verified": true,
      "created_at": "2023-07-20T12:00:00.000Z",
      "updated_at": "2023-07-20T12:02:00.000Z"
    }
  ]
}
```

## Admin Dashboard

### Get Attendance Records

**Endpoint**: `GET /admin/attendance`

Retrieves attendance records with filtering and pagination.

**Query Parameters**:
- `date` (required): Date to get attendance for (YYYY-MM-DD)
- `status` (optional): Filter by attendance status (present, absent, not_marked)
- `search` (optional): Search term for staff name
- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Number of records per page (default: 10)

**Response**:
```json
{
  "records": [
    {
      "staff_id": 1001,
      "staff_name": "Staff Member 1",
      "staff_category": "Domestic Help",
      "staff_photo": "https://example.com/photo1.jpg",
      "status": "present",
      "note": "On time",
      "photo_url": "https://example.com/proof1.jpg",
      "updated_at": "2023-11-15T09:30:00.000Z"
    }
  ],
  "total": 20,
  "page": 1,
  "limit": 10,
  "totalPages": 2
}
```

### Get Attendance Summary

**Endpoint**: `GET /admin/attendance/summary`

Retrieves summary statistics for attendance on a specific date.

**Query Parameters**:
- `date` (required): Date to get summary for (YYYY-MM-DD)

**Response**:
```json
{
  "present": 15,
  "absent": 5,
  "not_marked": 2,
  "total": 22
}
```

### Update Attendance Status

**Endpoint**: `POST /admin/attendance/update`

Updates the status of an attendance record and broadcasts the change via WebSockets.

**Request Body**:
```json
{
  "attendance_id": 1001,
  "status": "present",
  "note": "Updated note"
}
```

**Response**:
```json
{
  "status": "success",
  "message": "Attendance updated successfully",
  "attendance": {
    "id": 1001,
    "staff_id": 1001,
    "staff_name": "Staff Member 1",
    "status": "present",
    "note": "Updated note",
    "photo_url": "https://example.com/proof1.jpg",
    "updated_at": "2023-11-15T10:15:00.000Z"
  }
}
```

## Staff Rating

### Submit Rating

**Endpoint**: `POST /staff/rating`

Submits a rating for a staff member.

**Request Body**:
```json
{
  "member_id": 12,
  "staff_id": 1003,
  "staff_type": "member",
  "rating": 4,
  "feedback": "Very punctual and polite"
}
```

**Response**:
```json
{
  "message": "Rating submitted successfully.",
  "rating": {
    "id": 1,
    "member_id": 12,
    "staff_id": 1003,
    "staff_type": "member",
    "rating": 4,
    "feedback": "Very punctual and polite",
    "created_at": "2023-11-20T12:00:00.000Z",
    "updated_at": "2023-11-20T12:00:00.000Z"
  }
}
```

### Get Ratings Summary

**Endpoint**: `GET /staff/{staff_id}/ratings`

**Query Parameters**:
- `staff_type`: The type of staff ("society" or "member") (required)

Gets a summary of ratings for a staff member.

**Response**:
```json
{
  "staff_id": 1003,
  "staff_type": "member",
  "average_rating": 4.2,
  "total_ratings": 18,
  "rating_distribution": {
    "1": 1,
    "2": 2,
    "3": 3,
    "4": 5,
    "5": 7
  },
  "recent_reviews": [
    {
      "rating": 5,
      "feedback": "Great service!",
      "member_name": "Asha",
      "created_at": "2023-11-19T10:30:00.000Z"
    },
    {
      "rating": 4,
      "feedback": "Very punctual and polite",
      "member_name": "Rahul",
      "created_at": "2023-11-18T14:45:00.000Z"
    }
  ]
}
```

### Get All Ratings (Admin)

**Endpoint**: `GET /admin/staff/ratings`

**Query Parameters**:
- `staff_type`: Filter by staff type ("society" or "member") (optional)
- `min_rating`: Minimum rating value (1-5) (optional)
- `max_rating`: Maximum rating value (1-5) (optional)
- `page`: Page number (default: 1) (optional)
- `limit`: Number of ratings per page (default: 10) (optional)

Gets all ratings with filtering and pagination (admin only).

**Response**:
```json
{
  "total": 50,
  "page": 1,
  "limit": 10,
  "ratings": [
    {
      "id": 1,
      "member_id": 12,
      "staff_id": 1003,
      "staff_type": "member",
      "rating": 4,
      "feedback": "Very punctual and polite",
      "created_at": "2023-11-20T12:00:00.000Z",
      "updated_at": "2023-11-20T12:00:00.000Z",
      "member": {
        "id": 12,
        "name": "Rahul"
      }
    },
    // More ratings...
  ]
}
```

### Export Ratings (Admin)

**Endpoint**: `GET /admin/staff/ratings/export`

**Query Parameters**:
- `staff_type`: Filter by staff type ("society" or "member") (optional)
- `min_rating`: Minimum rating value (1-5) (optional)
- `max_rating`: Maximum rating value (1-5) (optional)

Exports ratings as a CSV file (admin only).

**Response**: CSV file

## All Dues Report (Committee Only)

The All Dues Report API provides financial reporting capabilities for committee members. These endpoints are protected by the `CommitteeRoleMiddleware` which verifies the user has the 'committee' role in their Keycloak token.

### Get Dues Report

**Endpoint**: `GET /committee/dues-report`

**Query Parameters**:
- `building`: Filter by building name or code (optional)
- `wing`: Filter by wing name or code (optional)
- `floor`: Filter by floor number (optional)
- `month`: Filter by month in YYYY-MM format (optional)
- `status`: Filter by payment status (unpaid, partial, overdue) (optional)
- `search`: Search by member name or unit number (optional)
- `min_due`: Minimum due amount (optional)
- `max_due`: Maximum due amount (optional)
- `page`: Page number for pagination (default: 1) (optional)
- `per_page`: Number of records per page (default: 15) (optional)

**Response**:
```json
{
  "current_page": 1,
  "data": [
    {
      "member_name": "John Doe",
      "unit_number": "A-101",
      "building_name": "Building A",
      "bill_cycle": "Apr 2025",
      "bill_amount": 1000,
      "amount_paid": 0,
      "due_amount": 1000,
      "due_date": "2025-04-10",
      "last_payment_date": null
    }
  ],
  "first_page_url": "http://example.com/api/committee/dues-report?page=1",
  "from": 1,
  "last_page": 10,
  "last_page_url": "http://example.com/api/committee/dues-report?page=10",
  "links": [...],
  "next_page_url": "http://example.com/api/committee/dues-report?page=2",
  "path": "http://example.com/api/committee/dues-report",
  "per_page": 15,
  "prev_page_url": null,
  "to": 15,
  "total": 150
}
```

### Export Dues Report

**Endpoint**: `GET /committee/dues-report/export`

**Query Parameters**:
- Same filtering parameters as the Get Dues Report endpoint

Exports the dues report as a CSV file.

**Response**: CSV file

### Get Chart Summary

**Endpoint**: `GET /committee/dues-report/chart-summary`

**Query Parameters**:
- `month`: Filter by month in YYYY-MM format (optional)
- `chart_type`: Type of chart data to return (wing, floor, top_members) (default: wing)

**Response**:
```json
[
  {
    "label": "Building A",
    "total_due": 25000
  },
  {
    "label": "Building B",
    "total_due": 12000
  },
  {
    "label": "Building C",
    "total_due": 34000
  }
]
```

## Error Handling

All API endpoints return a consistent error response format:

```json
{
  "success": false,
  "message": "Error message",
  "errors": {
    "field1": ["Error message 1", "Error message 2"],
    "field2": ["Error message 3"]
  }
}
```

### Common Error Codes

- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Missing or invalid authentication token
  - `Token has expired`: The Keycloak token has expired
  - `Invalid token signature`: The token signature is invalid
  - `Invalid token issuer`: The token issuer doesn't match the expected Keycloak realm URL
  - `Invalid token audience`: The token audience doesn't include the expected client ID
- `403 Forbidden`: Insufficient permissions
  - `Unauthorized. Committee access required.`: The user doesn't have the 'committee' role
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation error
- `500 Internal Server Error`: Server error

## API Client

The Member Staff module includes an API client for making requests to the API:

```dart
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams});
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body});
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body});
  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? body});
}
```

### Usage

```dart
final apiClient = ApiClient(baseUrl: 'https://api.example.com/api');

// Get request
final response = await apiClient.get('staff/check', queryParams: {'mobile': '917411122233'});

// Post request
final response = await apiClient.post('staff/send-otp', body: {'mobile': '917411122233'});

// Put request
final response = await apiClient.put('staff/00000000-0000-0000-0000-000000000003', body: {'name': 'John Doe Updated'});

// Delete request
final response = await apiClient.delete('staff/00000000-0000-0000-0000-000000000003');
```

## API Models

The Member Staff module includes models for API requests and responses:

### ApiResponse

```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson);
  factory ApiResponse.fromJsonList(Map<String, dynamic> json, T Function(dynamic) fromJson);
}
```

### ApiException

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isAuthError;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.isAuthError = false,
    this.errors,
  });
}
```

## Conclusion

This document provides a comprehensive overview of all API endpoints used in the Member Staff module. It serves as a reference for developers to understand the API structure and usage.

For more detailed information about each endpoint, please refer to the source code and inline documentation.
