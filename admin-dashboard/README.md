# Member Staff Admin Dashboard

This is a Next.js application that provides an admin dashboard for managing member staff attendance records.

## Features

- View attendance records by date
- Filter by attendance status (present, absent, not marked)
- Search staff by name
- Pagination for large datasets
- Export attendance data to CSV
- View photo proof of attendance
- Summary statistics

## Getting Started

### Prerequisites

- Node.js 14.x or later
- npm or yarn

### Installation

1. Clone the repository
2. Install dependencies:

```bash
npm install
# or
yarn install
```

3. Run the development server:

```bash
npm run dev
# or
yarn dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

## Project Structure

- `/pages` - Next.js pages
  - `/api` - API routes
  - `/member-staff` - Member staff related pages
- `/components` - Reusable React components
- `/lib` - Utility functions
- `/styles` - Global styles

## API Routes

### GET /api/admin/attendance

Fetches attendance records with filtering and pagination.

**Query Parameters:**
- `date` (required): Date in YYYY-MM-DD format
- `status` (optional): Filter by status (present, absent, not_marked)
- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Number of records per page (default: 10)
- `search` (optional): Search term for staff name

**Response:**
```json
{
  "records": [
    {
      "staff_id": 1001,
      "staff_name": "Staff Member 1",
      "staff_category": "Domestic Help",
      "staff_photo": "https://example.com/photo1.jpg",
      "status": "present",
      "note": "On time",
      "photo_url": "https://example.com/proof1.jpg",
      "date": "2023-11-15"
    }
  ],
  "total": 20,
  "page": 1,
  "limit": 10,
  "totalPages": 2
}
```

## Next Steps

- Add filters for: present, absent, unmarked ✅
- Implement pagination ✅
- Add CSV export functionality ✅
- Add authentication and authorization
- Implement staff management features
- Add reporting and analytics
- Implement real-time updates
