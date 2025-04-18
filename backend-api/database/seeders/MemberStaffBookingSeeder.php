<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\MemberStaffBooking;
use App\Models\BookingSlot;
use Illuminate\Support\Carbon;

class MemberStaffBookingSeeder extends Seeder
{
    public function run()
    {
        $booking = MemberStaffBooking::create([
            'staff_id' => 1002,
            'member_id' => 12,
            'unit_id' => 3,
            'company_id' => 8454,
            'start_date' => '2025-04-21',
            'end_date' => '2025-04-21',
            'repeat_type' => 'once',
            'notes' => 'Test booking seeder',
            'status' => 'pending'
        ]);

        BookingSlot::create([
            'booking_id' => $booking->id,
            'date' => '2025-04-21',
            'hour' => 9,
            'is_confirmed' => false
        ]);

        BookingSlot::create([
            'booking_id' => $booking->id,
            'date' => '2025-04-21',
            'hour' => 10,
            'is_confirmed' => false
        ]);
    }
}
