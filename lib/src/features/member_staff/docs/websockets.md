# WebSockets Implementation for Real-time Updates

## Overview

This document describes the WebSockets implementation used for real-time updates in the Member Staff module, particularly for the Admin Dashboard's attendance monitoring features.

## Architecture

The WebSockets implementation follows a publisher-subscriber pattern:

1. **Publisher**: Laravel backend broadcasts events when attendance records are updated
2. **Broker**: Laravel Echo Server with Redis handles message distribution
3. **Subscriber**: Next.js frontend listens for events and updates the UI accordingly

## Technologies Used

### Backend

- **Laravel Broadcasting**: Framework for broadcasting events
- **Laravel Echo Server**: WebSockets server implementation
- **Redis**: Message queue for WebSockets
- **Pusher**: Protocol implementation (server-side)

### Frontend

- **Laravel Echo**: Client library for connecting to Laravel Echo Server
- **Pusher.js**: Protocol implementation (client-side)

## Implementation Details

### Backend Event Broadcasting

When an attendance record is updated, the backend broadcasts an `AttendanceUpdated` event:

```php
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
            'staff_category' => $attendance->staff->category ?? 'Staff',
            'staff_photo' => $attendance->staff->photo_url ?? null,
            'status' => $attendance->status,
            'note' => $attendance->note,
            'photo_url' => $attendance->photo_url,
            'date' => $attendance->date->format('Y-m-d'),
            'updated_at' => $attendance->updated_at->toIso8601String()
        ];
    }

    public function broadcastOn()
    {
        return new Channel('attendance');
    }

    public function broadcastAs()
    {
        return 'attendance.updated';
    }
}
```

The event is triggered in the `AdminAttendanceController`:

```php
public function update(Request $request)
{
    // Update attendance record
    $attendance = MemberStaffAttendance::findOrFail($request->input('attendance_id'));
    $attendance->status = $request->input('status');
    $attendance->save();

    // Broadcast the update
    event(new AttendanceUpdated($attendance));

    return response()->json(['status' => 'success']);
}
```

### Frontend Event Listening

The frontend uses Laravel Echo to listen for events:

```javascript
// Initialize Echo
const echo = new Echo({
  broadcaster: 'pusher',
  key: process.env.NEXT_PUBLIC_PUSHER_APP_KEY,
  wsHost: process.env.NEXT_PUBLIC_WEBSOCKET_HOST,
  wsPort: process.env.NEXT_PUBLIC_WEBSOCKET_PORT,
  forceTLS: false,
  disableStats: true,
});

// Subscribe to the attendance channel
echo.channel('attendance')
  .listen('.attendance.updated', (data) => {
    // Update UI with new data
    updateAttendanceRecord(data);
  });
```

## Configuration

### Laravel Echo Server Configuration

The Laravel Echo Server is configured in `laravel-echo-server.json`:

```json
{
  "authHost": "http://localhost:8000",
  "authEndpoint": "/broadcasting/auth",
  "clients": [
    {
      "appId": "member_staff_app",
      "key": "member_staff_app_key"
    }
  ],
  "database": "redis",
  "databaseConfig": {
    "redis": {
      "host": "localhost",
      "port": "6379"
    }
  },
  "devMode": true,
  "host": null,
  "port": "6001",
  "protocol": "http",
  "socketio": {},
  "secureOptions": 67108864,
  "sslCertPath": "",
  "sslKeyPath": "",
  "sslCertChainPath": "",
  "sslPassphrase": "",
  "subscribers": {
    "http": true,
    "redis": true
  },
  "apiOriginAllow": {
    "allowCors": true,
    "allowOrigin": "*",
    "allowMethods": "GET, POST",
    "allowHeaders": "Origin, Content-Type, X-Auth-Token, X-Requested-With, Accept, Authorization, X-CSRF-TOKEN, X-Socket-Id"
  }
}
```

### Laravel Broadcasting Configuration

Laravel broadcasting is configured in `config/broadcasting.php`:

```php
'pusher' => [
    'driver' => 'pusher',
    'key' => env('PUSHER_APP_KEY', 'member_staff_app_key'),
    'secret' => env('PUSHER_APP_SECRET', 'member_staff_app_secret'),
    'app_id' => env('PUSHER_APP_ID', 'member_staff_app'),
    'options' => [
        'cluster' => env('PUSHER_APP_CLUSTER', 'ap2'),
        'useTLS' => true,
        'host' => env('PUSHER_HOST', '127.0.0.1'),
        'port' => env('PUSHER_PORT', 6001),
        'scheme' => env('PUSHER_SCHEME', 'https'),
    ],
],
```

## Testing

The WebSockets implementation includes tests for both the backend and frontend:

### Backend Tests

- `AttendanceUpdatedEventTest`: Tests that the event contains the correct data and broadcasts on the right channel

### Frontend Tests

- `echo.test.js`: Tests the WebSockets client integration, including initialization, subscription, and event handling

## Performance Considerations

- WebSockets connections are only established when viewing the real-time dashboard
- Events are filtered by date on the client side to reduce unnecessary updates
- The server only broadcasts minimal data needed for updates
- Redis is used for efficient message distribution in high-load scenarios

## Security Considerations

- All WebSockets connections require authentication
- Admin-only routes are protected by middleware
- CORS is configured to allow only specific origins
- TLS can be enabled for production environments
