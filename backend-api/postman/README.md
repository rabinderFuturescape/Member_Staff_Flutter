# Member Staff API Postman Collection

This folder contains Postman collection and environment files for testing the Member Staff API.

## Files

- `Member_Staff_API.postman_collection.json`: The Postman collection containing all API endpoints
- `Member_Staff_API.postman_environment.json`: The Postman environment variables for development

## How to Use

1. Import the collection and environment files into Postman
2. Select the "Member Staff API - Development" environment
3. Generate a test token using the "Generate Test Token" request in the Authentication folder
4. Copy the token from the response and set it as the `auth_token` environment variable
5. Use the collection to test the API endpoints

## Environment Variables

The following environment variables are used in the collection:

- `base_url`: The base URL for the API (default: http://localhost:8000/api)
- `auth_token`: The JWT token for authentication
- `member_id`: The ID of the authenticated member
- `unit_id`: The ID of the member's unit
- `company_id`: The ID of the member's company
- `staff_id`: The ID of a staff member (set automatically after creating a staff)
- `time_slot_id`: The ID of a time slot (set automatically after creating a time slot)

## Test Scenarios

### Authentication Flow

1. Generate a test token using the "Generate Test Token" request
2. Verify the token using the "Verify Token" request

### Staff Verification Flow

1. Check if a staff exists using the "Check Staff Mobile" request
2. Send an OTP using the "Send OTP" request
3. Verify the OTP using the "Verify OTP" request
4. Create a new staff using the "Create Staff" request (if staff doesn't exist)
5. Verify the staff's identity using the "Verify Staff Identity" request

### Schedule Management Flow

1. Add time slots to a staff's schedule using the "Add Time Slot" or "Bulk Add Time Slots" request
2. Get the staff's schedule using the "Get Staff Schedule" request
3. Update a time slot using the "Update Time Slot" request
4. Remove a time slot using the "Remove Time Slot" request

### Member-Staff Assignment Flow

1. Assign a staff to a member using the "Assign Staff to Member" request
2. Get the staff assigned to a member using the "Get Member Staff" request
3. Unassign a staff from a member using the "Unassign Staff from Member" request

## Automated Tests

The collection includes automated tests for each request. To run the tests:

1. Open the collection in Postman
2. Click on the "..." button next to the collection name
3. Select "Run collection"
4. Configure the run settings
5. Click "Run Member Staff API"

## Pre-request Scripts

Some requests include pre-request scripts to set environment variables or perform other actions before the request is sent. For example, the "Generate Test Token" request sets the `auth_token` environment variable from the response.

## Test Scripts

Some requests include test scripts to validate the response and set environment variables for use in subsequent requests. For example, the "Create Staff" request sets the `staff_id` environment variable from the response.

## Notes

- The collection uses the `{{variable_name}}` syntax to reference environment variables
- The collection includes examples of all API endpoints
- The collection is organized into folders by functionality
- Each request includes a description of its purpose
