# Strapi CMS Integration for Member Staff App

This document provides instructions for setting up and using the Strapi CMS integration with the Member Staff Flutter application.

## Table of Contents

- [Overview](#overview)
- [Setup Instructions](#setup-instructions)
- [Content Types](#content-types)
- [API Reference](#api-reference)
- [Frontend Integration](#frontend-integration)
- [Development Workflow](#development-workflow)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## Overview

The Strapi CMS integration allows for managing content through a headless CMS, providing a flexible and dynamic way to update the application's content without requiring code changes. This integration uses the Strapi SDK to communicate with the Strapi CMS API.

### Features

- **Dynamic Content**: Manage pages, features, notifications, and FAQs through the CMS
- **Content Types**: Pre-defined content types for common use cases
- **CMS Console**: Built-in console for managing content
- **Responsive UI**: UI components that adapt to different screen sizes
- **Offline Support**: Caching of CMS content for offline use
- **Localization**: Support for multiple languages

## Setup Instructions

### 1. Install Strapi CMS

1. Install Node.js (v14 or later) and npm
2. Install Strapi globally:
   ```bash
   npm install -g strapi
   ```
3. Create a new Strapi project:
   ```bash
   npx create-strapi-app@latest my-project
   ```
4. Start the Strapi server:
   ```bash
   cd my-project
   npm run develop
   ```
5. Access the Strapi admin panel at http://localhost:1337/admin

### 2. Create Content Types

1. In the Strapi admin panel, go to Content-Type Builder
2. Create the following content types:
   - Pages
   - Features
   - Settings
   - Staff Members
   - Members
   - Notifications
   - FAQs

You can use the schema defined in `lib/cms/schema/strapi_schema.json` as a reference for creating these content types.

### 3. Generate API Token

1. In the Strapi admin panel, go to Settings > API Tokens
2. Create a new API token with the following permissions:
   - Read access to all content types
   - Write access to Notifications (for marking as read)

### 4. Configure the Flutter App

1. Update the CMS configuration in `lib/cms/config/cms_config.dart`:
   ```dart
   static const String baseUrl = 'http://your-strapi-url:1337';
   static const String apiToken = 'your-strapi-api-token';
   ```

2. Add the required dependencies to `pubspec.yaml`:
   ```yaml
   dependencies:
     strapi_sdk: ^1.0.0
     cached_network_image: ^3.3.0
     html_unescape: ^2.0.0
     flutter_html: ^3.0.0-beta.2
     flutter_markdown: ^0.6.18
   ```

3. Run `flutter pub get` to install the dependencies

### 5. Seed Initial Content

1. Use the seed data in `lib/cms/schema/strapi_seed_data.json` to create initial content in Strapi
2. You can import this data using the Strapi Import Export plugin or manually create the content

## Content Types

### Pages

Pages are used for static content like About, Terms, Privacy Policy, etc.

**Fields:**
- Title (string, required)
- Slug (uid, required)
- Content (richtext, required)
- Meta Title (string)
- Meta Description (text)
- Featured Image (media)
- Is Published (boolean)

### Features

Features are used for displaying feature cards on the home screen.

**Fields:**
- Title (string, required)
- Description (text, required)
- Icon (string, required)
- Color (string, required)
- Route (string, required)
- Order (integer)
- Is Enabled (boolean)
- Requires Authentication (boolean)
- Required Roles (json)

### Settings

Settings are used for application-wide configuration.

**Fields:**
- App Name (string, required)
- App Logo (media)
- Theme Color (string)
- Primary Color (string)
- Secondary Color (string)
- Accent Color (string)
- Background Color (string)
- Text Color (string)
- Font Family (string)
- Contact Email (email)
- Contact Phone (string)
- Social Links (json)
- Terms URL (string)
- Privacy URL (string)

### Staff Members

Staff Members are used for managing staff information.

**Fields:**
- Name (string, required)
- Photo (media)
- Position (string, required)
- Contact Number (string)
- Email (email)
- Address (text)
- ID Proof (media)
- Is Verified (boolean)
- Is Active (boolean)
- Rating (decimal)
- Total Ratings (integer)
- Skills (json)
- Availability (json)

### Members

Members are used for managing member information.

**Fields:**
- Name (string, required)
- Photo (media)
- Contact Number (string)
- Email (email)
- Unit Number (string)
- Building Name (string)
- Is Active (boolean)
- Role (string)
- Staff Members (relation)

### Notifications

Notifications are used for sending messages to users.

**Fields:**
- Title (string, required)
- Message (text, required)
- Type (enumeration: info, success, warning, error)
- Icon (string)
- Action (string)
- Action Data (json)
- Is Read (boolean)
- Target User IDs (json)
- Target Roles (json)

### FAQs

FAQs are used for frequently asked questions.

**Fields:**
- Question (string, required)
- Answer (richtext, required)
- Category (string)
- Order (integer)
- Is Published (boolean)

## API Reference

### CMSService

The `CMSService` class provides methods for interacting with the Strapi CMS API:

```dart
// Get all pages
Future<List<CMSPage>> getPages({
  Map<String, dynamic>? filters,
  String? sort,
  int? page,
  int? pageSize,
});

// Get a page by slug
Future<CMSPage?> getPageBySlug(String slug);

// Get all features
Future<List<CMSFeature>> getFeatures({
  Map<String, dynamic>? filters,
  String? sort,
  int? page,
  int? pageSize,
});

// Get settings
Future<CMSSettings?> getSettings();

// Get notifications for a user
Future<List<CMSNotification>> getNotifications({
  required String userId,
  List<String>? roles,
  bool? isRead,
  int? page,
  int? pageSize,
});

// Mark a notification as read
Future<bool> markNotificationAsRead(int notificationId);

// Get FAQs
Future<List<CMSFAQ>> getFAQs({
  String? category,
  bool? isPublished,
  String? sort,
  int? page,
  int? pageSize,
});

// Get FAQ categories
Future<List<String>> getFAQCategories();
```

### CMSProvider

The `CMSProvider` class provides state management for CMS data:

```dart
// Initialize the CMS provider
Future<void> initialize();

// Load pages
Future<void> loadPages();

// Load page by slug
Future<CMSPage?> loadPageBySlug(String slug);

// Load features
Future<void> loadFeatures();

// Load settings
Future<void> loadSettings();

// Load notifications for a user
Future<void> loadNotifications({
  required String userId,
  List<String>? roles,
});

// Mark a notification as read
Future<bool> markNotificationAsRead(int notificationId);

// Load FAQs
Future<void> loadFAQs({String? category});

// Load FAQ categories
Future<void> loadFAQCategories();
```

## Frontend Integration

### Using CMS Components

The CMS integration provides several UI components for displaying CMS content:

```dart
// Display a CMS page
CMSPageContent(page: cmsPage);

// Display CMS features
CMSFeatureGrid(
  features: cmsProvider.features,
  onFeatureTap: (feature) {
    // Handle feature tap
  },
);

// Display CMS notifications
CMSNotificationList(
  notifications: cmsProvider.notifications,
  onNotificationTap: (notification) {
    // Handle notification tap
  },
  onMarkAsRead: (notification) {
    cmsProvider.markNotificationAsRead(notification.id);
  },
);

// Display CMS FAQs
CMSFAQList(
  faqs: cmsProvider.faqs,
  categories: cmsProvider.faqCategories,
  onCategorySelected: (category) {
    cmsProvider.loadFAQs(category: category);
  },
);
```

### Launching the CMS-Based App

To launch the CMS-based version of the app:

```dart
import 'package:member_staff_app/main.dart';

void main() {
  launchCMSBasedApp();
}
```

## Development Workflow

### 1. Create Content in Strapi

1. Log in to the Strapi admin panel
2. Create or update content as needed
3. Publish the content when ready

### 2. Test in the Flutter App

1. Launch the CMS-based app using `launchCMSBasedApp()`
2. Verify that the content appears correctly
3. Test all features and interactions

### 3. Make Code Changes

1. Update the CMS models if needed
2. Update the CMS service if needed
3. Update the UI components if needed

### 4. Deploy

1. Deploy the Strapi CMS to a production server
2. Update the CMS configuration in the Flutter app
3. Build and deploy the Flutter app

## Deployment

### Deploying Strapi CMS

1. Set up a production server (e.g., DigitalOcean, AWS, Heroku)
2. Install Node.js and npm
3. Clone your Strapi project
4. Install dependencies: `npm install`
5. Build the admin panel: `npm run build`
6. Start the server: `npm run start`

### Configuring the Flutter App for Production

1. Update the CMS configuration in `lib/cms/config/cms_config.dart`:
   ```dart
   static const String baseUrl = 'https://your-production-strapi-url';
   static const String apiToken = 'your-production-api-token';
   ```

2. Build the Flutter app for production:
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

## Troubleshooting

### Common Issues

#### Content Not Loading

- Check that the Strapi server is running
- Verify that the API token is correct
- Check the network connection
- Look for errors in the console

#### Images Not Displaying

- Verify that the image URLs are correct
- Check that the Strapi server is accessible
- Ensure that the images are published

#### Rich Text Not Rendering Correctly

- Check the HTML content in Strapi
- Verify that the `flutter_html` package is correctly configured
- Look for unsupported HTML tags or attributes

### Getting Help

If you encounter issues not covered in this guide:

1. Check the Strapi documentation: https://docs.strapi.io
2. Check the Strapi SDK documentation: https://pub.dev/documentation/strapi_sdk/latest/
3. Look for similar issues on GitHub or Stack Overflow
4. Contact the development team for assistance
