<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MockMembersSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get unit IDs
        $units = DB::table('units')->get();
        
        // Create mock members
        $members = [
            [
                'id' => Str::uuid()->toString(),
                'name' => 'John Doe',
                'email' => 'john.doe@example.com',
                'mobile' => '919876543210',
                'unit_id' => $units[0]->id,
                'company_id' => '8454',
                'unit_number' => $units[0]->unit_number,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Jane Smith',
                'email' => 'jane.smith@example.com',
                'mobile' => '919876543211',
                'unit_id' => $units[1]->id,
                'company_id' => '8454',
                'unit_number' => $units[1]->unit_number,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Bob Johnson',
                'email' => 'bob.johnson@example.com',
                'mobile' => '919876543212',
                'unit_id' => $units[2]->id,
                'company_id' => '8454',
                'unit_number' => $units[2]->unit_number,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Alice Brown',
                'email' => 'alice.brown@example.com',
                'mobile' => '919876543213',
                'unit_id' => $units[3]->id,
                'company_id' => '8454',
                'unit_number' => $units[3]->unit_number,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Charlie Davis',
                'email' => 'charlie.davis@example.com',
                'mobile' => '919876543214',
                'unit_id' => $units[4]->id,
                'company_id' => '8454',
                'unit_number' => $units[4]->unit_number,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('members')->insert($members);
    }
}
