# Staff Rating API Documentation

This document outlines the API endpoints for the Staff Rating feature.

## Authentication

All API endpoints require authentication using Laravel Sanctum. Include the authentication token in the request header:

```
Authorization: Bearer {token}
```

## Member Staff Rating Endpoints

### Get All Ratings for Authenticated User

Retrieves all ratings submitted by the authenticated user.

**URL:** `/api/staff/ratings`

**Method:** `GET`

**Query Parameters:**
- `staff_type` (optional): Filter by staff type (`society` or `member`)
- `rating` (optional): Filter by rating value (1-5)
- `page` (optional): Page number for pagination

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "member_id": 101,
      "member_name": "John Doe",
      "staff_id": 201,
      "staff_type": "member",
      "staff_name": "Jane Smith",
      "rating": 4,
      "feedback": "Great service!",
      "created_at": "2023-06-15 10:30:45",
      "updated_at": "2023-06-15 10:30:45"
    },
    ...
  ],
  "links": {
    "first": "http://example.com/api/staff/ratings?page=1",
    "last": "http://example.com/api/staff/ratings?page=1",
    "prev": null,
    "next": null
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 1,
    "path": "http://example.com/api/staff/ratings",
    "per_page": 10,
    "to": 1,
    "total": 1
  }
}
```

### Create a New Rating

Creates a new rating for a staff member.

**URL:** `/api/staff/ratings`

**Method:** `POST`

**Request Body:**
```json
{
  "staff_id": 201,
  "staff_type": "member",
  "rating": 4,
  "feedback": "Great service!"
}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "member_id": 101,
    "member_name": "John Doe",
    "staff_id": 201,
    "staff_type": "member",
    "staff_name": "Jane Smith",
    "rating": 4,
    "feedback": "Great service!",
    "created_at": "2023-06-15 10:30:45",
    "updated_at": "2023-06-15 10:30:45"
  }
}
```

### Get a Specific Rating

Retrieves a specific rating by ID.

**URL:** `/api/staff/ratings/{rating}`

**Method:** `GET`

**Response:**
```json
{
  "data": {
    "id": 1,
    "member_id": 101,
    "member_name": "John Doe",
    "staff_id": 201,
    "staff_type": "member",
    "staff_name": "Jane Smith",
    "rating": 4,
    "feedback": "Great service!",
    "created_at": "2023-06-15 10:30:45",
    "updated_at": "2023-06-15 10:30:45"
  }
}
```

### Update a Rating

Updates an existing rating.

**URL:** `/api/staff/ratings/{rating}`

**Method:** `PUT`

**Request Body:**
```json
{
  "rating": 5,
  "feedback": "Excellent service!"
}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "member_id": 101,
    "member_name": "John Doe",
    "staff_id": 201,
    "staff_type": "member",
    "staff_name": "Jane Smith",
    "rating": 5,
    "feedback": "Excellent service!",
    "created_at": "2023-06-15 10:30:45",
    "updated_at": "2023-06-15 11:15:20"
  }
}
```

### Delete a Rating

Deletes a rating.

**URL:** `/api/staff/ratings/{rating}`

**Method:** `DELETE`

**Response:**
```json
{
  "message": "Rating deleted successfully."
}
```

## Admin Staff Rating Endpoints

### Get All Staff Ratings (Admin)

Retrieves aggregated ratings for all staff members.

**URL:** `/api/admin/staff/ratings`

**Method:** `GET`

**Query Parameters:**
- `staff_type` (optional): Filter by staff type (`society` or `member`)
- `min_rating` (optional): Filter by minimum average rating
- `max_rating` (optional): Filter by maximum average rating
- `search` (optional): Search by staff name

**Response:**
```json
{
  "total": 2,
  "ratings": [
    {
      "staff_id": 201,
      "staff_type": "member",
      "staff_name": "Jane Smith",
      "staff_category": "Maid",
      "staff_photo_url": "https://example.com/photos/jane.jpg",
      "average_rating": 4.5,
      "total_ratings": 12
    },
    {
      "staff_id": 202,
      "staff_type": "society",
      "staff_name": "Bob Johnson",
      "staff_category": "Security",
      "staff_photo_url": "https://example.com/photos/bob.jpg",
      "average_rating": 4.2,
      "total_ratings": 8
    }
  ]
}
```

### Get Detailed Staff Rating (Admin)

Retrieves detailed rating information for a specific staff member.

**URL:** `/api/admin/staff/{staffId}/ratings`

**Method:** `GET`

**Query Parameters:**
- `staff_type` (required): Staff type (`society` or `member`)

**Response:**
```json
{
  "staff_id": 201,
  "staff_type": "member",
  "staff_name": "Jane Smith",
  "staff_category": "Maid",
  "staff_photo_url": "https://example.com/photos/jane.jpg",
  "average_rating": 4.5,
  "total_ratings": 12,
  "rating_distribution": {
    "1": 0,
    "2": 1,
    "3": 2,
    "4": 3,
    "5": 6
  },
  "recent_reviews": [
    {
      "id": 1,
      "rating": 5,
      "feedback": "Excellent service!",
      "member_name": "John Doe",
      "created_at": "2023-06-15 11:15:20"
    },
    ...
  ]
}
```

### Export Staff Ratings (Admin)

Exports staff ratings as a CSV file.

**URL:** `/api/admin/staff/ratings/export`

**Method:** `GET`

**Query Parameters:**
- `staff_type` (optional): Filter by staff type (`society` or `member`)
- `min_rating` (optional): Filter by minimum rating
- `max_rating` (optional): Filter by maximum rating
- `search` (optional): Search by staff name

**Response:**
CSV file download with the following columns:
- ID
- Member ID
- Member Name
- Staff ID
- Staff Type
- Staff Name
- Rating
- Feedback
- Created At

## Error Responses

### Unauthorized

```json
{
  "error": "Unauthorized. You do not have permission to access this resource."
}
```

### Not Found

```json
{
  "error": "Staff not found."
}
```

### Validation Error

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "rating": [
      "The rating field is required."
    ],
    "staff_id": [
      "You have already rated this staff this month. You can only rate a staff once per month."
    ]
  }
}
```
