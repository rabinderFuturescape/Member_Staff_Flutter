<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class ImportSqlSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('Importing mock data from SQL file...');
        
        $sqlFile = database_path('seeders/sql/mock_member_staff_seed.sql');
        
        if (!File::exists($sqlFile)) {
            $this->command->error('SQL file not found: ' . $sqlFile);
            return;
        }
        
        // Get the SQL content
        $sql = File::get($sqlFile);
        
        // Split SQL file into individual statements
        $statements = array_filter(array_map('trim', explode(';', $sql)));
        
        // Execute each statement
        foreach ($statements as $statement) {
            if (!empty($statement)) {
                try {
                    DB::unprepared($statement . ';');
                } catch (\Exception $e) {
                    $this->command->error('Error executing SQL: ' . $e->getMessage());
                    $this->command->error('Statement: ' . $statement);
                }
            }
        }
        
        $this->command->info('SQL import completed successfully.');
    }
}
