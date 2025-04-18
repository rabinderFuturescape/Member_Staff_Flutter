# Member Staff Attendance Dashboard Wireframe

## Main Dashboard Layout

```
+--------------------------------------------------------------+
|                                                              |
|  [Logo] Admin Dashboard                       [User Profile] |
|                                                              |
+--------------------------------------------------------------+
|                  |                                           |
|  Navigation      |  Content Area                             |
|                  |                                           |
|  - Dashboard     |  +-------------------------------------------+
|  - Staff         |  |                                           |
|  - Attendance    |  |  Member Staff Attendance Dashboard        |
|  - Bookings      |  |                                           |
|  - Reports       |  +-------------------------------------------+
|                  |                                           |
|                  |  +-------------------------------------------+
|                  |  |                                           |
|                  |  |  Date: [Date Picker] Status: [Dropdown]   |
|                  |  |                                           |
|                  |  |  Search: [Search Box]     [Export CSV]    |
|                  |  |                                           |
|                  |  +-------------------------------------------+
|                  |                                           |
|                  |  +-------------------------------------------+
|                  |  |                                           |
|                  |  |  Staff Name | Status | Note | Photo       |
|                  |  |  ------------------------------------     |
|                  |  |  Staff 1    | Present| Note1 | [Photo]    |
|                  |  |  Staff 2    | Absent | Note2 | N/A        |
|                  |  |  Staff 3    | Present| Note3 | [Photo]    |
|                  |  |  ...        | ...    | ...   | ...        |
|                  |  |                                           |
|                  |  +-------------------------------------------+
|                  |                                           |
|                  |  +-------------------------------------------+
|                  |  |                                           |
|                  |  |  [Prev] 1 2 3 ... [Next]                  |
|                  |  |                                           |
|                  |  +-------------------------------------------+
|                  |                                           |
|                  |  +-------------------------------------------+
|                  |  |                                           |
|                  |  |  Present: 15  |  Absent: 5  |  Not Marked: 2  |
|                  |  |                                           |
|                  |  +-------------------------------------------+
|                  |                                           |
+------------------+-------------------------------------------+
```

## Components Breakdown

### 1. Header
- Logo and application name
- User profile dropdown

### 2. Sidebar Navigation
- Dashboard link
- Staff Management link
- Attendance link (active)
- Bookings link
- Reports link

### 3. Filters and Controls
- Date picker to select date
- Status dropdown (All, Present, Absent, Not Marked)
- Search box for staff name
- Export CSV button

### 4. Attendance Table
- Staff Name column with photo thumbnail
- Status column with color-coded badges
- Note column
- Photo column with proof thumbnails
- Pagination controls

### 5. Summary Statistics
- Present count with green highlight
- Absent count with red highlight
- Not Marked count with gray highlight

## Mobile Responsive Design

On mobile devices:
- Sidebar collapses to a hamburger menu
- Table becomes scrollable horizontally
- Filters stack vertically
- Summary statistics display in a single column

## Interactions

1. **Date Selection**
   - When a date is selected, the table updates to show attendance for that date

2. **Status Filtering**
   - When a status is selected from the dropdown, the table filters to show only records with that status

3. **Search**
   - As the user types in the search box, the table filters to show only staff names matching the search term

4. **Photo Viewing**
   - Clicking on a photo thumbnail opens a modal with a larger version of the photo

5. **Pagination**
   - Clicking on page numbers or next/previous buttons navigates between pages of results

6. **CSV Export**
   - Clicking the Export CSV button downloads a CSV file with the current filtered data
