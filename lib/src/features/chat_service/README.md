# Chat Service Feature

This module provides a complete chat service with real-time messaging capabilities, powered by Supabase and integrated with OneSSO (Keycloak) authentication. It includes direct messaging, group chats, and public discussion rooms.

## Features

- Real-time messaging with Supabase Realtime
- Different chat room types (direct, group, public)
- Create and join chat rooms
- Send and receive messages in real-time
- View chat history
- Leave chat rooms
- User presence indicators
- Secure authentication with OneSSO (Keycloak)
- Token-based authorization
- Automatic token refresh

## Architecture

The Chat Service feature follows a clean architecture approach:

- **Models**: Data classes representing chat messages, rooms, and users
- **API**: Service layer for interacting with Supabase
- **Services**: Authentication and other business logic services
- **Providers**: State management using the Provider pattern
- **Pages**: UI screens for the chat functionality
- **Widgets**: Reusable UI components
- **Utils**: Constants and helper functions

## Database Schema

The feature uses the following tables in Supabase:

- `chat_rooms`: Stores information about chat rooms
- `chat_room_participants`: Tracks participants in each room
- `chat_messages`: Stores all chat messages

Row Level Security (RLS) policies are implemented to ensure users can only:
- View rooms they are in (or public rooms)
- Send messages to rooms they are in
- Create new rooms
- Join public rooms
- Leave rooms they are in

## Integration

To integrate this feature into your app:

1. Register the routes in your main app:
```dart
void main() {
  // ...
  final routes = {
    ...ChatServiceModule.getRoutes(),
    // Your other routes
  };
  // ...
}
```

2. Register the providers:
```dart
MultiProvider(
  providers: [
    ...ChatServiceModule.getProviders(),
    // Your other providers
  ],
  child: MyApp(),
)
```

3. Initialize the module:
```dart
await ChatServiceModule.initialize();
```

4. Configure OneSSO (Keycloak) integration:
```dart
// In your constants.dart file
static const String keycloakBaseUrl = 'https://sso.oneapp.in';
static const String keycloakRealm = 'oneapp';
static const String keycloakClientId = 'member-staff-app';
```

5. Execute the SQL schema in your Supabase project:
```sql
-- Run the SQL from ChatServiceModule.getDatabaseSchema()
```

## Usage

Navigate to the chat list screen:
```dart
Navigator.pushNamed(context, ChatConstants.chatListRoute);
```

Navigate to a specific chat room:
```dart
Navigator.pushNamed(
  context,
  ChatConstants.chatRoomRoute,
  arguments: {'roomId': 'some-room-id'},
);
```

Create a new chat room:
```dart
Navigator.pushNamed(context, ChatConstants.createRoomRoute);
```

## Dependencies

- `supabase_flutter`: For Supabase integration and real-time functionality
- `provider`: For state management
- `timeago`: For formatting message timestamps
- `flutter_secure_storage`: For securely storing authentication tokens
- `jwt_decoder`: For decoding and validating JWT tokens
- `http`: For making HTTP requests to the OneSSO server

## Screenshots

![Chat List](screenshots/chat_list.png)
![Chat Room](screenshots/chat_room.png)
![Create Room](screenshots/create_room.png)
