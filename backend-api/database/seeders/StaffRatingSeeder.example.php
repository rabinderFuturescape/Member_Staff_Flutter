<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\StaffRating;
use App\Models\Member;
use App\Models\Staff;
use App\Models\SocietyStaff;
use Faker\Factory as Faker;

class StaffRatingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $faker = Faker::create();
        
        // Get all members, staff, and society staff
        $members = Member::all();
        $staff = Staff::all();
        $societyStaff = SocietyStaff::all();
        
        if ($members->isEmpty() || ($staff->isEmpty() && $societyStaff->isEmpty())) {
            $this->command->info('No members or staff found. Please run the MemberSeeder, StaffSeeder, and SocietyStaffSeeder first.');
            return;
        }
        
        // Create ratings for member staff
        foreach ($staff as $s) {
            // Generate between 0 and 10 ratings for each staff
            $numRatings = $faker->numberBetween(0, 10);
            
            for ($i = 0; $i < $numRatings; $i++) {
                // Get a random member (excluding the owner of the staff)
                $member = $members->where('id', '!=', $s->member_id)->random();
                
                // Create a rating
                StaffRating::create([
                    'member_id' => $member->id,
                    'staff_id' => $s->id,
                    'staff_type' => 'member',
                    'rating' => $faker->numberBetween(1, 5),
                    'feedback' => $faker->optional(0.7)->paragraph(),
                    'created_at' => $faker->dateTimeBetween('-1 year', 'now'),
                    'updated_at' => now(),
                ]);
            }
        }
        
        // Create ratings for society staff
        foreach ($societyStaff as $s) {
            // Generate between 0 and 20 ratings for each society staff
            $numRatings = $faker->numberBetween(0, 20);
            
            for ($i = 0; $i < $numRatings; $i++) {
                // Get a random member
                $member = $members->random();
                
                // Create a rating
                StaffRating::create([
                    'member_id' => $member->id,
                    'staff_id' => $s->id,
                    'staff_type' => 'society',
                    'rating' => $faker->numberBetween(1, 5),
                    'feedback' => $faker->optional(0.7)->paragraph(),
                    'created_at' => $faker->dateTimeBetween('-1 year', 'now'),
                    'updated_at' => now(),
                ]);
            }
        }
        
        $this->command->info('Staff ratings seeded successfully.');
    }
}
