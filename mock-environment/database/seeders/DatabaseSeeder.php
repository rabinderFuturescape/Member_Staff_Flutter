<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\File;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Check if SQL file exists
        $sqlFile = database_path('seeders/sql/mock_member_staff_seed.sql');

        if (File::exists($sqlFile)) {
            // If SQL file exists, use it
            $this->call(ImportSqlSeeder::class);
            $this->command->info('Used SQL file for seeding.');
        } else {
            // Otherwise use the mock seeders
            $this->command->info('SQL file not found. Using mock seeders instead.');
            $this->call([
                MockUnitsSeeder::class,
                MockMembersSeeder::class,
                MockStaffSeeder::class,
            ]);
        }
    }
}
