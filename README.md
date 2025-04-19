# Member Staff Flutter Application

A comprehensive Flutter application for managing society members, staff information, bookings, attendance tracking, and financial reporting efficiently.

## Overview
This application provides a complete solution for society management, including:
- Member registration and management
- Society Staff and Member Staff management
- Staff booking and scheduling with hourly time slots
- Staff attendance tracking with photo verification
- Staff rating system with feedback
- Committee-only financial reporting with the All Dues Report feature
- User authentication and authorization with role-based access control
- Real-time monitoring through Admin Dashboard
- Dynamic content management through Strapi CMS integration
- Multi-language support with localization

## Project Structure

```
Member_Staff_Flutter/
├── lib/                          # Flutter application code
│   ├── main.dart                 # Entry point of the application
│   ├── cms/                      # CMS integration module
│   │   ├── config/               # CMS configuration
│   │   ├── models/               # CMS data models
│   │   ├── providers/            # CMS state management
│   │   ├── screens/              # CMS UI screens
│   │   ├── services/             # CMS services
│   │   ├── widgets/              # CMS UI components
│   │   ├── localization/         # Localization support
│   │   └── schema/               # CMS schema definitions
│   ├── models/                   # Data models
│   │   ├── dues_chart_model.dart # Chart data models for All Dues Report
│   │   ├── dues_report_model.dart# Dues report data models
│   │   └── user_model.dart       # User authentication models
│   ├── screens/                  # UI screens
│   │   ├── all_dues_report_screen.dart # All Dues Report screen
│   │   ├── cms_home_screen.dart  # CMS-based home screen
│   │   ├── cms_about_screen.dart # CMS-based about screen
│   │   ├── cms_faq_screen.dart   # CMS-based FAQ screen
│   │   └── cms_notification_screen.dart # CMS-based notification screen
│   ├── services/                 # API and other services
│   │   └── api_service.dart      # API communication service
│   ├── utils/                    # Utility functions and constants
│   │   ├── constants.dart        # Application constants
│   │   └── snackbar_helper.dart  # UI notification helpers
│   ├── widgets/                  # Reusable widgets
│   │   ├── custom_app_bar.dart   # Custom app bar widget
│   │   ├── custom_drawer.dart    # Navigation drawer widget
│   │   └── dues_chart_widget.dart# Chart visualization widget
│   └── src/                      # Core application code
│       ├── app.dart              # Main application widget
│       ├── cms_app.dart          # CMS-based application widget
│       ├── features/             # Feature modules
│       │   ├── member_staff/     # Member Staff feature module
│       │   │   ├── api/          # API clients for Member Staff
│       │   │   ├── models/       # Data models for Member Staff
│       │   │   ├── screens/      # UI screens for Member Staff
│       │   │   ├── services/     # Services for Member Staff
│       │   │   └── widgets/      # Widgets for Member Staff
│       │   ├── feature_request/  # Feature Request module
│       │   │   ├── api/          # API clients for Feature Request
│       │   │   ├── models/       # Data models for Feature Request
│       │   │   ├── screens/      # UI screens for Feature Request
│       │   │   ├── providers/    # State management for Feature Request
│       │   │   └── widgets/      # Widgets for Feature Request
│       │   └── chat_service/     # Chat Service module
│       │       ├── api/          # API clients for Chat Service
│       │       ├── models/       # Data models for Chat Service
│       │       ├── pages/        # UI screens for Chat Service
│       │       ├── providers/    # State management for Chat Service
│       │       ├── utils/        # Utility functions for Chat Service
│       │       └── widgets/      # Widgets for Chat Service
│       └── core/                 # Core functionality
│           ├── auth/             # Authentication
│           ├── models/           # Core data models
│           └── services/         # Core services
├── test/                         # Unit and widget tests
│   ├── features/                 # Feature-specific tests
│   │   ├── committee/            # Committee feature tests
│   │   │   └── all_dues_report_test.dart # Tests for All Dues Report
│   │   └── member_staff/         # Member Staff feature tests
│   │       ├── staff_attendance_test.dart # Tests for attendance
│   │       └── staff_rating_test.dart # Tests for rating system
│   └── models/                   # Model tests
├── backend-api/                  # Laravel backend API
│   ├── app/                      # Laravel application code
│   │   ├── Http/                 # HTTP layer
│   │   │   ├── Controllers/      # API controllers
│   │   │   ├── Middleware/       # Request middleware
│   │   │   └── Requests/         # Form requests
│   │   └── Models/               # Database models
│   ├── routes/                   # API routes
│   └── tests/                    # Laravel tests
├── admin-dashboard/              # Admin dashboard (Next.js)
├── docs/                         # Project documentation
├── pubspec.yaml                  # Flutter dependencies
└── analysis_options.yaml         # Dart analyzer configuration
```

## Features

