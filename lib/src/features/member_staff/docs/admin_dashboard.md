# Member Staff Admin Dashboard

## Overview

The Member Staff Admin Dashboard provides a comprehensive interface for administrators to monitor and manage staff attendance records. It features both standard and real-time views of attendance data, with filtering, search, and export capabilities.

## Features

- View attendance records by date
- Filter by attendance status (present, absent, not marked)
- Search staff by name
- Real-time updates via WebSockets
- Export attendance data to CSV
- Visual notifications for attendance changes
- Summary statistics

## Architecture

### Frontend (Next.js)

The frontend is built with Next.js and uses the following technologies:

- **React**: For building the UI components
- **TailwindCSS**: For styling
- **Laravel Echo**: For WebSockets integration
- **Pusher.js**: For WebSockets client
- **Axios**: For API requests
- **React CSV**: For CSV export

### Backend (Laravel)

The backend is built with Laravel and uses the following technologies:

- **Laravel Echo Server**: For WebSockets server
- **Redis**: For WebSockets broadcasting
- **Laravel Broadcasting**: For event broadcasting
- **Laravel Gates**: For authorization

## Authentication & Authorization

Access to the admin dashboard is restricted to users with the 'admin' role. This is enforced through:

1. **Laravel Gates**: The `view-admin-dashboard` gate checks if the user has the 'admin' role
2. **Middleware**: The `can:view-admin-dashboard` middleware is applied to all admin routes

## WebSockets Integration

Real-time updates are implemented using Laravel Echo and Pusher:

1. **Backend**: The `AttendanceUpdated` event is broadcast on the 'attendance' channel
2. **Frontend**: The dashboard subscribes to the channel and updates the UI when events are received

## API Endpoints

### GET /api/admin/attendance

Retrieves attendance records with filtering and pagination.

**Query Parameters:**
- `date` (required): Date to get attendance for (YYYY-MM-DD)
- `status` (optional): Filter by attendance status (present, absent, not_marked)
- `search` (optional): Search term for staff name
- `page` (optional): Page number for pagination
- `limit` (optional): Number of records per page

### GET /api/admin/attendance/summary

Retrieves summary statistics for attendance on a specific date.

**Query Parameters:**
- `date` (required): Date to get summary for (YYYY-MM-DD)

### POST /api/admin/attendance/update

Updates the status of an attendance record and broadcasts the change.

**Request Body:**
```json
{
  "attendance_id": 1,
  "status": "present",
  "note": "Optional note"
}
```

## Testing

The codebase includes comprehensive tests for both the backend and frontend:

### Backend Tests

- `AdminAttendanceControllerTest`: Tests the API endpoints
- `AttendanceUpdatedEventTest`: Tests the WebSockets event

### Frontend Tests

- `echo.test.js`: Tests the WebSockets integration

## Integration with Flutter App

The admin dashboard is designed to complement the Flutter app's member-facing attendance tracking features. While members use the Flutter app to mark attendance for their staff, administrators use the web dashboard to:

1. Monitor attendance across all members and staff
2. Generate reports and analytics
3. Verify attendance records with photo proof
4. Make corrections to attendance records when necessary

The Flutter app and admin dashboard share the same backend API and database, ensuring data consistency across both platforms.

## Future Enhancements

Planned enhancements for the admin dashboard include:

1. Advanced analytics and reporting
2. Staff performance metrics
3. Attendance anomaly detection
4. Mobile-responsive design for admin access on the go
5. Integration with notification systems for attendance alerts
