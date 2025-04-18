<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;

class MemberStaffAttendanceTest extends TestCase
{
    use RefreshDatabase;

    public function testMemberCanSubmitAttendance()
    {
        $user = User::factory()->create(['role' => 'member']);

        $response = $this->actingAs($user, 'api')->postJson('/api/member-staff/attendance', [
            'member_id' => 1,
            'unit_id' => 1,
            'date' => now()->toDateString(),
            'entries' => [
                ['staff_id' => 1, 'status' => 'present'],
                ['staff_id' => 2, 'status' => 'absent'],
            ]
        ]);

        $response->assertStatus(200)->assertJson(['status' => 'saved']);
    }
}
