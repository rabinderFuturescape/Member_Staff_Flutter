<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Tymon\JWTAuth\Facades\JWTAuth;
use App\Models\User;

class GenerateTestToken extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'generate:test-token {--member-id=} {--unit-id=} {--company-id=}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generate a test JWT token for development';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $memberId = $this->option('member-id');
        $unitId = $this->option('unit-id');
        $companyId = $this->option('company-id');

        if (!$memberId) {
            // Get the first member from the database
            $member = DB::table('members')->first();
            if ($member) {
                $memberId = $member->id;
                $unitId = $member->unit_id;
                $companyId = $member->company_id;
            } else {
                $this->error('No members found in the database. Please seed the database first.');
                return 1;
            }
        }

        // Get member details
        $member = DB::table('members')->where('id', $memberId)->first();
        
        if (!$member) {
            $this->error('Member not found with ID: ' . $memberId);
            return 1;
        }

        // Create a custom token payload
        $customClaims = [
            'member_id' => $memberId,
            'unit_id' => $unitId ?? $member->unit_id,
            'company_id' => $companyId ?? $member->company_id,
            'member_name' => $member->name,
            'unit_number' => $member->unit_number,
            'email' => $member->email,
            'mobile' => $member->mobile,
        ];

        // Make sure we have a user in the database
        $user = User::first();
        if (!$user) {
            $this->error('No users found in the database. Please seed the database first.');
            return 1;
        }

        // Generate token with custom claims
        $token = JWTAuth::customClaims($customClaims)->fromUser($user);

        $this->info('Test token generated successfully:');
        $this->line($token);
        
        $this->info('Token payload:');
        $this->table(
            ['Key', 'Value'],
            collect($customClaims)->map(function ($value, $key) {
                return [$key, $value];
            })->toArray()
        );

        return 0;
    }
}
