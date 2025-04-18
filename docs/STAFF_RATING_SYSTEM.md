# Staff Rating System

This document provides a comprehensive overview of the Staff Rating System implemented in the Member Staff module.

## Overview

The Staff Rating System allows members to provide ratings and feedback for:
- Society Staff (e.g., Security, Housekeeping, Office Staff)
- Member Staff (e.g., Maid, Driver, Electrician) assigned to their unit

Ratings are stored and visible in the admin dashboard, and can be optionally shared with staff or kept internal.

## Features

- **1-5 Star Rating Scale**: Members can rate staff on a scale of 1 to 5 stars
- **Feedback Text**: Optional feedback text can be provided with ratings
- **Monthly Restriction**: Members can rate each staff member only once per month
- **Rating Summaries**: Average ratings, total ratings, and rating distribution
- **Recent Reviews**: Display of recent reviews with member names
- **Admin Dashboard**: Comprehensive dashboard for monitoring ratings
- **Filtering and Search**: Filter ratings by staff type, rating value, and search by member name
- **CSV Export**: Export ratings data as CSV for further analysis

## Database Schema

The staff rating system uses the following database table:

### staff_ratings

| Column | Type | Description |
|--------|------|-------------|
| id | BIGINT | Primary Key |
| member_id | BIGINT | Who rated |
| staff_id | BIGINT | Staff being rated |
| staff_type | ENUM | 'society' or 'member' |
| rating | INT | 1 to 5 |
| feedback | TEXT | Optional comment |
| created_at | TIMESTAMP | Auto |
| updated_at | TIMESTAMP | Auto |

## API Endpoints

### Submit Rating

**Endpoint**: `POST /api/staff/rating`

**Authorization**: Bearer Token

**Payload**:
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

**Endpoint**: `GET /api/staff/{staff_id}/ratings`

**Query Parameters**:
- `staff_type`: The type of staff ("society" or "member") (required)

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

**Endpoint**: `GET /api/admin/staff/ratings`

**Query Parameters**:
- `staff_type`: Filter by staff type ("society" or "member") (optional)
- `min_rating`: Minimum rating value (1-5) (optional)
- `max_rating`: Maximum rating value (1-5) (optional)
- `page`: Page number (default: 1) (optional)
- `limit`: Number of ratings per page (default: 10) (optional)

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

**Endpoint**: `GET /api/admin/staff/ratings/export`

**Query Parameters**:
- `staff_type`: Filter by staff type ("society" or "member") (optional)
- `min_rating`: Minimum rating value (1-5) (optional)
- `max_rating`: Maximum rating value (1-5) (optional)

**Response**: CSV file

## UI Components

### StaffRatingDialog

A dialog for submitting ratings with the following features:
- Staff profile display
- 5-star rating selection
- Feedback text input
- Submit and cancel buttons
- Error handling and loading states

### StaffRatingSummary

A widget for displaying rating summaries with the following features:
- Average rating display
- Total ratings count
- Rating distribution visualization
- Recent reviews display

### StaffProfileScreen

A screen that displays staff details and includes rating functionality:
- Staff profile information
- Rating summary
- "Rate Staff" button that opens the rating dialog

### Admin Dashboard

A comprehensive dashboard for monitoring ratings with the following features:
- Filtering by staff type, rating value
- Search by member name
- Pagination
- CSV export
- Summary statistics (total ratings, average rating, low ratings)

## Integration

To integrate the Staff Rating System into your application:

1. Include the required dependencies in your `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_rating_bar: ^4.0.1
   ```

2. Register the necessary providers:
   ```dart
   Provider<StaffRatingApi>(
     create: (context) => StaffRatingApi(
       apiClient: Provider.of<ApiClient>(context, listen: false),
       authService: Provider.of<AuthService>(context, listen: false),
     ),
   ),
   ChangeNotifierProvider<StaffRatingProvider>(
     create: (context) => StaffRatingProvider(
       api: Provider.of<StaffRatingApi>(context, listen: false),
     ),
   ),
   ```

3. Add the rating functionality to your staff profile screen:
   ```dart
   StaffRatingSummary(
     staffId: staff.id,
     staffType: staffType,
     onRatePressed: () => showDialog(
       context: context,
       builder: (context) => StaffRatingDialog(
         staff: staff,
         staffType: staffType,
       ),
     ),
   ),
   ```

4. Add the admin dashboard to your admin navigation:
   ```dart
   ListTile(
     leading: Icon(Icons.star),
     title: Text('Staff Ratings'),
     onTap: () => Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => StaffRatingsDashboard(),
       ),
     ),
   ),
   ```

## Validation Rules

- Only members assigned to that staff can rate member staff
- Society staff can be rated by any member
- 1 rating per staff per member per month
- Admin can view all ratings (for analytics)

## Testing

The Staff Rating System includes comprehensive tests:

- **Unit Tests**: Test the rating models, providers, and API clients
- **Widget Tests**: Test the rating dialog and summary widgets
- **Integration Tests**: Test the end-to-end rating flow
- **API Tests**: Test the rating API endpoints

Run the tests with:
```bash
flutter test test/features/member_staff/staff_rating_test.dart
```

For API tests:
```bash
php artisan test tests/Feature/StaffRatingTest.php
```
