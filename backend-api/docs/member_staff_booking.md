# Member Staff Booking Feature

This document provides detailed information about the Member Staff Booking feature in the OneApp application.

## Overview

The Member Staff Booking feature allows members to book staff services for specific dates and times. It supports one-time bookings, daily repeating bookings, and weekly repeating bookings. Members can view their bookings, reschedule them, and cancel them.

## Models

### MemberStaffBooking

Represents a booking made by a member for staff services.

**Fields:**
- `id` (bigint): Primary key, auto-incrementing
- `staff_id` (bigint): Foreign key to Staff model
- `member_id` (bigint): Foreign key to Member model
- `unit_id` (bigint): ID of the member's unit
- `company_id` (bigint): ID of the member's company
- `start_date` (date): Start date of the booking
- `end_date` (date): End date of the booking
- `repeat_type` (string): Type of repeat (once, daily, weekly)
- `notes` (text, nullable): Additional notes for the booking
- `status` (string): Status of the booking (pending, confirmed, rescheduled, cancelled)

**Relationships:**
- `slots`: HasMany relationship with BookingSlot model

### BookingSlot

Represents a time slot within a booking.

**Fields:**
- `id` (bigint): Primary key, auto-incrementing
- `booking_id` (bigint): Foreign key to MemberStaffBooking model
- `date` (date): Date of the slot
- `hour` (integer): Hour of the day (0-23)
- `is_confirmed` (boolean): Whether the slot is confirmed

**Relationships:**
- `booking`: BelongsTo relationship with MemberStaffBooking model

## API Endpoints

### Get Member Bookings

```
GET /api/member-staff/bookings?member_id=12345
```

**Description:** Get all bookings for a member.

**Authentication:** Required

**Authorization:** User must be allowed to view bookings.

**Query Parameters:**
- `member_id` (required): ID of the member

**Response:**
```json
[
  {
    "booking_id": 1,
    "staff_id": 1002,
    "date": "2025-04-21",
    "hour": 9,
    "status": "pending"
  },
  {
    "booking_id": 1,
    "staff_id": 1002,
    "date": "2025-04-21",
    "hour": 10,
    "status": "pending"
  }
]
```

### Create Booking

```
POST /api/member-staff/booking
```

**Description:** Create a new booking.

**Authentication:** Required

**Authorization:** User must be allowed to create bookings.

**Request Body:**
```json
{
  "staff_id": 1002,
  "member_id": 12,
  "unit_id": 3,
  "company_id": 8454,
  "start_date": "2025-04-21",
  "end_date": "2025-04-21",
  "repeat_type": "once",
  "slot_hours": [9, 10],
  "notes": "Need cleaning service in the morning"
}
```

**Response:**
```json
{
  "status": "success",
  "booking_id": 1
}
```

### Reschedule Booking

```
PUT /api/member-staff/booking/1
```

**Description:** Reschedule a booking.

**Authentication:** Required

**Authorization:** User must be allowed to reschedule bookings.

**Request Body:**
```json
{
  "new_date": "2023-08-10",
  "new_hours": [14, 15, 16]
}
```

**Response:**
```json
{
  "status": "rescheduled"
}
```

### Cancel Booking

```
DELETE /api/member-staff/booking/1
```

**Description:** Cancel a booking.

**Authentication:** Required

**Authorization:** User must be allowed to cancel bookings.

**Response:**
```json
{
  "status": "deleted"
}
```

## Authorization

The Member Staff Booking feature uses Laravel's authorization system with policies and gates.

### Gates

- `view-bookings`: Determine whether the user can view bookings
- `create-booking`: Determine whether the user can create bookings
- `reschedule-booking`: Determine whether the user can reschedule a booking
- `cancel-booking`: Determine whether the user can cancel a booking

### Policy

The `MemberStaffBookingPolicy` class handles authorization for member staff bookings based on user roles:

```php
public function viewBookings(User $user)
{
    return $user->role === 'member' || $user->role === 'admin';
}

public function createBooking(User $user)
{
    return $user->role === 'member';
}

public function rescheduleBooking(User $user)
{
    return $user->role === 'member';
}

public function cancelBooking(User $user)
{
    return $user->role === 'member';
}
```

## Database Schema

### member_staff_bookings Table

```sql
CREATE TABLE `member_staff_bookings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `staff_id` bigint(20) unsigned NOT NULL,
  `member_id` bigint(20) unsigned NOT NULL,
  `unit_id` bigint(20) unsigned NOT NULL,
  `company_id` bigint(20) unsigned NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `repeat_type` varchar(255) NOT NULL DEFAULT 'once',
  `notes` text DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### booking_slots Table

```sql
CREATE TABLE `booking_slots` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` bigint(20) unsigned NOT NULL,
  `date` date NOT NULL,
  `hour` int(11) NOT NULL,
  `is_confirmed` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `booking_slots_booking_id_foreign` FOREIGN KEY (`booking_id`) REFERENCES `member_staff_bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Implementation Details

### Booking Creation

When a booking is created, the system:
1. Creates a `MemberStaffBooking` record
2. Creates `BookingSlot` records for each hour in the booking
3. Sets the status of the booking to "pending"

### Booking Rescheduling

When a booking is rescheduled, the system:
1. Deletes all existing `BookingSlot` records for the booking
2. Creates new `BookingSlot` records for the new date and hours
3. Updates the `start_date` and `end_date` of the booking
4. Sets the status of the booking to "rescheduled"

### Booking Cancellation

When a booking is cancelled, the system:
1. Deletes all `BookingSlot` records for the booking
2. Deletes the `MemberStaffBooking` record

## Testing

The Member Staff Booking feature includes a seeder for testing:

- `MemberStaffBookingSeeder`: Seeder for populating the database with a sample booking and slots

```php
public function run()
{
    $booking = MemberStaffBooking::create([
        'staff_id' => 1002,
        'member_id' => 12,
        'unit_id' => 3,
        'company_id' => 8454,
        'start_date' => '2025-04-21',
        'end_date' => '2025-04-21',
        'repeat_type' => 'once',
        'notes' => 'Test booking seeder',
        'status' => 'pending'
    ]);

    BookingSlot::create([
        'booking_id' => $booking->id,
        'date' => '2025-04-21',
        'hour' => 9,
        'is_confirmed' => false
    ]);

    BookingSlot::create([
        'booking_id' => $booking->id,
        'date' => '2025-04-21',
        'hour' => 10,
        'is_confirmed' => false
    ]);
}
```

To run the seeder:

```bash
php artisan db:seed --class=MemberStaffBookingSeeder
```
