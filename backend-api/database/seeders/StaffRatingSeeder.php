<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\StaffRating;
use App\Models\Staff;
use App\Models\SocietyStaff;
use App\Models\Member;

class StaffRatingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // Get all members
        $members = Member::all();
        if ($members->isEmpty()) {
            $this->command->info('No members found. Please run MemberSeeder first.');
            return;
        }
        
        // Get all staff
        $memberStaff = Staff::all();
        if ($memberStaff->isEmpty()) {
            $this->command->info('No member staff found. Please run StaffSeeder first.');
            return;
        }
        
        // Get all society staff
        $societyStaff = SocietyStaff::all();
        if ($societyStaff->isEmpty()) {
            $this->command->info('No society staff found. Please run SocietyStaffSeeder first.');
            return;
        }
        
        // Create ratings for member staff
        foreach ($memberStaff as $staff) {
            // Get members assigned to this staff
            $assignedMembers = $staff->members;
            if ($assignedMembers->isEmpty()) {
                continue;
            }
            
            // Create 1-3 ratings for each staff from different members
            $ratingCount = rand(1, 3);
            $ratedMembers = $assignedMembers->random(min($ratingCount, $assignedMembers->count()));
            
            foreach ($ratedMembers as $member) {
                StaffRating::factory()->create([
                    'member_id' => $member->id,
                    'staff_id' => $staff->id,
                    'staff_type' => 'member',
                ]);
            }
        }
        
        // Create ratings for society staff
        foreach ($societyStaff as $staff) {
            // Create 3-8 ratings for each society staff from random members
            $ratingCount = rand(3, 8);
            $ratedMembers = $members->random(min($ratingCount, $members->count()));
            
            foreach ($ratedMembers as $member) {
                StaffRating::factory()->create([
                    'member_id' => $member->id,
                    'staff_id' => $staff->id,
                    'staff_type' => 'society',
                ]);
            }
        }
        
        $this->command->info('Staff ratings seeded successfully.');
    }
}
