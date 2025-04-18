# Member Staff Feature

This module provides functionality for members to search for staff, check availability, book staff services, manage their bookings, and track staff attendance. It includes both list and calendar views for managing bookings and attendance.

## Features

- Search for staff by name, category, and availability
- View staff details and availability
- Book staff for specific dates and times
- View bookings in list or calendar format
- Reschedule or cancel bookings
- Track staff attendance with calendar view
- Mark staff as present or absent
- Capture photos and notes for attendance records
- Admin dashboard for monitoring staff attendance
- Real-time updates via WebSockets

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

### Staff Attendance Screen
- View calendar with attendance status indicators
- Mark staff as present or absent for selected date
- Add notes for attendance records
- Capture photos as proof of attendance
- Submit attendance records to backend

### Admin Attendance Dashboard
- View attendance records by date
- Filter by attendance status (present, absent, not marked)
- Search staff by name
- Export attendance data to CSV
- View photo proof of attendance
- Real-time updates of attendance changes

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

The `MemberStaffAttendanceApi` class provides methods for:
- Getting attendance records for a month
- Saving attendance records for a date

The `AdminAttendanceApi` class provides methods for:
- Getting attendance records with filtering and pagination
- Getting attendance summary statistics
- Updating attendance status

The `AttendanceService` class provides a higher-level interface for:
- Loading attendance data for a month
- Saving attendance records
- Taking photos for attendance proof
- Getting mock staff data for testing

The API connects to a Laravel backend that handles data persistence and business logic, with WebSockets for real-time updates.

## Data Models

- `BookingRequest`: For creating new bookings
- `BookingResponse`: For handling booking creation responses
- `BookingSlotView`: For displaying booking slots in the UI
- `HourlyAvailability`: For representing staff availability by hour
- `StaffAttendance`: For representing staff attendance records
- `DayAttendanceStatus`: For representing the overall attendance status for a day
- `AttendanceRecord`: For representing attendance records in the admin dashboard
- `AttendanceSummary`: For representing attendance summary statistics

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

// Navigate to attendance screen
Navigator.pushNamed(context, '/member-staff/attendance');

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
- WebSockets for real-time updates
- Laravel Echo Server for broadcasting events
- Redis for WebSockets message queue

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

// MemberStaffAttendance model
class MemberStaffAttendance extends Model
{
    use HasFactory;

    protected $table = 'member_staff_attendance';

    protected $fillable = [
        'member_id', 'staff_id', 'unit_id', 'date',
        'status', 'note', 'photo_url'
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function staff(): BelongsTo
    {
        return $this->belongsTo(Staff::class);
    }

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }
}

// AttendanceUpdated event for WebSockets
class AttendanceUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $attendanceData;

    public function __construct(MemberStaffAttendance $attendance)
    {
        $this->attendanceData = [
            'id' => $attendance->id,
            'staff_id' => $attendance->staff_id,
            'staff_name' => $attendance->staff->name ?? 'Unknown',
            'status' => $attendance->status,
            'updated_at' => $attendance->updated_at->toIso8601String()
        ];
    }

    public function broadcastOn()
    {
        return new Channel('attendance');
    }
}
```