### Chat Service
- **Peer-to-Peer Messaging**: Direct messaging between users
- **Group Chat Rooms**: Create and join group chat rooms
- **Public Discussion Rooms**: Open chat rooms for all users
- **Committee Chat Rooms**: Special rooms for committee members with voting capabilities
- **Real-time Messaging**: Instant message delivery with typing indicators
- **Voting System**: Create polls, vote on options, and view results in committee rooms
- **Member Search**: Search and invite specific members to chat rooms
- **Secure Authentication**: Integration with OneSSO (Keycloak) for secure access
- **Offline Support**: Message caching for offline viewing

### Feature Request System
- **Request New Features**: Users can request new features for the application
- **Search Existing Requests**: Search for existing feature requests with auto-suggestions
- **Upvote System**: Upvote existing feature requests to show interest
- **Request Tracking**: Track the status and popularity of feature requests
- **Admin Dashboard**: View and manage feature requests through the admin interface

### Member Staff Module
- **Member Management**: Add, edit, view, and delete member information
- **Society Staff Management**: Manage society-employed staff with profiles and schedules
- **Member Staff Management**: Manage staff employed by individual members with verification flow
- **Staff Verification Flow**: Mobile number verification, OTP, and identity capture (photo, Aadhaar, address)
- **Staff Booking System**:
  - Book staff services with hourly time slots (60-minute slots)
  - Calendar view with busy/available indicators
  - Booking details selection and confirmation UI
  - Reschedule and cancel functionality

### Attendance Tracking
- **Member Staff Attendance**: Mark attendance with photo proof upload
- **Attendance Calendar**: Calendar view for staff schedules and attendance history
- **Real-time Updates**: Instant notifications for schedule changes
- **Admin Attendance Dashboard**: View and manage attendance records with image proof preview

### Staff Rating System
- **Rating Interface**: Rate society staff and member staff with 1-5 star ratings
- **Feedback System**: Provide text feedback along with ratings
- **Monthly Restrictions**: Limit to one rating per staff member per month
- **Rating Summary**: View aggregated ratings and feedback
- **Admin Rating Dashboard**: View and analyze staff performance based on ratings

### All Dues Report (Committee Users Only)
- **Financial Overview**: View all members' current dues, unpaid bills, and payment history
- **Advanced Filtering**: Filter by building, wing, floor, overdue status, due month, and amount range
- **Data Visualization**: Bar and pie charts showing dues by wing, floor, and top members
- **Infinite Scroll Pagination**: Browse large datasets with filter context preservation
- **Export Functionality**: Export filtered data as CSV

### Admin Dashboard
- **Real-time Monitoring**: Monitor staff attendance and ratings with WebSockets integration
- **Data Analytics**: View trends and statistics on staff performance
- **User Management**: Manage user roles and permissions
- **Notification Center**: Send and manage notifications to users

### Strapi CMS Integration
- **Dynamic Content Management**: Manage content through a headless CMS without code changes
- **Content Types**: Pre-defined content types for pages, features, settings, notifications, and FAQs
- **CMS Console**: Built-in console for managing content directly from the app
- **Offline Support**: Caching of CMS content for offline use
- **Authentication Integration**: Secure access to CMS content with token-based authentication
- **Multi-language Support**: Content localization with language switching

### Security and Integration
- **Authentication**: Secure login with OneSSO (Keycloak) integration
- **Role-based Access Control**: Different features for members, staff, and committee users
- **OneApp Integration**: Seamless integration with parent OneApp using Keycloak tokens
- **Token Validation**: Comprehensive token validation with issuer and audience verification
- **Automatic Token Refresh**: Transparent token refresh mechanism for uninterrupted user experience
- **Secure API Communication**: Encrypted data transfer between app and backend

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- An IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository
   ```
   git clone https://github.com/rabinderFuturescape/Member_Staff_Flutter.git
   ```

2. Navigate to the project directory
   ```
   cd Member_Staff_Flutter
   ```

3. Install dependencies
   ```
   flutter pub get
   ```

4. Configure OneSSO integration
   - Update Keycloak settings in `lib/utils/constants.dart`
   - Configure backend environment variables in `.env` file:
   ```
   KEYCLOAK_BASE_URL=https://sso.oneapp.in
   KEYCLOAK_REALM=oneapp
   KEYCLOAK_CLIENT_ID=member-staff-api
   KEYCLOAK_PUBLIC_KEY=your_public_key_here
   ```

5. Set up Strapi CMS (optional)
   - Install Strapi globally:
   ```
   npm install -g strapi
   ```
   - Create a new Strapi project:
   ```
   npx create-strapi-app@latest my-project
   ```
   - Start the Strapi server:
   ```
   cd my-project
   npm run develop
   ```
   - Configure the CMS in `lib/cms/config/cms_config.dart`:
   ```dart
   static const String baseUrl = 'http://your-strapi-url:1337';
   static const String apiToken = 'your-strapi-api-token';
   ```

6. Run the app
   ```
   flutter run
   ```

## Development

This project follows clean architecture principles and is organized into layers:

- **Presentation Layer**: UI components (screens, widgets)
- **Domain Layer**: Business logic and models
- **Data Layer**: API services and repositories

## Backend API

The application connects to a Laravel backend API that provides comprehensive functionality for all features:

