# All Dues Report Feature

This feature allows Management Committee users to view all members' current dues, unpaid bills, invoice amounts, due dates, and last payments received. Normal members will still see only their own dues (no change in existing flow).

## Features

- View all members' current dues (committee members only)
- Filter by building, floor, overdue status, and due month
- Search by member name or unit number
- Export data as CSV
- Pagination for large datasets

## Access Control

| Role      | Access to Report       |
|-----------|------------------------|
| committee | ✅ Full Society Report |
| member    | ❌ Only own dues (existing) |

## Implementation Details

### Backend (Laravel)

The backend implementation includes:

1. **Controller**: `CommitteeDuesReportController` with two main methods:
   - `index()`: Returns a paginated list of dues with filtering options
   - `exportCsv()`: Exports the dues report as a CSV file

2. **Routes**:
   - `GET /api/committee/dues-report`: Get the dues report with filtering options
   - `GET /api/committee/dues-report/export`: Export the dues report as CSV

3. **Middleware**:
   - `CommitteeMiddleware`: Ensures only committee members can access the routes

4. **Policy**:
   - `CommitteePolicy`: Defines authorization rules for committee members

5. **Database Tables**:
   - `member_bills`: Contains bills per unit per cycle
   - `payments`: Linked to invoices
   - `members`, `units`, `buildings`: Lookup tables

### Frontend (Flutter)

The frontend implementation includes:

1. **Screen**: `AllDuesReportScreen` with the following features:
   - Search bar for filtering member name/unit number
   - Filter dropdowns for building, month, and status
   - List view of dues with pagination
   - Export to CSV functionality

2. **Models**:
   - `DuesReportItem`: Represents a dues report item

3. **Services**:
   - `ApiService`: Handles API calls to the backend

4. **Widgets**:
   - Custom widgets for the UI components

## API Response Format

```json
{
  "current_page": 1,
  "data": [
    {
      "member_name": "John Doe",
      "unit_number": "A-101",
      "building_name": "Building A",
      "bill_cycle": "Apr 2025",
      "bill_amount": 1000,
      "amount_paid": 0,
      "due_amount": 1000,
      "due_date": "2025-04-10",
      "last_payment_date": null
    },
    ...
  ],
  "first_page_url": "http://example.com/api/committee/dues-report?page=1",
  "from": 1,
  "last_page": 10,
  "last_page_url": "http://example.com/api/committee/dues-report?page=10",
  "links": [...],
  "next_page_url": "http://example.com/api/committee/dues-report?page=2",
  "path": "http://example.com/api/committee/dues-report",
  "per_page": 15,
  "prev_page_url": null,
  "to": 15,
  "total": 150
}
```

## Testing

The implementation includes comprehensive tests:

1. **Backend Tests**:
   - `CommitteeDuesReportControllerTest`: Tests the controller methods
   - Tests for authorization, filtering, and CSV export

2. **Frontend Tests**:
   - Tests for the UI components
   - Tests for the API service

## Installation and Usage

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run the app using `flutter run`

## Future Enhancements

- Add more filtering options (e.g., by date range)
- Add sorting options (e.g., by amount, due date)
- Add charts and graphs for visualizing dues data
- Add email functionality to send reminders to members with overdue dues
