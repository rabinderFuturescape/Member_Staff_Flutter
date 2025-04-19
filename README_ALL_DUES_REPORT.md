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

### Authentication with OneSSO

The All Dues Report feature is secured using OneSSO (Keycloak) authentication:

- **Token-Based Authentication**: All API requests require a valid JWT token issued by Keycloak
- **Role-Based Access Control**: Only users with the 'committee' role can access the report
- **Token Validation**: Tokens are validated for authenticity, expiration, and proper issuer
- **Automatic Token Refresh**: Expired tokens are automatically refreshed when possible

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
   - `VerifyKeycloakToken`: Validates JWT tokens issued by Keycloak
   - `CommitteeRoleMiddleware`: Ensures only committee members can access the routes

4. **Configuration**:
   - `keycloak.php`: Contains Keycloak configuration settings
   - Environment variables for Keycloak base URL, realm, client ID, and public key

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
   - `OneSSOAuthService`: Manages authentication with Keycloak, including token retrieval, validation, and refresh

4. **Widgets**:
   - `DuesChartWidget`: Bar chart visualization for dues data
   - `DuesPieChartWidget`: Pie chart visualization for dues data
   - Custom filter widgets with debounce mechanisms

## Authentication Flow

1. **User Login**:
   - User logs in to the OneApp using OneSSO (Keycloak)
   - Upon successful authentication, Keycloak issues a JWT token
   - The token contains user information and roles in the payload

2. **Token Storage**:
   - The JWT token is securely stored using Flutter Secure Storage
   - The refresh token is also stored for automatic token renewal

3. **API Requests**:
   - The `ApiService` automatically attaches the token to all API requests
   - The token is sent in the Authorization header as a Bearer token

4. **Token Validation**:
   - The Laravel backend validates the token using the `VerifyKeycloakToken` middleware
   - The middleware checks the token signature, expiration, issuer, and audience

5. **Role Verification**:
   - The `CommitteeRoleMiddleware` extracts roles from the validated token
   - It verifies that the user has the 'committee' role
   - If the role check fails, a 403 Forbidden response is returned

6. **Token Refresh**:
   - When a token expires, the `ApiService` automatically attempts to refresh it
   - If refresh is successful, the request is retried with the new token
   - If refresh fails, the user is redirected to the login screen

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
   - `VerifyKeycloakTokenTest`: Tests the Keycloak token validation middleware
   - `CommitteeRoleMiddlewareTest`: Tests the committee role verification
   - Tests for authorization, filtering, and CSV export
   - Tests for the new wing, floor, and due amount range filters
   - Tests for the chart summary API endpoint

2. **Frontend Tests**:
   - `all_dues_report_test.dart`: Tests for the UI components and interactions
   - `onessoauth_service_test.dart`: Tests for the OneSSO authentication service
   - Tests for token validation, refresh, and role verification
   - Tests for filter application and auto-reload functionality
   - Tests for infinite scroll pagination with filter context preservation
   - Tests for chart type selection and visualization
   - Tests for unauthorized access handling

## Installation and Usage

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure OneSSO integration:
   - Set up Keycloak environment variables in `.env` file:
     ```
     KEYCLOAK_BASE_URL=https://sso.oneapp.in
     KEYCLOAK_REALM=oneapp
     KEYCLOAK_CLIENT_ID=member-staff-api
     KEYCLOAK_PUBLIC_KEY=your_public_key_here
     ```
   - Update Flutter constants in `lib/utils/constants.dart` if needed
4. Run the app using `flutter run`

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