### API Architecture
- **RESTful Design**: Well-structured API endpoints following REST principles
- **OneSSO Authentication**: Secure authentication using Keycloak identity provider
- **JWT Validation**: Comprehensive token validation with signature, issuer, and audience checks
- **Role-based Middleware**: Ensures proper access control for different user types
- **MySQL Database**: Robust data storage with optimized queries
- **WebSockets**: Real-time updates using Laravel Echo Server

### Key API Endpoints

#### Member Staff Management
- `GET /api/members` - List all members
- `GET /api/staff` - List all staff
- `POST /api/member-staff/verify` - Verify member staff identity
- `POST /api/member-staff/otp/verify` - Verify OTP during staff registration

#### Staff Booking
- `GET /api/member-staff/bookings` - List all bookings
- `POST /api/member-staff/bookings` - Create a new booking
- `PUT /api/member-staff/bookings/{id}` - Update/reschedule a booking
- `DELETE /api/member-staff/bookings/{id}` - Cancel a booking

#### Attendance Tracking
- `GET /api/member-staff/attendance` - Get attendance records
- `POST /api/member-staff/attendance` - Mark attendance with photo
- `GET /api/admin/attendance` - Admin view of all attendance records

#### Staff Rating
- `GET /api/staff/ratings` - Get ratings for a staff member
- `POST /api/staff/ratings` - Submit a new rating
- `GET /api/admin/staff/ratings` - Get aggregated staff ratings for admin

#### All Dues Report
- `GET /api/committee/dues-report` - Get dues report with filtering options
- `GET /api/committee/dues-report/export` - Export dues report as CSV
- `GET /api/committee/dues-report/chart-summary` - Get chart data for visualization

#### Chat Service
- `GET /api/chat/rooms` - List all chat rooms for the current user
- `POST /api/chat/rooms` - Create a new chat room
- `GET /api/chat/rooms/{id}` - Get details of a specific chat room
- `GET /api/chat/rooms/{id}/messages` - Get messages for a chat room
- `POST /api/chat/rooms/{id}/messages` - Send a message to a chat room
- `POST /api/chat/rooms/{id}/join` - Join a public chat room
- `DELETE /api/chat/rooms/{id}/leave` - Leave a chat room
- `GET /api/chat/users/search` - Search for users to invite to a chat room
- `POST /api/chat/rooms/{id}/polls` - Create a new poll in a committee room
- `GET /api/chat/rooms/{id}/polls` - Get all polls for a committee room
- `POST /api/chat/polls/{id}/vote` - Vote on a poll option
- `PATCH /api/chat/polls/{id}/close` - Close a poll (committee members only)

### API Documentation
Detailed API documentation is available in the following OpenAPI specification files:
- `member_staff_booking_api_spec.yaml` - Booking API endpoints
- `member_staff_attendance_api_spec.yaml` - Attendance API endpoints
- `admin_attendance_api_spec.yaml` - Admin dashboard API endpoints
- `staff_rating_api_spec.yaml` - Staff rating API endpoints
- `committee_dues_report_api_spec.yaml` - All Dues Report API endpoints

## Testing

The project includes comprehensive test coverage for both frontend and backend components:

### Flutter Tests
- **Widget Tests**: Test UI components and interactions
- **Unit Tests**: Test business logic and data models
- **Integration Tests**: Test API service integration

Run Flutter tests with:
```
flutter test
```

### Laravel Tests
- **Feature Tests**: Test API endpoints and controllers
- **Unit Tests**: Test individual components and services
- **Authorization Tests**: Test role-based access control

Run Laravel tests with:
```
php artisan test
```

## Documentation

Detailed documentation for each feature is available in the following files:

- **Member Staff Module**: [MEMBER_STAFF_IMPLEMENTATION_GUIDE.md](MEMBER_STAFF_IMPLEMENTATION_GUIDE.md)
- **Staff Booking System**: [member_staff_booking_api_spec.yaml](member_staff_booking_api_spec.yaml)
- **Attendance Tracking**: [MODELS_DOCUMENTATION.md](MODELS_DOCUMENTATION.md)
- **Staff Rating System**: [ADMIN_STAFF_RATING_API.md](ADMIN_STAFF_RATING_API.md)
- **All Dues Report**: [README_ALL_DUES_REPORT.md](README_ALL_DUES_REPORT.md)
- **Chat Service**: [README_CHAT_SERVICE.md](README_CHAT_SERVICE.md)
- **Strapi CMS Integration**: [README_STRAPI_CMS.md](README_STRAPI_CMS.md)
- **CMS Localization**: [lib/cms/localization/README.md](lib/cms/localization/README.md)
- **Feature Request Module**: [lib/src/features/feature_request/README.md](lib/src/features/feature_request/README.md)
- **API Documentation**: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **Integration Guide**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
- **Test Cases**: [TEST_CASES.md](TEST_CASES.md)

## Contributors

- Rabinder Futurescape

## License

This project is licensed under the terms found in the [license.lic](license.lic) file.
