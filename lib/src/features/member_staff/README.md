# Member Staff Booking Feature

This module provides functionality for members to search for staff, check availability, book staff services, and manage their bookings. It includes both list and calendar views for managing bookings.

## Features

- Search for staff by name, category, and availability
- View staff details and availability
- Book staff for specific dates and times
- View bookings in list or calendar format
- Reschedule or cancel bookings

## Screens

### Member Staff Search Screen
- Search for staff by name
- Filter by category and date
- View staff details and check availability

### Member Staff Booking Screen
- Select dates for booking
- Choose repeat type (once, daily, weekly)
- Select time slots
- Add notes
- Submit booking request

### Booking List Screen
- View all bookings grouped by date
- Reschedule or cancel bookings
- Switch to calendar view

### Calendar Booking Screen
- View bookings in a calendar format
- Tap on dates to see bookings for that day
- Reschedule or cancel bookings
- Switch to list view

## Components

### Reschedule Modal
- Select new date and time slots for a booking

### Cancel Confirmation Dialog
- Confirm booking cancellation

## API Services

The `MemberStaffBookingApi` class provides methods for:
- Getting member bookings
- Creating new bookings
- Rescheduling bookings
- Cancelling bookings
- Getting staff availability

The API connects to a Laravel backend that handles data persistence and business logic.

## Data Models

- `BookingRequest`: For creating new bookings
- `BookingResponse`: For handling booking creation responses
- `BookingSlotView`: For displaying booking slots in the UI
- `HourlyAvailability`: For representing staff availability by hour

## Usage

```dart
// Register routes in your app
final routes = MemberStaffBookingModule.getRoutes();

// Navigate to search screen
Navigator.pushNamed(context, '/member-staff/search');

// Navigate to bookings list
Navigator.pushNamed(context, '/member-staff/bookings');

// Navigate to calendar view
Navigator.pushNamed(context, '/member-staff/bookings/calendar');

// Navigate to booking screen with arguments
Navigator.pushNamed(
  context,
  '/member-staff/book',
  arguments: {
    'staffId': '1002',
    'staffName': 'Rajesh Kumar',
  },
);
```

## Backend Integration

This feature integrates with a Laravel backend API that provides:

- Role-based authorization (member vs admin roles)
- Data persistence with MySQL
- Business logic for booking management

The backend uses simplified models and migrations for easy maintenance:

```php
// MemberStaffBooking model
class MemberStaffBooking extends Model
{
    protected $fillable = [
        'staff_id', 'member_id', 'unit_id', 'company_id',
        'start_date', 'end_date', 'repeat_type', 'notes', 'status'
    ];

    public function slots(): HasMany
    {
        return $this->hasMany(BookingSlot::class, 'booking_id');
    }
}
```
