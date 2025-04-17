<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MockUnitsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create mock units
        $units = [
            [
                'id' => Str::uuid()->toString(),
                'unit_number' => 'A-101',
                'company_id' => '8454',
                'block' => 'A',
                'floor' => '1',
                'unit_type' => '2BHK',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => Str::uuid()->toString(),
                'unit_number' => 'A-102',
                'company_id' => '8454',
                'block' => 'A',
                'floor' => '1',
                'unit_type' => '3BHK',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => Str::uuid()->toString(),
                'unit_number' => 'B-201',
                'company_id' => '8454',
                'block' => 'B',
                'floor' => '2',
                'unit_type' => '2BHK',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => Str::uuid()->toString(),
                'unit_number' => 'B-202',
                'company_id' => '8454',
                'block' => 'B',
                'floor' => '2',
                'unit_type' => '3BHK',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => Str::uuid()->toString(),
                'unit_number' => 'C-301',
                'company_id' => '8454',
                'block' => 'C',
                'floor' => '3',
                'unit_type' => '4BHK',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('units')->insert($units);
    }
}
