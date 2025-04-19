# All Dues Report Feature

This feature allows Management Committee users to view all members' current dues, unpaid bills, invoice amounts, due dates, and last payments received. Normal members will still see only their own dues (no change in existing flow).

## Features

- View all members' current dues (committee members only)
- Advanced filtering options:
  - Filter by building, wing, floor, overdue status, and due month
  - Filter by due amount range using a slider
  - Search by member name or unit number
- Data visualization:
  - Bar charts showing total outstanding dues by wing
  - Bar charts showing total outstanding dues by floor
  - Bar charts showing top members with highest dues
  - Automatic switching between bar and pie charts based on data size
- Auto-reload on filter changes
- Infinite scroll pagination with filter context preservation
- Export data as CSV with all filters applied

## Access Control

| Role      | Access to Report       |
|-----------|------------------------|
| committee | ✅ Full Society Report |
| member    | ❌ Only own dues (existing) |

## Implementation Details

### Backend (Laravel)

The backend implementation includes:

1. **Controller**: `CommitteeDuesReportController` with three main methods:
   - `index()`: Returns a paginated list of dues with filtering options
   - `exportCsv()`: Exports the dues report as a CSV file
   - `chartSummary()`: Returns aggregated data for chart visualizations

2. **Routes**:
   - `GET /api/committee/dues-report`: Get the dues report with filtering options
   - `GET /api/committee/dues-report/export`: Export the dues report as CSV
   - `GET /api/committee/dues-report/chart-summary`: Get chart data with aggregated dues information

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
   - Advanced filter section with dropdowns for building, wing, floor, month, and status
   - Due amount range slider for filtering by amount
   - Chart visualization section with different chart types
   - List view of dues with infinite scroll pagination
   - Export to CSV functionality with all filters applied
   - Auto-reload on filter changes

2. **Models**:
   - `DuesReportItem`: Represents a dues report item
   - `DuesChartItem`: Represents a chart data item

3. **Services**:
   - `ApiService`: Handles API calls to the backend with pagination and filter support

4. **Widgets**:
   - `DuesChartWidget`: Bar chart visualization for dues data
   - `DuesPieChartWidget`: Pie chart visualization for dues data
   - Custom filter widgets with debounce mechanisms

## API Response Format

### Dues Report API Response

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

### Chart Summary API Response

```json
[
  {
    "label": "Building A",
    "total_due": 25000
  },
  {
    "label": "Building B",
    "total_due": 12000
  },
  {
    "label": "Building C",
    "total_due": 34000
  }
]
```

## Testing

The implementation includes comprehensive tests:

1. **Backend Tests**:
   - `CommitteeDuesReportControllerTest`: Tests the controller methods
   - Tests for authorization, filtering, and CSV export
   - Tests for the new wing, floor, and due amount range filters
   - Tests for the chart summary API endpoint

2. **Frontend Tests**:
   - `all_dues_report_test.dart`: Tests for the UI components and interactions
   - Tests for filter application and auto-reload functionality
   - Tests for infinite scroll pagination with filter context preservation
   - Tests for chart type selection and visualization

## Installation and Usage

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run the app using `flutter run`

## Future Enhancements

- Add more advanced filtering options:
  - Filter by date range with a date range picker
  - Filter by payment method
  - Filter by multiple buildings/wings simultaneously
- Add sorting options:
  - Sort by amount (ascending/descending)
  - Sort by due date (ascending/descending)
  - Sort by member name (alphabetical)
- Enhance chart visualizations:
  - Add trend analysis over time
  - Add comparison charts between months
  - Add export options for charts (PNG, PDF)
- Add email functionality:
  - Send reminders to members with overdue dues
  - Schedule automated reminder emails
  - Generate and send monthly dues reports to committee members
