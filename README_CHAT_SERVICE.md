# Chat Service Documentation

## Overview

The Chat Service feature provides a comprehensive messaging system for the OneApp platform, enabling users to communicate through direct messages, group chats, public discussion rooms, and committee-specific rooms with voting capabilities.

## Features

### Messaging Capabilities
- **Direct Messaging**: One-to-one private conversations between users
- **Group Chat**: Private group conversations with multiple participants
- **Public Discussion Rooms**: Open chat rooms that any user can join
- **Committee Rooms**: Special rooms for committee members with voting capabilities

### Real-time Communication
- **Instant Messaging**: Messages are delivered in real-time
- **Typing Indicators**: See when other users are typing
- **Online Status**: View which users are currently online
- **Message Delivery Status**: Confirmation when messages are delivered and read

### Committee Room Features
- **Topic-based Discussions**: Create rooms focused on specific topics
- **Member Search**: Find and invite specific members to join discussions
- **Voting System**: Create polls, vote on options, and view results
- **Poll Management**: Committee members can create and close polls

### Security and Privacy
- **Authentication**: Secure access through OneSSO (Keycloak) integration
- **Role-based Access**: Different capabilities based on user roles
- **End-to-end Encryption**: Secure message transmission
- **Message Retention**: Configurable message history retention

## Technical Implementation

### Architecture
The Chat Service is built using a combination of technologies:

- **Frontend**: Flutter for cross-platform mobile and web interfaces
- **Backend**: Supabase for real-time database and authentication
- **Real-time Communication**: Supabase Realtime for WebSocket connections
- **Authentication**: Integration with OneSSO (Keycloak) for secure access

### Database Schema
The Chat Service uses the following database tables:

- `chat_rooms`: Stores information about chat rooms
- `chat_room_participants`: Maps users to the rooms they participate in
- `chat_messages`: Stores all messages sent in chat rooms
- `voting_polls`: Stores polls created in committee rooms
- `voting_options`: Stores options for each poll
- `voting_responses`: Records user votes on poll options

### API Endpoints

#### Chat Rooms
- `GET /api/chat/rooms` - List all chat rooms for the current user
- `POST /api/chat/rooms` - Create a new chat room
- `GET /api/chat/rooms/{id}` - Get details of a specific chat room
- `DELETE /api/chat/rooms/{id}/leave` - Leave a chat room
- `POST /api/chat/rooms/{id}/join` - Join a public chat room

#### Messages
- `GET /api/chat/rooms/{id}/messages` - Get messages for a chat room
- `POST /api/chat/rooms/{id}/messages` - Send a message to a chat room

#### Users
- `GET /api/chat/users/search` - Search for users to invite to a chat room

#### Voting
- `POST /api/chat/rooms/{id}/polls` - Create a new poll in a committee room
- `GET /api/chat/rooms/{id}/polls` - Get all polls for a committee room
- `POST /api/chat/polls/{id}/vote` - Vote on a poll option
- `PATCH /api/chat/polls/{id}/close` - Close a poll (committee members only)

## User Interface

### Chat List Screen
- Displays all chat rooms the user is participating in
- Shows the most recent message and timestamp for each room
- Indicates unread message count
- Provides options to create new rooms or join public rooms

### Chat Room Screen
- Displays messages in a conversation view
- Shows user avatars and names
- Provides message input with attachment options
- For committee rooms, displays active polls and voting interface

### Committee Room Creation
- Form to enter room name, description, and topic
- Member search and selection interface
- Option to invite all members or select specific ones

### Poll Creation and Voting
- Interface for committee members to create polls with multiple options
- Voting interface for all room participants
- Results view showing vote counts and percentages
- Option for poll creators to close polls

## Integration with OneApp

The Chat Service is fully integrated with the OneApp platform:
- Uses the same authentication system (OneSSO/Keycloak)
- Shares user profiles and permissions
- Consistent UI/UX with the rest of the application
- Notifications are integrated with the OneApp notification system

## Security Considerations

- All API endpoints are protected with authentication
- Committee room features are restricted to users with the committee role
- Poll creation is limited to committee members
- Poll voting is restricted to room participants
- Users can only access rooms they are participants in

## Future Enhancements

- **File Sharing**: Support for sharing documents and media files
- **Message Reactions**: Emoji reactions to messages
- **Message Threading**: Reply to specific messages in a thread
- **Advanced Polls**: Support for multiple choice and ranked choice voting
- **Video Conferencing**: Integration with video call capabilities
- **Moderation Tools**: Features for moderating public discussion rooms
