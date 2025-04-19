# Member Data Sync Feature

## Overview
The Member Data Sync feature enables seamless synchronization of member data between the Laravel MySQL backend and Supabase, ensuring that the latest member information is available in the app. This is crucial for maintaining data consistency across platforms and providing up-to-date information to users.

## Purpose
- Keep member records in Supabase in sync with the authoritative source in Laravel MySQL.
- Support both initial full sync and periodic incremental updates.
- Enable robust, error-handled data transfer with minimal manual intervention.

## Workflow
1. **Initial Sync**: Fetches all member records from the Laravel API and upserts them into Supabase.
2. **Incremental Sync**: Periodically fetches only updated member records since the last sync and upserts them into Supabase.
3. **Metadata Tracking**: Maintains a `last_sync_timestamp` in Supabase to track the last successful sync and optimize incremental updates.

## Key Components
### MemberSyncService (`lib/services/member_sync_service.dart`)
- Handles the core logic for fetching and upserting member data.
- Uses Dio for HTTP requests to the Laravel API.
- Uses Supabase client for database operations.
- Provides methods:
  - `syncMembers()`: Performs a full sync of all members.
  - `syncMemberUpdates()`: Syncs only updated members since the last sync.

### MemberSyncProvider (`lib/providers/member_sync_provider.dart`)
- Exposes sync operations to the UI and manages sync state.
- Provides methods:
  - `performInitialSync()`: Triggers a full sync.
  - `syncUpdates()`: Triggers an incremental sync.
  - `startPeriodicSync()`: Sets up periodic background sync (e.g., every 5 minutes).
- Handles error reporting and notifies listeners of sync status.

## Integration Steps
1. **Configure** the Laravel API endpoint and Supabase client in your app.
2. **Instantiate** `MemberSyncProvider` with the required dependencies.
3. **Call** `performInitialSync()` on first launch or as needed.
4. **Enable** periodic sync by calling `startPeriodicSync()`.

## Error Handling
- All sync operations are wrapped in try-catch blocks.
- Errors are reported via the provider's `lastError` property for UI feedback.

## Extending the Feature
- Adjust sync intervals as needed in `startPeriodicSync()`.
- Add additional member fields as required by updating the mapping logic in `MemberSyncService`.

## References
- `lib/services/member_sync_service.dart`
- `lib/providers/member_sync_provider.dart`

For further details, see the code comments and usage examples in the respective files.