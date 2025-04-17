# Mock Data Structure

This document describes the structure of the mock data provided in the SQL seed file.

## Tables Overview

The mock data includes the following tables:

1. **members**: Member records with their details
2. **units**: Unit records associated with members
3. **staff**: Staff records with various verification statuses
4. **staff_schedules**: Time slot schedules for staff members
5. **otps**: OTP records for testing verification flow

## Data Structure

### members

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| name | string | Member's full name |
| email | string | Member's email address |
| mobile | string | Member's mobile number with country code |
| unit_id | uuid | Foreign key to units table |
| company_id | string | Company/society ID |
| unit_number | string | Unit number (e.g., A-101) |
| is_active | boolean | Whether the member is active |
| created_at | timestamp | Record creation timestamp |
| updated_at | timestamp | Record update timestamp |
| deleted_at | timestamp | Soft delete timestamp (nullable) |

### units

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| unit_number | string | Unit number (e.g., A-101) |
| company_id | string | Company/society ID |
| block | string | Block identifier (e.g., A, B, C) |
| floor | string | Floor number |
| unit_type | string | Type of unit (e.g., 2BHK, 3BHK) |
| is_active | boolean | Whether the unit is active |
| created_at | timestamp | Record creation timestamp |
| updated_at | timestamp | Record update timestamp |
| deleted_at | timestamp | Soft delete timestamp (nullable) |

### staff

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| name | string | Staff's full name |
| mobile | string | Staff's mobile number with country code |
| email | string | Staff's email address (nullable) |
| staff_scope | enum | 'society' or 'member' |
| department | string | Department (for society staff) |
| designation | string | Designation (for society staff) |
| society_id | uuid | Society ID (for society staff) |
| unit_id | uuid | Unit ID (for member staff) |
| company_id | string | Company/society ID |
| aadhaar_number | string | 12-digit Aadhaar number |
| residential_address | text | Staff's residential address |
| next_of_kin_name | string | Name of next of kin |
| next_of_kin_mobile | string | Mobile number of next of kin |
| photo_url | string | URL to staff's photo |
| is_verified | boolean | Whether the staff is verified |
| verified_at | timestamp | When the staff was verified |
| verified_by_member_id | uuid | Member who verified the staff |
| created_by | uuid | Member who created the staff record |
| updated_by | uuid | Member who last updated the staff record |
| created_at | timestamp | Record creation timestamp |
| updated_at | timestamp | Record update timestamp |
| deleted_at | timestamp | Soft delete timestamp (nullable) |

### staff_schedules

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| staff_id | uuid | Foreign key to staff table |
| date | date | Date of the time slot |
| start_time | string | Start time (HH:MM format) |
| end_time | string | End time (HH:MM format) |
| is_booked | boolean | Whether the time slot is booked |
| created_at | timestamp | Record creation timestamp |
| updated_at | timestamp | Record update timestamp |
| deleted_at | timestamp | Soft delete timestamp (nullable) |

### otps

| Column | Type | Description |
|--------|------|-------------|
| id | integer | Primary key |
| mobile | string | Mobile number the OTP was sent to |
| otp | string | The 6-digit OTP |
| verified | boolean | Whether the OTP has been verified |
| expires_at | timestamp | When the OTP expires |
| created_at | timestamp | Record creation timestamp |
| updated_at | timestamp | Record update timestamp |

## Test Scenarios

The mock data is designed to support the following test scenarios:

### 1. Unverified Existing Staff (917411122233)

- Staff record exists in the database
- `is_verified` is set to `false`
- No OTP record exists yet

### 2. Already Verified Staff (917422233344)

- Staff record exists in the database
- `is_verified` is set to `true`
- `verified_at` and `verified_by_member_id` are populated
- Identity information (aadhaar, address, etc.) is populated

### 3. New Staff (917433344455)

- No staff record exists with this mobile number
- Testing should create a new record

### 4. Staff with Pending OTP (917444455566)

- Staff record exists in the database
- `is_verified` is set to `false`
- An OTP record exists with `verified` set to `false`
- `expires_at` is set to a future time

### 5. Staff with Schedule Conflicts (917455566677)

- Staff record exists and is verified
- Multiple time slots exist in the `staff_schedules` table
- Some time slots overlap with common working hours

## Relationships

- Each **member** belongs to a **unit**
- Each **staff** can be assigned to a **member** (for member staff)
- Each **staff** can have multiple **time slots** in their schedule
- Each **staff** can have multiple **OTP** records for verification

## Notes

- All mobile numbers in the mock data follow the format `91XXXXXXXXXX` (Indian mobile numbers with country code)
- All OTPs in the mock environment are set to `123456` for testing purposes
- The `company_id` is set to `8454` for all records in the mock data
