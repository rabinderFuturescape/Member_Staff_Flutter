# Member Staff API

This is the backend API for the Member Staff module, built with Laravel.

## Overview

The Member Staff API provides endpoints for managing staff members, their schedules, and their assignments to members. It includes features for staff verification, OTP verification, and schedule management.

## Requirements

- PHP 8.1+
- Laravel 10.x
- MySQL 8.0+
- Composer

## Installation

1. Clone the repository:

```bash
git clone https://github.com/your-org/member-staff-api.git
cd member-staff-api
```

2. Install dependencies:

```bash
composer install
```

3. Copy the environment file:

```bash
cp .env.example .env
```

4. Generate an application key:

```bash
php artisan key:generate
```

5. Configure your database in the `.env` file:

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=member_staff
DB_USERNAME=root
DB_PASSWORD=
```

6. Configure JWT secret in the `.env` file:

```
JWT_SECRET=your_jwt_secret_key
```

7. Run migrations:

```bash
php artisan migrate
```

8. Seed the database (optional):

```bash
php artisan db:seed
```

9. Start the development server:

```bash
php artisan serve
```

## API Endpoints

### Authentication

- `POST /api/auth/generate-test-token` - Generate a test JWT token
- `POST /api/auth/verify-token` - Verify a JWT token

### Staff Management

- `GET /api/staff/check` - Check if a staff exists by mobile number
- `POST /api/staff/send-otp` - Send OTP to a mobile number
- `POST /api/staff/verify-otp` - Verify an OTP
- `POST /api/staff` - Create a new staff
- `GET /api/staff/{id}` - Get a staff's details
- `PUT /api/staff/{id}` - Update a staff's details
- `PUT /api/staff/{id}/verify` - Verify a staff's identity
- `DELETE /api/staff/{id}` - Delete a staff

### Schedule Management

- `GET /api/staff/{staffId}/schedule` - Get a staff's schedule
- `POST /api/staff/{staffId}/schedule/slots` - Add a time slot to a staff's schedule
- `PUT /api/staff/{staffId}/schedule/slots/{timeSlotId}` - Update a time slot
- `DELETE /api/staff/{staffId}/schedule/slots/{timeSlotId}` - Remove a time slot
- `GET /api/staff/{staffId}/schedule/date/{date}` - Get time slots for a specific date
- `POST /api/staff/{staffId}/schedule/slots/bulk` - Bulk add time slots

### Member-Staff Assignment

- `GET /api/members/{memberId}/staff` - Get staff assigned to a member
- `POST /api/member-staff/assign` - Assign a staff to a member
- `POST /api/member-staff/unassign` - Unassign a staff from a member
- `GET /api/company/{companyId}/staff` - Get all staff for a company
- `GET /api/staff/search` - Search for staff

## Authentication

All protected endpoints require a valid JWT token in the Authorization header:

```
Authorization: Bearer your_jwt_token
```

The JWT token should include the following claims:

- `member_id` - The ID of the authenticated member
- `unit_id` - The ID of the member's unit
- `company_id` - The ID of the member's company

## Member Context

All protected endpoints require member context in the request body:

- `member_id` - The ID of the authenticated member
- `unit_id` - The ID of the member's unit
- `company_id` - The ID of the member's company

This context is automatically added to the request by the `VerifyJwtToken` middleware.

## Testing

To run the tests:

```bash
php artisan test
```

## Development

### Middleware

The API uses two middleware:

1. `VerifyJwtToken` - Verifies the JWT token and adds the token payload to the request
2. `VerifyMemberContext` - Verifies that the member context is present in the request

### Models

The API includes the following models:

- `Staff` - Represents a staff member
- `TimeSlot` - Represents a time slot in a staff's schedule
- `Member` - Represents a member
- `Unit` - Represents a unit
- `MemberStaffAssignment` - Represents an assignment of a staff to a member
- `Otp` - Represents an OTP for mobile verification

### Controllers

The API includes the following controllers:

- `AuthController` - Handles authentication
- `StaffController` - Handles staff management
- `TimeSlotController` - Handles schedule management
- `MemberStaffController` - Handles member-staff assignments

## License

This project is licensed under the MIT License.
