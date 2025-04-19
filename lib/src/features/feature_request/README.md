# Feature Request Module

This module allows users to request new features for the application. Users can search for existing feature requests, upvote them, or create new feature requests.

## Features

- Search for existing feature requests
- Auto-suggest existing features as you type
- Upvote existing feature requests
- Create new feature requests with title and description
- View all feature requests with vote counts

## Architecture

The Feature Request module follows a clean architecture approach with the following components:

### Models

- `FeatureRequest`: Represents a feature request with title, description, and vote count

### API

- `FeatureRequestApi`: Handles communication with the backend API for feature requests

### Providers

- `FeatureRequestProvider`: Manages the state of feature requests and provides methods for interacting with them

### Screens

- `RequestFeatureScreen`: Main screen for searching, viewing, and creating feature requests

### Widgets

- `FeatureRequestItem`: Displays a single feature request with vote count and upvote button
- `FeatureRequestForm`: Form for creating a new feature request

## Backend Integration

The module integrates with a Laravel backend API with the following endpoints:

- `GET /api/feature-requests`: List all feature requests
- `GET /api/feature-requests/suggest?q={query}`: Get suggestions based on search query
- `POST /api/feature-requests`: Create a new feature request
- `POST /api/feature-requests/{id}/vote`: Upvote an existing feature request

## Database Schema

The backend uses a MySQL database with the following schema:

```sql
CREATE TABLE feature_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    feature_title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    votes INT DEFAULT 1,
    created_by BIGINT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX (feature_title)
);
```

## Usage

To use the Feature Request module, add it to your routes:

```dart
routes: {
  '/feature-request': (context) => const FeatureRequestModule(
        baseUrl: 'https://api.example.com/api',
      ),
}
```

Then navigate to it using:

```dart
Navigator.pushNamed(context, '/feature-request');
```

## Screenshots

![Feature Request Screen](../../assets/images/feature_request_screen.png)
![Feature Request Form](../../assets/images/feature_request_form.png)
