<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MockStaffSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get member IDs
        $members = DB::table('members')->get();
        
        // Create mock staff
        $staff = [
            // Unverified Existing Staff
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Unverified Staff',
                'mobile' => '917411122233',
                'email' => 'unverified.staff@example.com',
                'staff_scope' => 'member',
                'is_verified' => false,
                'company_id' => '8454',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            
            // Already Verified Staff
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Verified Staff',
                'mobile' => '917422233344',
                'email' => 'verified.staff@example.com',
                'staff_scope' => 'member',
                'is_verified' => true,
                'verified_at' => now()->subDays(5),
                'verified_by_member_id' => $members[0]->id,
                'unit_id' => $members[0]->unit_id,
                'company_id' => '8454',
                'aadhaar_number' => '123456789012',
                'residential_address' => '123 Main St, City, State, 123456',
                'next_of_kin_name' => 'Next of Kin',
                'next_of_kin_mobile' => '917422233345',
                'photo_url' => 'https://example.com/photos/staff1.jpg',
                'created_at' => now()->subDays(10),
                'updated_at' => now()->subDays(5),
            ],
            
            // Staff with Pending OTP
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Pending OTP Staff',
                'mobile' => '917444455566',
                'email' => 'pending.otp.staff@example.com',
                'staff_scope' => 'member',
                'is_verified' => false,
                'company_id' => '8454',
                'created_at' => now()->subHours(1),
                'updated_at' => now()->subHours(1),
            ],
            
            // Staff with Schedule Conflicts
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Schedule Conflict Staff',
                'mobile' => '917455566677',
                'email' => 'schedule.conflict.staff@example.com',
                'staff_scope' => 'member',
                'is_verified' => true,
                'verified_at' => now()->subDays(15),
                'verified_by_member_id' => $members[1]->id,
                'unit_id' => $members[1]->unit_id,
                'company_id' => '8454',
                'aadhaar_number' => '234567890123',
                'residential_address' => '456 Oak St, City, State, 234567',
                'next_of_kin_name' => 'Next of Kin 2',
                'next_of_kin_mobile' => '917455566678',
                'photo_url' => 'https://example.com/photos/staff2.jpg',
                'created_at' => now()->subDays(20),
                'updated_at' => now()->subDays(15),
            ],
            
            // Society Staff
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Society Staff',
                'mobile' => '917466677788',
                'email' => 'society.staff@example.com',
                'staff_scope' => 'society',
                'department' => 'Maintenance',
                'designation' => 'Electrician',
                'society_id' => Str::uuid()->toString(),
                'company_id' => '8454',
                'is_verified' => true,
                'verified_at' => now()->subDays(30),
                'created_at' => now()->subDays(30),
                'updated_at' => now()->subDays(30),
            ],
        ];

        DB::table('staff')->insert($staff);
        
        // Create staff assignments
        $staffRecords = DB::table('staff')->get();
        $verifiedStaff = $staffRecords->where('mobile', '917422233344')->first();
        $scheduleConflictStaff = $staffRecords->where('mobile', '917455566677')->first();
        
        $assignments = [
            [
                'id' => Str::uuid()->toString(),
                'member_id' => $members[0]->id,
                'staff_id' => $verifiedStaff->id,
                'created_at' => now()->subDays(5),
                'updated_at' => now()->subDays(5),
            ],
            [
                'id' => Str::uuid()->toString(),
                'member_id' => $members[1]->id,
                'staff_id' => $scheduleConflictStaff->id,
                'created_at' => now()->subDays(15),
                'updated_at' => now()->subDays(15),
            ],
        ];
        
        DB::table('member_staff_assignments')->insert($assignments);
        
        // Create time slots for the staff with schedule conflicts
        $today = now()->format('Y-m-d');
        $tomorrow = now()->addDay()->format('Y-m-d');
        
        $timeSlots = [
            [
                'id' => Str::uuid()->toString(),
                'staff_id' => $scheduleConflictStaff->id,
                'date' => $today,
                'start_time' => '09:00',
                'end_time' => '10:00',
                'is_booked' => true,
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(2),
            ],
            [
                'id' => Str::uuid()->toString(),
                'staff_id' => $scheduleConflictStaff->id,
                'date' => $today,
                'start_time' => '11:00',
                'end_time' => '12:00',
                'is_booked' => true,
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(2),
            ],
            [
                'id' => Str::uuid()->toString(),
                'staff_id' => $scheduleConflictStaff->id,
                'date' => $today,
                'start_time' => '14:00',
                'end_time' => '15:00',
                'is_booked' => true,
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(2),
            ],
            [
                'id' => Str::uuid()->toString(),
                'staff_id' => $scheduleConflictStaff->id,
                'date' => $tomorrow,
                'start_time' => '10:00',
                'end_time' => '11:00',
                'is_booked' => true,
                'created_at' => now()->subDays(1),
                'updated_at' => now()->subDays(1),
            ],
            [
                'id' => Str::uuid()->toString(),
                'staff_id' => $scheduleConflictStaff->id,
                'date' => $tomorrow,
                'start_time' => '15:00',
                'end_time' => '16:00',
                'is_booked' => true,
                'created_at' => now()->subDays(1),
                'updated_at' => now()->subDays(1),
            ],
        ];
        
        DB::table('time_slots')->insert($timeSlots);
        
        // Create OTP for the staff with pending OTP
        $pendingOtpStaff = $staffRecords->where('mobile', '917444455566')->first();
        
        $otps = [
            [
                'mobile' => $pendingOtpStaff->mobile,
                'otp' => '123456',
                'verified' => false,
                'expires_at' => now()->addMinutes(10),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];
        
        DB::table('otps')->insert($otps);
    }
}
