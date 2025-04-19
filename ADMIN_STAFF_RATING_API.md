# Admin Staff Rating API Documentation

This document outlines the API endpoints for the Admin Staff Rating feature in the Member Staff Flutter application. These endpoints allow administrators to view and export aggregated staff ratings data.

## Overview

The Admin Staff Rating API provides administrators with tools to:

1. View aggregated ratings for all staff members (both society staff and member staff)
2. Export staff ratings data as a CSV file for reporting and analysis

## Authentication and Authorization

### Authentication

All API endpoints require authentication using Laravel Sanctum. Include the authentication token in the request header:

```
Authorization: Bearer {token}
```

To obtain a token, use the login endpoint (not covered in this documentation).

### Authorization

Only users with the 'admin' role can access these endpoints. The system uses middleware to enforce this restriction. If a non-admin user attempts to access these endpoints, they will receive a 403 Forbidden response.

## API Endpoints

### 1. Get All Staff Ratings

Retrieves aggregated ratings for all staff members, including average rating and total number of ratings for each staff member.

**URL:** `/api/admin/staff/ratings`

**Method:** `GET`

**Query Parameters:**
None required, but future implementations may support filtering and pagination.

**Success Response:**

- **Code:** 200 OK
- **Content:**

```json
[
  {
    "staff_id": 1002,
    "staff_type": "member",
    "average_rating": 4.5,
    "total_ratings": 12
  },
  {
    "staff_id": 1003,
    "staff_type": "society",
    "average_rating": 4.2,
    "total_ratings": 8
  },
  ...
]
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| staff_id | integer | Unique identifier for the staff member |
| staff_type | string | Type of staff ("member" or "society") |
| average_rating | float | Average rating value (1-5) |
| total_ratings | integer | Total number of ratings received |

### 2. Export Staff Ratings as CSV

Exports staff ratings data as a CSV file for reporting and analysis purposes.

**URL:** `/api/admin/staff/ratings/export`

**Method:** `GET`

**Query Parameters:**
None required, but future implementations may support filtering options.

**Success Response:**

- **Code:** 200 OK
- **Content-Type:** text/csv
- **Content-Disposition:** attachment; filename="staff_ratings_report.csv"

**CSV Format:**
The CSV file contains the following columns:

| Column | Description |
|--------|-------------|
| Staff ID | Unique identifier for the staff member |
| Staff Type | Type of staff ("member" or "society") |
| Average Rating | Average rating value (1-5), formatted to 2 decimal places |
| Total Ratings | Total number of ratings received |

## Error Responses

### 1. Unauthorized (401)

Returned when the request does not include a valid authentication token.

```json
{
  "message": "Unauthenticated."
}
```

### 2. Forbidden (403)

Returned when the authenticated user does not have admin privileges.

```json
{
  "error": "Unauthorized. Admin access required."
}
```

### 3. Server Error (500)

Returned when there is an internal server error.

```json
{
  "message": "Server Error"
}
```

## Implementation Notes

### Database Structure

The API uses the `staff_ratings` table with the following structure:

```
staff_ratings
├── id (primary key)
├── member_id (foreign key to members table)
├── staff_id
├── staff_type (enum: 'society', 'member')
├── rating (integer: 1-5)
├── feedback (text, nullable)
├── created_at
└── updated_at
```

### Aggregation Logic

The ratings are aggregated using SQL functions:
- `AVG(rating)` for average_rating
- `COUNT(*)` for total_ratings

## Testing

### Automated Tests

You can run the automated tests for these endpoints using the provided feature tests:

```bash
php artisan test --filter=AdminStaffRatingControllerTest
```

### Manual Testing with Postman

A Postman collection is provided in the `postman/Admin_Staff_Rating_API.postman_collection.json` file. Import this collection into Postman to test the API endpoints manually.

## Future Enhancements

Planned enhancements for future versions:

1. Filtering options (by staff type, rating range, date range)
2. Pagination for large datasets
3. Detailed staff information in the response
4. Trend analysis (ratings over time)
5. Additional export formats (Excel, PDF)

## Support

For any issues or questions regarding the Admin Staff Rating API, please contact the development team.
