# Strapi CMS Integration

This module integrates Strapi CMS with the Member Staff Flutter application, allowing for dynamic content management and UI rendering from the CMS.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Setup](#setup)
- [Usage](#usage)
- [Content Types](#content-types)
- [API Reference](#api-reference)
- [CMS Console](#cms-console)

## Overview

The Strapi CMS integration allows for managing content through a headless CMS, providing a flexible and dynamic way to update the application's content without requiring code changes. This integration uses the Strapi SDK to communicate with the Strapi CMS API.

## Features

- **Dynamic Content**: Manage pages, features, notifications, and FAQs through the CMS
- **Content Types**: Pre-defined content types for common use cases
- **CMS Console**: Built-in console for managing content
- **Responsive UI**: UI components that adapt to different screen sizes
- **Offline Support**: Caching of CMS content for offline use
- **Localization**: Support for multiple languages

## Setup

### 1. Strapi CMS Setup

1. Install Strapi CMS:
   ```bash
   npx create-strapi-app@latest my-project
   ```

2. Start the Strapi server:
   ```bash
   cd my-project
   npm run develop
   ```

3. Create the required content types in Strapi:
   - Pages
   - Features
   - Settings
   - Staff Members
   - Members
   - Notifications
   - FAQs

4. Generate an API token in Strapi:
   - Go to Settings > API Tokens
   - Create a new API token with appropriate permissions

### 2. Flutter App Setup

1. Update the CMS configuration in `lib/cms/config/cms_config.dart`:
   ```dart
   static const String baseUrl = 'http://your-strapi-url:1337';
   static const String apiToken = 'your-strapi-api-token';
   ```

2. Initialize the CMS provider in your app:
   ```dart
   final cmsProvider = CMSProvider();
   await cmsProvider.initialize();
   ```

3. Add the CMS provider to your widget tree:
   ```dart
   MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (_) => CMSProvider()),
       // Other providers...
     ],
     child: MyApp(),
   )
   ```

## Usage

### Displaying CMS Content

```dart
// Display a CMS page
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => CMSPageScreen(slug: 'about'),
  ),
);

// Display CMS features
Consumer<CMSProvider>(
  builder: (context, cmsProvider, child) {
    return CMSFeatureGrid(
      features: cmsProvider.features,
      onFeatureTap: (feature) {
        // Handle feature tap
      },
    );
  },
);

// Display CMS notifications
Consumer<CMSProvider>(
  builder: (context, cmsProvider, child) {
    return CMSNotificationList(
      notifications: cmsProvider.notifications,
      onNotificationTap: (notification) {
        // Handle notification tap
      },
      onMarkAsRead: (notification) {
        cmsProvider.markNotificationAsRead(notification.id);
      },
    );
  },
);

// Display CMS FAQs
Consumer<CMSProvider>(
  builder: (context, cmsProvider, child) {
    return CMSFAQList(
      faqs: cmsProvider.faqs,
      categories: cmsProvider.faqCategories,
      onCategorySelected: (category) {
        cmsProvider.loadFAQs(category: category);
      },
    );
  },
);
```

### Launching the CMS App

```dart
import 'package:member_staff_app/main.dart';

void main() {
  launchCMSApp();
}
```

## Content Types

### Pages

Pages are used for static content like About, Terms, Privacy Policy, etc.

**Fields:**
- Title
- Slug
- Content (Rich Text)
- Meta Title
- Meta Description
- Featured Image
- Is Published

### Features

Features are used for displaying feature cards on the home screen.

**Fields:**
- Title
- Description
- Icon
- Color
- Route
- Order
- Is Enabled
- Requires Authentication
- Required Roles

### Settings

Settings are used for application-wide configuration.

**Fields:**
- App Name
- App Logo
- Theme Color
- Primary Color
- Secondary Color
- Accent Color
- Background Color
- Text Color
- Font Family
- Contact Email
- Contact Phone
- Social Links
- Terms URL
- Privacy URL

### Notifications

Notifications are used for sending messages to users.

**Fields:**
- Title
- Message
- Type (Info, Success, Warning, Error)
- Icon
- Action
- Action Data
- Is Read
- Target User IDs
- Target Roles

### FAQs

FAQs are used for frequently asked questions.

**Fields:**
- Question
- Answer
- Category
- Order
- Is Published

## API Reference

### CMSService

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

## CMS Console

The CMS console provides a way to manage content directly from the Flutter app. It can be accessed by calling the `launchCMSConsole()` function.

```dart
import 'package:member_staff_app/main.dart';

void main() {
  launchCMSConsole();
}
```

The console provides links to:
- Strapi Admin Panel
- API Documentation
- Content Types
